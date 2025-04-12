---
layout:     post                       # 使用的布局（不需改）
title:      java.util.function 之中的 function 详解         # 标题 
subtitle:   对jdk8开始引入的function做解读        #副标题
date:       2025-04-12        # 时间
author:     Haiming                         # 作者
header-img: img/post-bg-2015.jpg     #这篇文章标题背景图片
catalog: true                         # 是否归档
tags:                                #标签
    - Programming
---

# BiConsumer\<T, U>

输入两个参数且不返回结果的操作

例子: 输出一个map之中所有的K-V 对

```java
        Map<String, String> map = new HashMap<>();
        map.put("key1","value1");
        map.put("k2","v2");
        BiConsumer<String,String> biConsumer = (k,v) -> System.out.println(k+";"+v);
        map.forEach(biConsumer);
```

输出:

```java
key1;value1
k2;v2
```

# BiFunction\<T, U, R>

输入两个参数, 且**返回一个结果**的操作
