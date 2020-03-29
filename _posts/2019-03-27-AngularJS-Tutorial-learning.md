---
  layout:     post                       # 使用的布局（不需要改）
  title:     学习AngularJS：PhoneCat 与3月27日日常记录            # 标题 
  subtitle:   官方Tutorial的一点总结和体会，版本1.3.16 #副标题
  date:       2019-03-27                # 时间
  author:     Haiming                         # 作者
  header-img: img/post-bg-2015.jpg     #这篇文章标题背景图片
  catalog: true                         # 是否归档
  tags:                                #标签
      - Programming
      - Study
      - AngularJS
---

  [教程地址在这](https://code.angularjs.org/1.3.16/docs/tutorial),此处放的是1.3.16版本

# 1. 初始化环境的准备

## 1.1 npm install有什么作用？

  npm install这个命令读取了angular-phonecat的package.json文件（因此有很多时候提示package.json文件缺失报错），并且把以下的工具下载到`node_modules`目录之中。

1. Bower-客户端代码包管理器
2. Http-Server-本地静态Web服务器
3. Karma-单元测试运行器
4. Protractor-端到端测试运行器

  之后可以使用`npm start`来启动一个本地Web服务器，`npm test`来启动Karma单元测试运行器

## 1.2 环境都去哪配置？

  可以编辑package.json内部的"start"脚本，

1. 使用’-a‘ 设置地址（address）
2. 使用’-p‘设置端口（port）

## 1.3 在哪测试？

  测试部分在karma之中，使用`npm test`来测试。

  `karma.conf.js`是karma进行测试的初始配置文件。

  下面对于`karma.conf.js`之中的字段进行解释：

1. `module.exports = function(config)`：这部分指向一个接受一个参数的function
2. `basePath`： 对于所有的`files`和`exclude`之中的文件路径的初始定义。
3. `autoWatch`：Default是true,决定当文件有改动时候是否自动执行测试

  若其在后台一直运行，可以针对代码操作进行实时反馈。

# 2. Bootstrapping

## 2.1 `ng-app`

  `<html ng-app>`

  用来规定AngularJS的作用范围。可以选择整个页面或者某个部分。

## 2.2 AngularJS script tag

  用于下载angular.js， 之后将其作为bootstrap应用到`ngApp`的范围之内。

## 2.3 Double-curly binding with an expression

  双大括号里面的值在绑定之后替换回原来双大括号的位置。

## 2.4 Bootstrapping AngularJS apps

  通常使用`ngApp`来自动做Bootstrap。

  当Bootstrap完成之后，其会等待操作例如点击鼠标，若操作对model做出改变，则直接更新所有被影响的Binding

# 3. Static Template

1. 所有的操作，类似于`ng-repeat`和`ng-controller`,都是写在标签里面的。标签的范围也就是操作起作用的范围。
2. *<ul>*之中包含*<li>*, 其中*<li>*是*<ul>*的一个项。每一个*<li>*前面都会有*<ul>*的那个点。

  

# 4. AngularJS templates

  

  本步骤之中的所有操作都是对于app.js文件。

1. 首先在一开始要定义一个变量作为整个module的名字，用于html文件之中引用。
2. 定义一个controller，个人认为是controller的constructor，对于这个controller之后的参数（$scope)而言，下面的所有变量都要用scope来定义，例如scope.phone可以在html文件之中的{{phone.xxxxx}}之中使用。这里的scope仅仅在这个controller的作用域下面起作用。
   - `phonecatApp.controller('PhoneListController', function PhoneListController($scope) `
   - 上面是一个标准的定义controller的代码，`phonecatApp`是module的名字，`PhoneListController`是controller的名字，后面的($scope)是整个函数的作用域。
   - 注意`'PhoneListController'`之前的括号是直接一括到底的，包含了整个constructor的所有内容。
   - **在这里就定义了一个PhoneListController然后将其注册成了一个AngularJs module。**
3. $scope 是在程序初始化时候就创建的rootscope的child，所有的scope都是继承于rootscope的。

## 4.1 Scope

  

  scope是model和controller之间的纽带。官方教程之中解释如下：

  

> A scope can be seen as the glue which allows the template, model, and controller to work together.

  

  个人认为scope是将model和controller之间的改变同步绑定的一种方式，是实现interactive application的工具。

  

## 4.2 Controller

  

  We can write scripts to do test automatically with AngularJS. The testing of AngularJS is :

  

1. Load `phonecatApp` module.
2. Inject `$ controller` service to test function.
3. With the `$Controller`to create an instance of `PhonelistController`
4. Verify if the result is the same as ours.

  

  Always we create the testing file with some suffix in the name, in the tutorial it is `.spec`.

  

