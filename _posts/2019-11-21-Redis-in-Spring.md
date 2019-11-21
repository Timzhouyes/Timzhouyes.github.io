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





