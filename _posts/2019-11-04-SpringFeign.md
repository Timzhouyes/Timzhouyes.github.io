---
layout:     post   				    # 使用的布局（不需要改）
title:        关于API设计和Spring的一点记录				# 标题 
subtitle:       总结一下最近踩到的坑            #副标题
date:       	2019-11-01			# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Spring
    - API
---

做中学的确是最快学习的方式……开冲

# 1. 对API设计的一些经验总结

下面是针对应用内部，即前端对后端的API的设计之中总结的一点经验。

1. 命名：前端对后端的API不应叫做 Internal API，Internal API 是内部的一些功能，是不对用户开放的，比如黑名单设置等等。前端对后端的API应直接叫做 API
2. 在API的设计之中，命名和URL设计的原则要让人一眼知道其作用。由于之前看到的例子之中，RESTful 的API的例子都是以名词作为URL，因此之前的设计之中一直以为只有名词做URL才是RESTful，导致第一版设计出来的效果不好，究其原因，是因为很多内容不能只用HTTP的method（比如GET和POST）加上名词来表示，因此尽量简练即可。
3. 在命名方面，URL之中是使用连接线来链接，参数是使用小驼峰。
4. 对于参数之中的Object，要把所有的对应参数写齐，不能只确定一个Object但是不放具体参数，这样会对于前端人员的API使用造成很大的困扰。
5. API的简介要简练的将作用写出来。

# 2. Spring 使用过程之中的一些经验

最近在赶MyInfo API对接的时候，对于Spring的使用有了进一步的理解，还有对 Groovy 的使用也有了一些领悟，下面是总结：

Spring 之中，对于某些默认无法转换成Object的对象，比如本次之中的 JWE，Spring Feign无法从返回的请求将其转换成 *JSON Web Encryption* ，那么就需要使用 Feign 本身的原生返回，即 Response 类进行自己的转换。直接从 Response 之中拿到其Body 并且对其做解析，自己将其转换成对应的类，是这种情况下解决问题的较快方法。当然，也可以像其报错信息一样，自己去写一个 HttpMessageConverter， 但是这种情况下较慢。

