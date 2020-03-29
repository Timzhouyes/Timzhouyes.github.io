---
layout:     post   				    # 使用的布局（不需要改）
title:      Record of intern 				# 标题 
subtitle:   Just record #副标题
date:       2019-03-11 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 实习
    - 记录
---
### 11/03/2019
1.  Analysis the demand of event app (Eventbrite and Pigeonhole)
2.  Search on google & Github if there is similar projects

### 16/04/2019
今日经验总结：
1. 如果想在浏览器上，当用户点击时弹出提示且一段时间自动消失并跳转到其他网页，可以使用`modal`，其为`Bootstrap`之中的一个插件。使用方式为: 
- 前提如下： `div class="modal fade" id="RegisterSuccessModal" dex="-1" tabinrole="dialog" aria-labelledby="RegisterSuccessModal" aria-hidden="true"`
- 先弹出提示：`$('#RegisterSuccessModal').modal('show');`
- 再延时一段时间后让提示消失。此处需要延时是因为[All API methods are asynchronous and start a transition. They return to the caller as soon as the transition is started but before it ends. In addition, a method call on a transitioning component will be ignored.](https://getbootstrap.com/docs/4.0/components/modal/#methods)。此处如果不延时，亲测会发生背景无法消除的现象。
- 之后在延时之中调用跳转代码，如下
```window.setTimeout(function () {
window.location.href = "#/login";
$window.location.reload();
},3000);
```

### 17/04/19
今天主要做了给admin的user-management页面，实现了：
- 筛选功能：admin可以看到所有图片，用户只可以看到自己的图片
- 只有admin的bar上有user-management的选项
- API之中实现了返回所有用户，但是不返回密码的查询

今日收获：
1. 在不同的var之间跳转的时候，`$rootscope`的值会清除，也就是说，其实已经换了一个对象，相当于页面跳转并刷新了（因为`display`和`main`二者是两个完全没有关系的页面，`display`的路由在`index.js`之中，其业务逻辑在自己的`display.js`里面，而对于`main.js`的`$rootScope`，所有的`controller`都在里面。）
- 在看到开了`console`的情况下，页面从`main`跳转到`display.js`之时整个`console`之中的所有数据清除就应该知道不对劲了……这分明就是纯纯粹粹的刷新！！肯定啥都没有了……
- 最后实现是使用了`$cookieStore`来进行的，在使用Chrome调试的时候，发现不论是`$http`还是`$cookieStore`都显示没有定义，但是下面的测试发现可以使用，目前看来`console.log()`是任何情况下都比较靠谱的方式，可以将其中的所有数据输出，不会出现内部保存了数据但是提示没有定义的情况。
2. ModgoDb之中查询的方式和Node.js连接MongoDb之后查询的方式不同。下面是二者返回数据之中去掉指定`password`列的query方法：
- MongoDb之中: `db.getCollection('User').find({},{"password":0})`
- Node.js和MongoDb结合： ` const collection = db.collection('User');     collection.find({},{projection:{"password":0}})`