## 4.3 Testing with `npm test`

  

  The testing function of  AngularJS is `Jasmine` ,and `npm test`is to use Karma do the test. 

  

  Basic grammer of testing is `expect(scope.xxx).toBe(xxx);`

  

  In the command window, it will show the result matches expectation or not. 

  

# 5.Components

  

  In AngularJS, the client-side not only "show" the HTML page from a server, but also takes some functions so it can interact in model data or state., which is a kind of user interaction.

  

## 5.1 What do components solve?

  

  There are 2 things we can do better:

1. It is difficult to reuse the same functionality in a different part of the application.
   - Now the solution is to duplicate the whole template to reuse.
2. The scope isn't isolated with other parts in the page so if there is something wrong unexpected in the page, it is difficult to debug 

## 5.2 What is Components?

  

  A component is a combination of template and controller .  And each component is separated.

  

  The template contains structures for style of how the website shows .Such as some lists and {{}} to contain data .

  

  The controller always contains data should be filled in {{}}

  

  

  

  For some reasons ,it isn't recommended to use `$scope` directly, instead , official recommendation is use alias.

  

  So we can just create one component and then use it everywhere. 

  

# 6.Directory and File Organization

  The main job is to 

- Put each entity in its **own file**.
- Organize our code by **feature area**, instead of by function.
- Split our code into **modules** that other modules can depend on.

  

  Each feature should declare its own module and all related entities should register themselves on the module.

  

  So just new folders and then put things have the same element or related together.

  

# 7. Filtering Repeaters

  

  it is very simple to use the filter. First we can pass the value through `ng-model="$ctrl.query"`,then we use it in the `ng-repeater`with a filter, like `ng-repeat="phone in $ctrl.phones | filter:$ctrl.query"`

  

  Then the page will do the filter auto and show the results sync.

  

  

# 8.Two-way Data Binding

  

  We can add orderProp to the component so when it in initialized it has the order.

  

  Why tutorial called the "Sort" function as a `two way data-binding`? Because it has the `this.orderProp`in the component, so that when it is initialized, it has the function that put sorted model data to the view, and when we choose to "sort by alphabetical ", it then shows the things order in alphabet and send to model .So I think it is the "2 way binding"

  

  And in the sort it is very easy to revert the result with "-" before the option.

  

# 9 XHR(XMLHttpRequest) & Dependency Injection

  

  $ is the prefix of services that provided by AngularJS

  

# 10. Templating Links & Images

  

  Here is to use Bootstrap to create a table :`div class="col-md-10"`. And we create a label for pics to link to some different urls.

  

# 11. Routing and Multiple Views

  This step is to create different views for different devices. And if we create the views manually, it will be hard to maintain . So that we choose to use templates autogenerate views on website.

  

  

  In AngularJS, routing is done by `ngRoute` module . And `angular-route` is a library ,not in the AngularJS framework. 

  

  Application routes are decleared in $routeProvider, and it is a provider of `route` service. It is easy to merge controllers, view templates and URL locations.  And we can implement the features with the `ngRoute` ,and then use browser to go forward or backward or bookmarks. 

  

  And here is my view : if we use the `GET` method, it is very easy to let the customers store information in the bookmarks , but if we use `POST` ,it isn't very easy to do it ,because information is stored in the content not url. 

  

## 11.1 How does dependency injection(DI) in AngularJS work?

  Here is from tutorial:

  

  When the application is created, it will do instantiation for the injector, and at the time, the injector doesn't know anything about how to do specific work such as `$http` or `$route`. It has to be configured to do these things. 

  

  Then it receive all the parameters and instantiate services for specific works then pass the parameters to injectable function .

  

#### What is provider?

  

> Providers are objects that provide (create) instances of services and expose configuration APIs, that can be used to control the creation and runtime behavior of a service. In case of the `$route` service, the `$routeProvider` exposes APIs that allow you to define routes for your application.

  

  So the main functions are :

- provide instances of services
- expose configuration APIs

  

  And the limit of Provider is that it can be only injected into `config` functions. Thus when at runtime , we cannot inject `routeProvider` into the `PhoneListController` .

  

  And in this situation we use a template `ng-view` and insert it into the body of  our `index.html` .

  

  Don't forget to add script into html page so that it can be installed, which is the solution of [Module 'ngRoute' is not available](https://stackoverflow.com/questions/30719722/module-ngroute-is-not-available)  .the script contains `app.config.js` and 'lib/angular-route/angular-route.js'

  

  

## 11.2 Steps for routing in AngularJS

  

1. insert `'ngRoute' ` into `app.module.js` .
2. create a `app.config.js` file .
   - `.config` method is a method for us to get access to all `Providers` for configuration. It is a link.
3. For $routeProvider, we can write a `when` to choose different options when type in different urls.

  

