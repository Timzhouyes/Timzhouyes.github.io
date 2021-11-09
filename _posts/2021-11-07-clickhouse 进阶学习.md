---
layout:     post   				    # 使用的布局（不需要改）
title:      Clickhouse Optimization  		# 标题 
subtitle:   尚硅谷 clickhouse 进阶课程笔记        #副标题
date:       2021-11-07		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - clickhouse
---

# Chapter 1 Get Execution plan by `Explain`

Before version 20.6, if we need to get execution plan we need look into the logs, from 20.6 we can use `explain` to get execution plan.

## 1.1 Basic grammar

Refer: https://clickhouse.com/docs/en/sql-reference/statements/explain

```sql
EXPLAIN [AST | SYNTAX | PLAN | PIPELINE] [setting = value, ...] SELECT ... [FORMAT ...]
```

There are 4 types for explaining:

1. Plan: Default value, for getting the excution plan
   - Header: Default 0, can show the type of all parameters
   - Description: Default 1, show step-by-step description for the execution plan
   - Actions: Default 0, show detailed information of all steps
2. AST: Show grammar tree for execution plan
3. SYNTAX: Show optimized grammer for execution plan
4. PIPELINE: Will show detailed information, like how many threads did the work

Here are some examples:

1. **Simple query**

```sql
explain plan select arrayJoin([1,2,3,null,null]);
```

Result:

```sql
EXPLAIN
SELECT arrayJoin([1, 2, 3, NULL, NULL])

┌─explain───────────────────────────────────────────────────────────────────┐
│ Expression ((Projection + Before ORDER BY))                               │
│   SettingQuotaAndLimits (Set limits and quota after reading from storage) │
│     ReadFromStorage (SystemOne)                                           │
└───────────────────────────────────────────────────────────────────────────┘

3 rows in set. Elapsed: 0.004 sec.
```

2. **Execution plan for complex query**

```sql
explain select database,table,count(1) cnt from system.parts where
database in ('datasets','system') group by database,table order by
database,cnt desc limit 2 by database;
```

Above is the SQL for query in system database, and here is the result:

```sql
┌─explain─────────────────────────────────────────────────────────────────────────────────────┐
│ Expression (Projection)                                                                     │
│   LimitBy                                                                                   │
│     Expression (Before LIMIT BY)                                                            │
│       MergingSorted (Merge sorted streams for ORDER BY)                                     │
│         MergeSorting (Merge sorted blocks for ORDER BY)                                     │
│           PartialSorting (Sort each block for ORDER BY)                                     │
│             Expression (Before ORDER BY)                                                    │
│               Aggregating                                                                   │
│                 Expression (Before GROUP BY)                                                │
│                   Filter (WHERE)                                                            │
│                     SettingQuotaAndLimits (Set limits and quota after reading from storage) │
│                       ReadFromStorage (SystemParts)                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

Step sequence is from the bottom to the top.

3. **AST grammar tree**

```sql
EXPLAIN AST SELECT number from system.numbers limit 10;
```

```sql
┌─explain─────────────────────────────────────┐
│ SelectWithUnionQuery (children 1)           │
│  ExpressionList (children 1)                │
│   SelectQuery (children 3)                  │
│    ExpressionList (children 1)              │
│     Identifier number                       │
│    TablesInSelectQuery (children 1)         │
│     TablesInSelectQueryElement (children 1) │
│      TableExpression (children 1)           │
│       TableIdentifier system.numbers        │
│    Literal UInt64_10                        │
└─────────────────────────────────────────────┘
```

4. **SYNTAX grammar optimization **
   Below is the example for before and after opening conditional operator(三目运算符)

   ```sql
   SELECT number = 1 ? 'hello' : (number = 2 ? 'world' : 'atguigu') FROM numbers(10);
   ```

   ```
   ┌─if(equals(number, 1), 'hello', if(equals(number, 2), 'world', 'atguigu'))─┐
   │ atguigu                                                                   │
   │ hello                                                                     │
   │ world                                                                     │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   │ atguigu                                                                   │
   └───────────────────────────────────────────────────────────────────────────┘
   ```

   And we see the optimization for conditional operator:

   ```sql
   EXPLAIN SYNTAX
   SELECT if(number = 1, 'hello', if(number = 2, 'world', 'atguigu'))
   FROM numbers(10)
   
   ┌─explain────────────────────────────────────────────────────────────┐
   │ SELECT if(number = 1, 'hello', if(number = 2, 'world', 'atguigu')) │
   │ FROM numbers(10)                                                   │
   └────────────────────────────────────────────────────────────────────┘
   ```

   Here we can see no change because we didn't open the optimization choice for conditional operator.

   And we open it:

   ```sql
   SET optimize_if_chain_to_multiif = 1;
   ```

   ```sql
   EXPLAIN SYNTAX
   SELECT if(number = 1, 'hello', if(number = 2, 'world', 'atguigu'))
   FROM numbers(10)
   
   ┌─explain─────────────────────────────────────────────────────────────┐
   │ SELECT multiIf(number = 1, 'hello', number = 2, 'world', 'atguigu') │
   │ FROM numbers(10)                                                    │
   └─────────────────────────────────────────────────────────────────────┘
   ```

   Previously the result is several `if`, and after we open the optimization then can see it becomes `multiIf`, which is like `switch`.

5. **For pipeline**

   ```sql
   EXPLAIN PIPELINE
   SELECT sum(number)
   FROM numbers_mt(100000)
   GROUP BY number % 20
   
   ┌─explain─────────────────────────┐
   │ (Expression)                    │
   │ ExpressionTransform             │
   │   (Aggregating)                 │
   │   Resize 32 → 1                 │
   │     AggregatingTransform × 32   │
   │       (Expression)              │
   │       ExpressionTransform × 32  │
   │         (SettingQuotaAndLimits) │
   │           (ReadFromStorage)     │
   │           NumbersMt × 32 0 → 1  │
   └─────────────────────────────────┘
   ```

   Here can see some `32` , which means the machine we are using now is 32 working threads.

# Chapter 2 Optimization for creating tables

