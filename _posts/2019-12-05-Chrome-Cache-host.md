---
layout:     post   				    # 使用的布局（不需要改）
title:      对于不同域名之间浏览器Cache处理方式的小探究  		# 标题 
subtitle:   记一次RabbitMQ的排查处理        #副标题
date:       2019-12-05		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Cache
    - RabbitMQ
---

今天遇到了一个很有趣的问题，是这样的：

在 develop 环境和 staging 环境上，有两套版本不同的 RabbitMQ，均需要通过跳板机进行端口映射再使用。 但是在 staging 环境上是可以用 `127.0.0.1` 和 `localhost` 登录的，在 develop 环境上面就只可以用 `localhost` 登录。

目标：在两个环境之下都可以使用 `127.0.0.1` 和 `localhost` 登录。

下面是排查过程的记录：

- 首先考虑是不是本地的 host 映射关系有错，在查看 `/etc/hosts` 之后，发现映射关系是没有问题的，localhost 对应的就是 127.0.0.1 
- 那么也肯定不是跳板机的问题，因为映射之后都是 127.0.0.1: 15672 映射到跳板机的同一个端口，从这里开始没有任何区别，因此不排查从跳板机之后的过程。
- 从跳板机往前排查，那么就想到是不是应该使用不同浏览器尝试
- 尝试使用safari，发现 `127.0.0.1` 和 `localhost` 都可以使用。初步判定是 chrome 问题
- 经过排查之后发现，是因为chrome之中的cookie管理是通过域名的，在 chrome 之中， localhost 和 127.0.0.1 的cookie是不同的，然而不同版本之间的 RabbitMQ 的 cache 是冲突的，因此会报错。之前我一直使用127.0.0.1 ， 所以在这个页面会报错，但是在localhost的时候就会因为从未使用过，因此没有 cache 的冲突问题，所以不会报错。