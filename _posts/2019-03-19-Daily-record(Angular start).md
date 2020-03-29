---
layout:     post   				    # 使用的布局（不需要改）
title:      Daily record (Angular.js)				# 标题 
subtitle:   To study Angular.js #副标题
description: Try it now
date:       2019-03-19 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 日常
    - 记录
    - Study
    - Angular.js
---
# 0. 今日工作遇到问题
1.   mongoDB要在mongoDB的Bin文件夹下面开，而不是在所要开启的项目文件夹下面开启
2.   在Angular.js之中一定要注意好所在函数的作用域，不然会有问题，今日因为忽视了作用域，直接导致debugger死活进不去。以后要注意。
# 1. 梳理一下基本的Angular.js传值步骤
  如何在Angular.js之中做到同步传值？按照之前所说，Angular.js是双向绑定，因此只要在程序之中说明其需要什么就好。
  ```<input type="xxx" ng-model="this.maxPrice" /> ```
  这句话指定了输入的类型（xxx）和 maxPrice 这个变量，那么只要在contoller.js之中定义一个一样的变量(this.maxPrice) ，然后对其进行操作就可以实时的同步view和model的值。

然后在controller之中便可以调用这个值，各种输出计算全都不在话下了。 注意在 controller之中， 其也要叫做 this.maxPrice , 即使这个地方的 this 只是用于标注当前的这个 controller 。
# 2.Angular.js 动作
在Angular.js 之中，想要对于网页的动作进行一个绑定，只需要在.html文件之中定义好自己的代码块和动作，然后在 .js 文件之中直接调用其id进行引用就好。
``` $('IdOfTheMethod').whatever```
通常是上面所述的格式， id 用 $ 标注出来


  
  

#  # 今日科普：（别人早就会了我还不知道的知识……）
## 1.什么是Owin
Owin全程是Open Web Interface for .NET.个人理解其就是一个中间件，是用来使 .NET 的程序脱离某个具体的服务器环境来设置的。

我们都知道Web应用程序是运行在Web服务器之中的，应用程序的请求接收和数据发送都是通过web
服务器，这样就给应用程序的开发造成了一些困难。这种情况之下，如果可以将Web程序对于服务器的要求统一抽象出来，针对这个抽象接口编程，那么会容易很多。

Owin就是这样的一个接口。