### 11.3 Why default url always contains `#!`

  

  The reason is :

   

  '#' is the hash part of url to determine current route.

  '!' is the hash-prefix and needs to appear after '#' , so it can be consider as a 'AngularJS path'. '! ' is the default value.

  

  So sum above up, the default way for AngularJS to get its own path is #!

  

## 11.4  A note on Sub-module Dependencies

  

  Although we can import the extension of `ngRoute` in the whole application and then delete the part of import extensions in the sub-module, `it will break our hard-earned modularity`. 

  

  So the `modularity` in my view is we can pick up any module we want , and then insert it into another project, then it will work .  It doesn't rely on the parent module's dependencies.

  

  

# 12 . More Templating

  

  In this part, we change the templateUrl of `phone-detail component` to a link . And the controllers are added one '$http' .

  

  Then in the `phone-detail.html` we have databinding with {{}}, then it uses `ctrl.phone.availablity` to bind data from database.

  

# 13. Customer Filters

  

  We can register our own module in `app/core` module.In this chapter, we created our own filter called `checkmark` in it .

  

# 14. Event Handlers

  

  In any component we created we can both set functions and use functions in controller part.

  

# 15 RESTful APIs

  

  `ngResource` is a module specially made for RESTful structure . it provides `$resource` module, which is a encapsulation of `$ http` 

  

  There are 5 methods for `$resource`:

1. get: {method:'GET'}, always use to get one special resource
2. query:{method:'GET',isArray:true},always get a set of resources and return in array.
3. save:{method:'POST'}, used to save one resource, maybe update, and maybe new a resource .
4. remove:{method:'DELETE'}:used to delete one resource
5. delete:{method:'DELETE'}: used to delete one resource

  

  It is easier to use functions that related with `$resource`  service than `$http` service when we use the RESTful resources. So we replace the `$http` service with our own `Phone` service. 

  

  

# Summarize

  

  In AngularJS, the flow is from `index.html` , which contains AngularJS modules, and then it generate extentions with `app.config.js`, such as ngRoute ,then it turns to components ,which contains `template` and `controller` ,put data in controller to corresponding views. 

  

  Data can be passed through urls between different views. 

  

# 3月27日日常记录

### 1. What is the difference between Authentication and Authorization?

  Authentication的翻译为认证，而Authorization的翻译是授权。

  简而言之，Authentication意思是”确定你是谁“，而Authorization的意思是”确定你有什么权限“

  

### 2. What is E2E test?

  

  E2E test is a way to simulate a real environment ,such as browser and then do testing .When they meet problems , maybe it is because of frontend or backend.

  

### 3. Why we have to use `var self=this` in JS, not just use `this` ?

  

#### 3.1 What is closure?How do we use closure?

  

  In my view ,Closure is a method for outside program viewing local variables. 

  

  If we want to view a local variable outside the program A, we have to write a program B inside program A , and then use A to visit B and get variables in B. This is 'Closure' . 

  

  What do we use it for? First is read variables inside method, second it provides  a trick to store variables in memory, priventing it from processed by GC.

#### 3.2 Why do we have to use `var self=this` ?

  

  Every method be analysised by ECMAScript has two special variables,` this` and `argument` .In other words, every method has its own `'this'` ,and in global variables, it refers to the object `window` ,and in the methods provided by ourselves, it refers to the object of the function . 

  

  So if I created another var for this, such as `var self=this` ,  I can refer to this special 'this' to get the inside of the method. 

  

  Here are two pieces of codes for the function :

  1st:
--------  
```

  var name = "The Window";
　　var object = {
　　　　name : "My Object",

　　　　getNameFunc : function(){
　　　　　　return function(){
　　　　　　　　return this.name;
　　　　　　};
　　　　}
　　};
　　alert(object.getNameFunc()());


```

--------

　　

2nd:

---------

```

 var name = "The Window";
　　var object = {
　　　　name : "My Object",
　　　　getNameFunc : function(){
　　　　　　var that = this;
　　　　　　return function(){
　　　　　　　　return that.name;
　　　　　　};
　　　　}
　　};
　　alert(object.getNameFunc()());
  
```

---------


The 1st one pop up a notice showed "The Window" , and the second one pop up a notice showed "My Object "



This is because of in the 1st one, ` this ` means the global variable , `window` , and then it returns "The Window". In the 2nd one, we use `that` to refer the variable `that=this` ,which can visit things inside the method, so it returns 'My Object'


　　

  

  

  

  

  

# 一些小Tips

1. 建议把脚本放在 <body> 元素的底部。这会提高网页加载速度，因为 HTML 加载不受制于脚本加载。

- 此处的脚本为`<script src="https://cdn.staticfile.org/angular.js/1.4.6/angular.min.js"></script>`

