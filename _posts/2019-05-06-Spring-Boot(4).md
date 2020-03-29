---
layout:     post   				    # 使用的布局（不需要改）
title:      《Spring Boot 42讲》学习笔记（4） 				# 标题 
subtitle:   构建RESTful API服务  #副标题
date:       2019-05-06				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Spring Boot
    - 记录
    - Study
    - Java
---

# 第2-8课：Spring Boot 构建一个 RESTful Web 服务

RESTful 的核心概念是“资源”，从 RESTful 的角度来看，网络之中，无论一段文本，图片，歌曲，服务等等都对应一个特定的URI，并且用URI进行表示，访问这个URI就可以得到这个资源。

资源可以有多种表现形式，也就是资源的“表述（Representation）。

此处教程所举的例子是一张图片，既可以是 JPEG 格式，也可以是 PNG 格式，但我个人认为不是这样。下面是另一个我认为比较恰当的关于”表述“的定义：

> 例如，对于一个景点，可以用jpeg照片来表示，也可以用包含位置、介绍等信息的json或xml格式来分别表示

在互联网中，客户端和服务器之间的互动传递的就是资源的表述（Representation），我们上网的过程，就是调用资源的URI，获取其不同表现形式的过程。而这种互动只能通过无状态的HTTP，那么所有客户相关的状态就只能在服务端保存。客户端可以使用HTTP的几个基本操作，包括GET（获取），POST（创建），PUT（更新）和DELETE（删除），使服务端的资源发生”状态转化“，也就是所谓的”表述性状态转移 (REST)"。



#### Spring Boot 对于 RESTful 的支持

Spring Boot 通过不同的 annotation 来支持开发 RESTful 服务。

- @GetMapping ， 处理 Get 请求。
- @PostMapping ， 处理 Post 请求。
- @PutMapping， 处理 Put 请求。
- @DeleteMapping， 处理Delete 请求。
- @PatchMapping，用于更新部分资源。

上面这些方法都是 @RequestMapping的一种简写方式。例如 @GetMapping 就是 `@RequestMapping(value="xxx",method=RequestMethod.GET)` 的简写。

#### 快速上手

按照RESTful的思想，设计一组面向用户操作的API：

| 请求   | 地址          | 说明               |
| ------ | ------------- | ------------------ |
| get    | /messages     | 获取所有信息       |
| post   | /message      | 创建一个信息       |
| put    | /message      | 修改消息内容       |
| patch  | /message/text | 修改消息的text字段 |
| get    | /message/id   | 根据ID获取消息     |
| delete | /message/id   | 根据ID删除消息     |

put 用来更新整个资源， patch 用于更新部分字段。



#### Atomic类

在代码之中我们使用了 AtomicInteger 类，其 Atomic 这个属性在下面有所介绍：

先看 Atomic 官方定义：

A small toolkit of classes that support lock-free thread-safe programming on single variables. In essence, the classes in this package extend the notion of `volatile` values, fields, and array elements to those that also provide an atomic conditional update operation.

按我个人的理解，其意味着使用 Atomic 的操作是不可中断的，即使多个线程一起执行，一个操作一旦开始，就不会被其他线程干扰。



要注意，测试的时候发现路由进不去，有可能是因为 Application 的总文件和其他文件夹目录不一致，这样就导致了扫描的时候扫描不到其文件。应该 Application 文件和其他文件夹在 project 的总目录下面。



本项目之中的信息表存储是使用 ConcurrentMap 来存储的：

`private final ConcurrentMap<Long, Message> messages= new ConcurrentHashMap<>();`



# 第2-9课：使用Swagger2 构建 RESTful APIs

