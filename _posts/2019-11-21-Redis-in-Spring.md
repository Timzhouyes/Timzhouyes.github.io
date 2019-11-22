---
layout:     post   				    # 使用的布局（不需要改）
title:      SpringBoot使用RedisTemplate操作Redis  		# 标题 
subtitle:   自己的一些理解和感悟        #副标题
date:       2019-11-21		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - SpringBoot
    - Redis
---

在感叹完Spring对于程序的大大简化之后，在这里总结一下Redis在Spring之中的使用技巧。Spring将Redis封装成一个RedisTemplate，所以本文之中主要总结的是如何使用这个RedisTemplate。话不多说，现在开始。

参考文章地址：https://www.cnblogs.com/superfj/p/9232482.html

本博客之中之前对于Redis的部分学习笔记:

[关于Redis,MyBatis和Spring之中问题的一点梳理](https://timzhouyes.github.io/2019/11/08/工作杂谈RedisSpringBean/)

[Redis浅析](https://timzhouyes.github.io/2019/08/27/Redis/)

# 概述

本文内容主要：

- 关于 spring-redis
- 关于 redis 的 key 设计
- redis 的基本数据结构
- 介绍 redis 和 springboot 的整合
- springboot 之中的 redistemplate 的使用

# 关于spring-redis

Spring-data-redis 针对 jedis 提供了如下功能：

1. 连接池自动管理，提供了一个高度封装的"RedisTemplate" 类

2. 针对 Jedis 客户端之中的大量 API 进行了归类封装，将同一类型的操作封装为 operation 接口。

   ValueOperations: 简单K-V操作

   SetOperations: set 类型数据操作

   ZSetOperations: zset 类型数据操作

   HashOperations: 针对 map 类型的数据操作

   ListOperations: 针对 list 类型的数据操作。

   由上可见，其直接将同一类的数据类型的操作归类，直接操作接口即可对某种数据类型进行直接操作，大大减小其操作复杂度。

3. 提供了对于 key 的 "bound" （绑定）便捷化操作 API， 可以通过 bound 封装指定的 key，即BoundKeyOperations:

   BoundValueOperations

   BoundSetOperations

   BoundListOperations

   BoundHashOperations

4. 将事务操作封装，由容器控制

5. 针对数据的 ” 序列化/反序列化“， 提供了多种可选择策略（RedisSerializer）

   `JdkSerializationRedisSerializer`: POJO 对象的存取场景，使用 JDK 本身序列化机制，将 pojo 类通过 ObjectInputStream/ObjectOutputStream 进行序列化操作，最终在 redis-server 之中存储字节序列。是目前最常用的序列化策略。

   `StringRedisSerializer`: **Key** 或者 **Value** 为字符串的场景，根据指定的 charset， 对数据的字节序列编码成String，是 `new String(bytes,charset)` 和 `String.getBytes(charset) ` 的直接封装。是最轻量级和高效的策略。
   
   `JacksonJsonRedisSerializer`:  Jackson-json 提供了 javabean 和 json 之间的转换能力，可以将pojo实例序列化成json之后存储在Redis之中，也可以将json格式的数据转换成pojo实例。因为 jackson 工具在序列化和反序列化的时候，需要明确指定Class类型，因此此策略封装起来略微复杂。需要【jackson-mapper-asl工具支持】
   
   OxmSerializer: 提供了将 javabean 和 xml 之间的转换能力，目前可用的三方支持包括 jaxb，apache-xmlbeans,redis 存储的数据将是xml 工具，但是难度大，效率低，不建议使用。
   
   **如果数据需要被第三方工具解析，那么数据应该使用StringRedisSerializer，而不是 JdkSerializationRedisSerializer**

# 关于Key的设计

**key的存活时间：**

一个很好的例子就是存储一些诸如临时认证key之类的东西。当去查找一个授权key的时候，以OAUTH为例，通常会得到一个超时时间。在超时时间过了之后，Redis就会自动清除。

**关系型数据库的Redis key 设计**

1. 将表名换为key前缀，比如 tag
2. 第二段放置用于区分 key 的字段，对应 mysql 之中主键的列名，比如 userid
3. 第三段放主键值，如 2，3，4,  a,  b,  c
4. 第四段，写存储的列名

例子：user:userid:9:username

# Redis的数据类型

**String字符串**

- String 是 redis 最基本的类型，一个 key 对应一个 value
- String 类型是二进制安全的，意味着 **Redis的String 可以存储任何数据，包含jpg图片或者序列化对象**
- String 类型是 Redis 最基本的数据类型，一个键最大可以存储512MB

**链表**

- Redis列表是最简单的字符串列表，排序为插入的顺序，列表的最大长度为2^32-1
- Redis的列表是使用链表实现的，这意味着在列表头部或者尾部增加一个元素的时间是常量时间
- 可以使用列表获取最新的内容，比如帖子，微博等等。用 itrim 很容易就可以获取最新的内容，并移除旧的内容
- 用列表可以实现生产者消费者模式，生产者调用 **lpush** 添加项到列表之中，消费者调用 **rpop** 从列表之中提取。如果没有元素，则轮询去获取，或者使用 **brpop**等待生产者添加项到列表之中。

**集合**

- redis 的集合是无序的字符串集合，集合之中的值是唯一的，无序的，可以对集合进行传统意义上面的所有操作，比如查看某个元素是否存在，对几个集合取交集，取并集等等。
- 通常可以使用集合去表示存储一些无关顺序的，表示对象之间关系的数据。比如可以用 sismember 查看用户是否拥有某个角色
- 在用到随机值的场合非常合适，因为可以使用 smember 来随机获取一个元素。同时，采用`@EnableCaching` 开启声明式缓存支持，这种注解缓存是对于缓存使用的抽象，通过在代码之中的注释就可以达到缓存的效果。

**Zset有序集合**

- 有序集合，由唯一的，不重复的**字符串**元素组成。有序集合之中，每个元素都关联了一个浮点值，称为score。 可以看做是一个hash和集合的混合体，score 就是 hash 的key。
- 有序集合之中的元素就是**按序存储**的，而不是在请求的时候才排序的

**Hash-哈希**

- Redis的哈希值是字符串字段和字符串之间的映射。
- 哈希之中的字段数量没有限制，所以可以在应用程序用不同的方式来使用哈希

