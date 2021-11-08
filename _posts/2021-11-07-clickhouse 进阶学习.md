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

