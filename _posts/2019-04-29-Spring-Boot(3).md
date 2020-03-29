---
layout:     post   				    # 使用的布局（不需要改）
title:      《Spring Boot 42讲》学习笔记（3） 				# 标题 
subtitle:   模板引擎Thymeleaf使用  #副标题
date:       2019-04-29				# 时间
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



# 第2-3课：模板引擎Thymeleaf基础使用

### 1. 什么是模板引擎？

模板引擎，是为了用户界面和业务数据（内容）分离而成的，其可以生成特定格式的文档，用于网站的模板引擎就会生成一个标准的HTML文档。

模板引擎的实现有“置换引擎”（将模板内容之中的特定标记替换，但效率底下），“解释型”模板引擎和“编译型”模板引擎等。

### 2. Thymeleaf介绍与其特点

具体介绍网上很多，个人理解 Thymeleaf 就是一个用来写前端的模板。

Thymeleaf的特点如下：

- Thymeleaf在有网络和无网络的条件下都可以运行，既可以查看页面布局等静态效果，又可以查看带数据的动态页面效果。原理是其支持HTML原型，然后在HTML标签之中加入额外的属性来达到模板+数据的方式。由于浏览器在解释HTML的时候会忽略未定义的标签属性，所以Thymeleaf的模板可以静态的运行，当有数据返回的时候，Thymeleaf标签便可以动态的替换掉静态内容，使页面动态显示。
- 开箱即用：支持标准方言和Spring方言，可以直接套用模板实现 JSTL 和 OGNL 等等效果。
- Thymeleaf提供一个Spring标准方言和SpringMVC完美集成的可选模块，可快速实现表单绑定，属性编辑器，I18N等等。

#### 对比

Thymeleaf相比之下使用了自然的模板技术，意味着Thymeleaf的模板语法并不会破坏文档结构，模板依旧是有效的XML文档。

下面是打印消息的对比：

```
Velocity: <p>$message</p>
FreeMarker: <p>${message}</p>
Thymeleaf: <p th:text="${message}">Hello World!</p>
```

可以看到Thymeleaf的作用于在HTML的标签之内，类似于标签的一个属性来使用，这就是其一个特点。

**注意：由于Thymeleaf使用了XML DOM 解析器，因此不适合处理大规模的XML文件**

> 为什么不适合？
>
>  **DOM（Document Object Model)**
>
> ​      DOM是用与平台和语言无关的方式表示XML文档的官方W3C标准。DOM是以层次结构组织的节点或信息片断的集合。这个层次结构允许开发人员在树中寻找特定信息。分析该结构通常需要加载整个文档和构造层次结构，然后才能做任何工作。由于它是基于信息层次的，因而DOM被认为是基于树或基于对象的。
>
> 【优点】
>       ①允许应用程序对数据和结构做出更改。
>       ②访问是双向的，可以在任何时候在树中上下导航，获取和操作任意部分的数据。
> 【缺点】
>       ①通常需要加载整个XML文档来构造层次结构，消耗资源大。
>
> 因此可以看出大规模的XML文件的预先加载会消耗过量资源，因此不是最适合的。



### 快速上手：Thymeleaf的Hello world

首先是加入Dependency

```
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

然后在applications.properties 之中配置变量

`spring.thymeleaf.cache=false`

含义为关闭Thymeleaf的缓存，不然在开发过程之中修改页面不会立刻生效，而是需要重启。生产配置可以为True。



#### 模板页面编写

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8"></meta>
    <title>Hello</title>
</head>
<body>
<h1 th:text="${message}">Hello World</h1>
</body>
</html>
```

这个页面，如果直接在IDEA之中使用Chrome打开，所显示的只有一行“Hello World”，这也体现了thymeleaf的特性，即可以离线访问已经输入页面，便于前端进行操作。

注意，所有使用Thymeleaf的页面必须在HTML标签声明Thymeleaf

`<html lang="en" xmlns:th="http://www.thymeleaf.org">`

表明页面使用的是 Thymeleaf 语法

#### Controller

```java
@Controller
public class HelloController {
    @RequestMapping("/")
    public String index(ModelMap map)
    {
        map.addAttribute("message", "https://timzhouyes.github.io");
        return "hello";
    }
}
```

- 此处和之前不同，使用的是`@Controller` 而非 `@RESTController` ，区别下面讲。
- 代码的含义是将map传入到页面里面，然后将值替换掉。

#### 一些问题

和教程不同，我一直是将新代码加到上一个代码的项目之中，而非开新的项目。当前的这个教程，即2-3，其`pom.xml` 之中的 Dependencies 有两项要删除，分别为：

```
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>jstl</artifactId>
		</dependency>
		<dependency>
			<groupId>org.apache.tomcat.embed</groupId>
			<artifactId>tomcat-embed-jasper</artifactId>
		</dependency>
```



实测这两项加入之后，无论怎样调整，都会显示`Whitelabel Error Page`，个人认为这两项和Thymeleaf不兼容，会拦截所有想要导向`\templates\hello.html` 的请求，并且将其转到请求`\WEB-INF\jsp\hello.jsp`,从而导致 Whitelabel 的错误。顺带说一句，教程2-2之中的解决`Whitelabel Error Page` 的方法在这里不起作用。



#### 对于@Controller 和 @RestController 的解析

下面是对于@Controller和@RestController的区别解析，由于在自己输入代码的过程之中将二者混淆，导致最后结果不太对，这个地方要明确注意一下。

首先是官方文档的解释：@RestController注解相当于@ResponseBody ＋ @Controller合在一起的作用。

但是在使用的过程之中有一些出入：

1. 如果只是使用@RestController注解Controller，那么Controller之中的方法就无法返回对应的 JSP 页面，也就是其配置的InternalResourceViewResolver不起作用，那么返回的就是Return里面的内容。也就是本来应该到`success.jsp`页面的，结果只显示“success”
2. 如果想要返回到指定页面，需要使用@Controller配合视图解析器InternalResourceViewResolver才可以
3. 如果需要返回JSON，XML或者自定义MediaType内容到页面，需要在对应的方法上面加上 @ResponseBody

### 常用语法

##### 赋值，字符串拼接

赋值：

`<p th:text=${username}>Username</p>`

`<span th:text="'Welcome to our application'+${username}+'!'"></span>`

字符串拼接还有另一种简洁的方法：

`<span th:text="|Welcome to our application,${username}!|"></span>`



下面是`\templates\string.html`:

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Example String</title>
</head>
<body>
    <div>
        <h1>text</h1>
        <p th:text="${username}">Username</p>
        <span th:text="'Welcome to our application'+${username}+'!'"></span>
        <br/>
        <span th:text="|Welcome to our application,${username}!|"></span>
    </div>
</body>
</html>
```

后端传值：

```java
@Controller
public class ExampleController {
    @RequestMapping("/string")
    public String string(ModelMap map)
    {
        map.addAttribute("username", "Mint");
        return "string";
    }
}

```



和之前一样，使用ModelMap以KV的形式传到页面。

直接在 IDEA 里面打开的结果显示:

> # text
>
> Username

而在网页之中传递得到的结果是:

> # text
>
> Mint
>
> Welcome to our applicationMint!
>
> Welcome to our application,Mint!



### 条件判断If/Unless

在 Thymeleaf 之中，使用 th:if 和 th:unless 进行判断，在下面例子之中， `<a>` 标签只有在 th:if 成立时才显示， 而只有在 th:unless 不成立时才显示。



if.html 的代码：

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Example If/Unless</title>
</head>
<body>
<div>
    <h1>If/Unless</h1>
    <a th:if="${flag=='yes'}" th:href="@{https://timzhouyes.github.io}">home</a>
    <br/>
    <a th:unless="${flag!='no'}" th:href="@{https://google.com}">unless test</a>
</div>

</body>
</html>
```



后端传值Controller部分：

```java
    @RequestMapping("/if")
    public String ifunless(ModelMap map)
    {
        map.addAttribute("flag","yes");
        return "if";
    }
```

也是使用KV方式传值到页面。

 该代码效果为只显示“home”， 不显示其他。



##### for循环

For 循环一般结合前端的表格使用。

首先在后端定义一个用户列表，注意此处需要首先在model 的 User 里面加入一个 constructor：

```java
    public User(String name, int age, String pass) {
        this.name = name;
        this.age = age;
        this.pass = pass;
    }
```

这样就不必一次次的调用 setName 等等。



再定义一个用户列表：

```java
    private List<User> getUserList(){
        List<User> list=new ArrayList<User>();
        User user1=new User("A1",13,"1234567");
        User user2=new User("A2",14,"4321234");
        User user3=new User("A3",19,"0933211");
        list.add(user1);
        list.add(user2);
        list.add(user3);
        return list;
    }
```



按照键 users ，传递到前端：

```java
    @RequestMapping("/list")
    public String list(ModelMap map)
    {
        map.addAttribute("users",getUserList());
        return "list";
    }
```

页面 `list.html` 进行数据展示：

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Example For test</title>
</head>
<body>
<div>
    <h1>for loop testing</h1>
    <table>
        <tr th:each="user,iterStat:${users}">
            <td th:text="${user.name}">Neo</td>
            <td th:text="${user.age}">19</td>
            <td th:text="${user.pass}">6666666</td>
            <td th:text="${iterStat.index}">index</td>
        </tr>
    </table>
</div>

</body>
</html>
```

其中的`iterStat` 称为状态变量，属性有：

- index: 当前迭代对象的index,从0计算。
- count: 当前迭代对象的index ，从1计算。
- size:被迭代对象的大小。
- current：当前迭代变量，我的变量是`com.neo.hello.model.User@703cd7ff`
- even/odd: 布尔值，当前循环是否是偶数/奇数。
- first: 布尔值，当前循环是否是第一个
- last: 布尔值，当前循环是否是最后一个

### URL

Thymeleaf对于URL的处理是通过语法@{...} 来处理的。如果需要 Thymeleaf 对于URL 进行渲染，务必使用 th:href, th:src 等属性，下面是一个例子：

此处的URL经过传值进入：

##### `url.html`

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Example URL</title>
</head>
<body>
<div>
    <h1>URL</h1>
    <a th:href="@{http://www.ityouknow.com/{type}(type=${type})}">link1</a>
    <br/>
    <a th:href="@{http://www.ityouknow.com/{pageId}/can-use-springcloud.html(pageId=${pageId})}">view</a>
    <br/>
    <div th:style="'background:url(' + @{${img}} + ');'">
        <br/><br/><br/>
    </div>
</div>

</body>
</html>
```



##### 后端程序

```java
    @RequestMapping("/url")
    public String url(ModelMap map)
    {
        map.addAttribute("type","link");
        map.addAttribute("pageId","springcloud/2017/09/11/");
        map.addAttribute("img","http://www.ityouknow.com/assets/images/neo.jpg");
        return "url";
    }
```



### 三目运算

```
<input th:value="${name}"/>
<input th:value="${age gt 30 ? '中年':'年轻'}"/>
```

下面这个语句是年龄>30 显示中年， 年龄 < 30 显示年轻。

- gt: greater than （大于）
- ge: great equal （大于等于）
- eq: equal （等于）
- lt： less than （小于）
- le: less equal (小于等于)
- ne:not equal (不等于)



##### 完整的页面内容 `eq.html`

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>ternary operator</title>
</head>
<body>
<div>
    <h1>EQ</h1>
    <input th:value="${name}"/>
    <br/>
    <input th:value="${age gt 30 ? 'Old':'young'}"/>
    <br/>
    <a th:if="${flag eq 'yes'}" th:href="@{https://google.com}">Google</a>
</div>

</body>
</html>
```

##### 后端程序

```java
    @RequestMapping("/Sanmu")
    public String Sanmu(ModelMap map)
    {
        map.addAttribute("name","neo");
        map.addAttribute("age",90);
        map.addAttribute("flag","yes");
        return "eq";
    }
```

注意此处我的 @RequestMapping 和 最后返回的名字并不相同，前者是浏览器之中的URL， 后者是在`\templates` 之中的` eq.html`



### Switch选择

switch/case 的情况用于多条件判断，还记得之前我们说JSTL里面的 <c:if >只要判断条件满足就立刻退出判断吗？



##### HTML 代码

```HTML
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Switch test</title>
</head>
<body>
<div>
    <div th:switch="${sex}">
    <p th:case="'woman'">She is a girl</p>
        <p th:case="'man'">He is a boy</p>
        <p th:case="*">The one with no sex</p>
    </div>
</div>
</body>
</html>
```

- 此处的 `th:case="*" `是case的缺省项，在上面两项不同的情况下默认找到这个选项。



##### Controller代码

```java
    @RequestMapping("/switch")
    public String Switch(ModelMap map){
        map.addAttribute("sex","woman1");
        return "switch";
    }
```

- 输出为“The one with no sex"



### 第2-4课：模板引擎Thymeleaf高阶用法



#### 内联[[]]

Thymeleaf之中的内联能够使人们写更少的代码，也可以用于在javascript代码块之中访问model的数据。

内联的使用方法：[[...]] 是内联文本的表示方式，在使用之前必须通过 `th:inline="text"` 或者 `th:inline="javascript"`来激活，如果使用`th:inline="none"`，其意味着不使用inline，因为某些情况下我们需要输出`[[]]` 这种符号，那么就要提前写上 `th:inline=”none"`来防止其被识别为内联。

`th:inline`可以在父级标签之中使用，甚至可以作为 body 的标签 。内联文本比 `th:text`的代码少，相对而言不利于展示。

##### Html template code:

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Inline example</title>
</head>
<body>
<div>
    <h1>内联</h1>
    <div th:inline="text">
        <p>Hello,[[${username}]]!</p>
        <br/>
    </div>
    <div>
        <h1>不使用内联</h1>
        <p th:text="'hello,'+${username}+'!'"></p>
        <br/>
    </div>
</div>

</body>
<script th:inline="javascript">
    var name=[[${username}]]+', Sebasitian';
    alert(name);
</script>
</html>
```

- 内联：要先在标签之内激活，然后下面的标签之中便不需要重新`<th:text= >`,可以直接写变量。
- 要是想在script之中使用后端传入的值，则必须写内联，脚本内联可以在 js 之中收到后台传过来的参数。其内联参数为 `th：inline="javascript"`





#### 基本对象

Thymeleaf 包含了了⼀一些基本对象，可以⽤用于我们的视图中，这些基本对象使⽤用 # 开头。
  - #ctx ：上下文对象
  - #vars ：上下文变量
  - #locale ：区域对象
  - #request ：（仅 Web 环境可用）HttpServletRequest 对象
  - #response ：（仅 Web 环境可用）HttpServletResponse 对象
  - #session ：（仅 Web 环境可用）HttpSession 对象
  - #servletContext ：（仅 Web 环境可用）ServletContext 对象



下面对于`#request` ，`#session`和`#locale` 做一点介绍。

##### HTML页面

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">

<head>
    <meta charset="UTF-8">
    <title>Basic Object</title>
</head>
<body>
<div>
    <h1>基本对象</h1>
    <p th:text="${#request.getAttribute('request')}">
    <br/>
    <p th:text="${session.session}"></p>
    Established locale country:<span th:text="${#locale.country}">SIN</span>

</div>

</body>
</html>
```

以上我们可以看到：

- request 的值使用 getAttribute 来得到
- session 的值可以直接取到
- locale 指区域对象（没错，是地理区域）。在前端看本页面显示"Established locale country:SIN"， 但是程序之中显示的是"Established locale country:CN"。说明这个变量读取的是地理区域。





##### 内嵌变量

插一嘴时间格式的问题：

- yyyy：年份
- MM：月份
- dd：日期
- HH：24小时制
- hh：12小时制，当在0-12之间时候显示正常，在13-24之间显示的是（原值-12)，即如果是14：00：00则显示为2：00：00
- mm：分钟，注意和上面那个月份之间的区别
- ss：秒



为了使模板更易用，Thymeleaf还内置了一系列Utility对象，内置于context之中，可以通过#直接访问。

下面举一些使用日期和字符串的方法：

##### 页面

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Utility Example</title>
</head>
<body>
<h1>时间相关</h1>
格式化时间
<p th:text="${#dates.format(date,'yyyy-MM-dd HH:mm:ss')}">neo</p>
创建时间精确到天
<p th:text="${#dates.createToday()}">neo</p>
创建时间 精确到秒
<p th:text="${#dates.createNow()}">neo</p>
<h1>字符串相关</h1>
判断字符串是否为空
<p th:text="${#strings.isEmpty(username)}">username</p>
判断list是否为空
<p th:text="${#strings.listIsEmpty(users)}">username</p>
输出字符串长度
<p th:text="${#strings.length(username)}">username</p>
拼接字符串
<p th:text="${#strings.concat(username,username)}">username+username</p>
创建自定义长度的字符串
<p th:text="${#strings.randomAlphanumeric(count)}">username</p>
</body>
</html>
```



##### 后端传值

```java
    @RequestMapping("/utility")
    public String utility(ModelMap map)
    {
        map.addAttribute("date",new Date());
        map.addAttribute("username", "Neoolee");
        map.addAttribute("users", getUserList());
        map.addAttribute("count", 12);
        return "utility";
    }
```



### 表达式

表达式一共分为五类：

- 变量表达式：${...} :

变量表达式即spring EL 表达式，类似${session.user.name} 。其也是含有变量的值的表达式。

其一般以HTML标签的一个属性来表示，即

```html
<span th:text="${book.author.name}">
<li th:each="book : ${books}">
```

- 选择或星号表达式：*{...}

选择表达式与变量表达式不同，其用一个预先选择的对象来代替上下文变量容器(map)来执行。类似`*{customer.name}`

被指定的object由`th:object`来定义：此处title即为book的属性。

```html
<div th:object="${book}">
...
<span th:text="*{title}">...</span>
...
</div>
```

- 文字国际化表达式

文字国际化表达式是根据不同的国家地区可以显示不同页面内容的方法。其可以从一个外部文件获得区域文字信息，然后用key索引value，还可以提供一组可选的参数。

```html
<table>
...
<th th:text="#{header.address.city}">...</th>
<th th:text="#{header.address.country}">...</th>
...
</table>
```

- URL表达式

URL表达式在需要将某些信息重写回URL的时候使用。例如`@{/order/list}`

URL还可以设置参数： `@{/order/details(id=${orderId})}`

可以设置相对路径：`@{.../documents/report}`

```html
<form th:action="@{/createOrder}">
<a href="main.html" th:href="@{/main}">
```

- 片段表达式

片段表达式是一种将其他片段做标记，然后将其移动到模板之中的方法。其优势是可以被复制或者作为参数传递到其他模板。片段表达式可以有参数。

最常见的方法是使用`th:insert` 或者 `th:replace` 插入片段。

`<div th:insert="~{commons :: main}">...</div>`

也可以在页面的其他位置使用：

```html
<div th:with="frag=~{footer :: #main/text()}">
	<p th:insert="${frag}">
</div>
```

- 变量表达式和星号表达式有什么区别？

如果不考虑上下文的情况下，两者之间没有区别。星号语法是在选定对象上表达，而不是整个上下文。选定对象指的是父标签的值。例如：

```html
<div th:object="${session.user}">
<p>Name: <span th:text="*{firstName}">Sebastian</span>.</p>
<p>Surname: <span th:text="*{lastName}">Pepper</span>.</p>
<p>Nationality: <span th:text="*{nationality}">Saturn</span>.</p>
</div>
```

和下面这一段完全等价：

```html
<div th:object="${session.user}">
<p>Name: <span th:text="${session.user.firstName}">Sebastian</span>.</p>
<p>Surname: <span th:text="${session.user.lastName}">Pepper</span>.</p>
<p>Nationality: <span th:text="${session.user.nationality}">Saturn</span>.</p>
</div>
```



# 第2-5课：Thymeleaf页面布局

**提示：从本课开始，博客内容不再是原有内容的精华部分，而是博主个人在编程时候遇到的难点或者疑问点。因此不会再有大段代码或者完整程序。**



页面布局指的是对前端的页面进行划分区域，每个区域有自己不同的职责。布局是为了更好的重复利用前端代码，避免大量的重复性的劳动。在现有的前端之中，页面布局成为了前端开发的最重要的工作之一。Thymeleaf的相关语法可以很容易的实现对前端页面布局。

个人理解，其意味着将整个页面划分成及部分，例如页眉，页脚等等，然后针对每部分进行自己的操作，相当于将整个页面模块化，可以起到更好的效果。

### 快速入手

- `th:insert` 和`th:replace` 区别：前者仅仅是加载，后者是替换。Thymeleaf 3.0 之中建议使用`th:insert` 来替换`th:replace`

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org"><head>
    <meta charset="UTF-8">
    <title>The main page</title>
</head>
<body>
    <div th:insert="layout/copyright::copyright"></div>
    <div th:replace="layout/copyright::copyright"></div>
</body>
</html>
```

这段代码使用了两种形式来做copyright的插入，其中定位信息如下：

- layout/copyright 是文件位置，copyright 的内容意义为在copyright 文件之中的<copyright>标签之中的内容。所以上面这段代码是将<copyright> 里面的内容重复两次。



#### 片段表达式

片段表达式，支持在一个网页之中写fragment，在另一个网页之中引用并使用类似于`~{commons::footer}` 的传值方法，并且将其作用在`th:insert`或者`th:replace`的内部。

代码模板：

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head th:fragment="common_header(title,links)">
    <title th:replace="${title}">common title</title>
    <link rel="stylesheet" type="text/css" media="all" th:href="@{/css/myapp.css}">
    <link rel="shortcut icon" th:href="@{/images/favicon.ico}">
    <script type="type/javascript" th:src="@{/js/myapp.js}"></script>
    <th:block th:replace="${links}"/>
</head>
<body>

</body>
</html>
```

- 其中使用`common_header` 是名称，支持传入两个参数title和links。指明了使用位置是：
  - `<title th:replace="${title}">common title</title>` 将使用模板的网页的title传入其中
  - `<th:block th:replace="${links}"/>`将使用模板的网页的link（也就是使用<link >标签的）传入其中，而 th:block 作为页面的自定义使用不会展示到页面之中。实际而言，`<th:block>` 所包含的是代码块。 

##### 使用模板的代码

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head th:replace="base::common_header(~{::title},~{::link})">
    <title>Fragment-Page</title>
    <link rel="stylesheet" th:href="@{/css/bootstrap.min.css}">
    <link rel="stylesheet" th:href="@{/cs/fragmen.css}">

</head>
<body>

</body>
</html>
```

这段代码，在head处直接写入了一个`th:replace`，将`base` 文件之中的`common_header`放进本页面的头文件之中。又在下面指出了所有值，包括title和link，所以在最后的html里面，查看源代码，其显示为：

```html

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Fragment-Page</title>
    <link rel="stylesheet" type="text/css" media="all" href="/css/myapp.css">
    <link rel="shortcut icon" href="/images/favicon.ico">
    <script type="type/javascript" src="/js/myapp.js"></script>
    <link rel="stylesheet" href="/css/bootstrap.min.css"><link rel="stylesheet" href="/cs/fragmen.css">
</head>
<body>

</body>
</html>
```

可见其就是将 title 和 两个 link 填充到上面的模板之中所形成的文件。这样就完成了一个网页的模板填充。

这是片段表达式最常使用的方式之一，也是3.0版本之中针对页面布局推出的新语法。

##### 页面布局

我们在 templates/layout 下面新建页面 footer.html , header.html , left.html 页面，内容如下:（以footer.html 举例）

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org"><head>
<head>
    <meta charset="UTF-8">
    <title>footer</title>
</head>
<body>
    <footer th:fragment="footer">
        <h1> I am footer of HTML</h1>
    </footer>
</body>
</html>
```

可见这里面我们自己定义了一个<footer> 的标签，一样的，我们在另外几个 HTML 之中也新建几个和名字对应的标签。

新建一个使用所有模板的模板：

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org" xmlns:layout="http://www.ultraq.net.nz/web/thymeleaf/layout">
<head>
    <head>
        <meta charset="UTF-8">
        <title>Total layout</title>
    </head>
<body>
<div>
    <div th:replace="layout/header::header"></div>
    <div th:replace="layout/left::left"></div>
    <div layout:fragment="content">content</div>
    <div th:replace="layout/footer::footer"></div>
</div>
</body>
</html>
```

注意这段代码，在我们之前的命名空间基础之上加入了新的语法命名空间：`xmlns:layout="http://www.ultraq.net.nz/web/thymeleaf/layout"` 。而且我们在这个命名空间的下面重新定义了一个content，作为后期要替换的内容。

新建一个 layout.html 使用模板：

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org"
      xmlns:layout="http://www.ultraq.net.nz/web/thymeleaf/layout" layout:decorate="layout">
<head>
    <head>
        <meta charset="UTF-8">
        <title>Home site to test1</title>
    </head>
<body>
<div layout:fragment="content">
    Self content done by myself
</div>
</body>
</html>
```



- html 标签之中的 `layout:decorate="layout"` 是在之前基础上新增加的，意味使用`layout.html`这个模板文件之中的布局。
- `<div layout:fragment="content">` 意为将下面内容替换 `layout.html` 之中的 content 代码片段。

采用页面布局的时候有两个关键设置，一个是在模板之中定义需要替换的部分 `layout:fragment="content"` 另一个是在**需要引入模板的页面头** 之中写 `layout:decorate="layout"`，再修改其中的内容。

# 第2-6课：使用Spring Boot 和 Thymeleaf 演示上传文件

Spring boot 使用了 MultipartFile 的特性来接收和处理上传的文件， MultipartFile 是 Spring 的一个封装接口，封装了文件上传的相关操作，利用 MultipartFile 可以很方便的接受前端文件，并存储其到本机或者其他中间件之中。

启动类之中要加入以下代码，不然上传文件超过10M 会出现问题。而此处将其设置为(-1) 可以避免连接重置（因为文件大小没有限制了）。这个异常内容 GlobalException 捕获不到。只会显示 ERR_Connection_Reset

```java
package com.neo.hello;

import org.apache.coyote.http11.AbstractHttp11Protocol;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.embedded.tomcat.TomcatConnectorCustomizer;
import org.springframework.boot.web.embedded.tomcat.TomcatReactiveWebServerFactory;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class HelloApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloApplication.class, args);
    }

    //Tomcat large file upload connection reset
    @Bean
    public TomcatServletWebServerFactory tomcatEmbedded() {
        TomcatServletWebServerFactory tomcat = new TomcatServletWebServerFactory();
        tomcat.addConnectorCustomizers((TomcatConnectorCustomizer) connector -> {
            if ((connector.getProtocolHandler() instanceof AbstractHttp11Protocol<?>)) {
                    //-1 means unlimited
                ((AbstractHttp11Protocol<?>) connector.getProtocolHandler()).setMaxSwallowSize(-1);
            }
        });
        return tomcat;
    }

}

```

其结构为：

前端由两个页面组成，一个负责上传文件，一个负责返回传输状态。

后端有两部分，一部分用来做 RequestMapping ,包括数据的传输和页面判断，另一部分使用 @ControllerAdvice 做ExceptionHandling，将Exception信息使用redirectAttribute() 传输到“传输状态” 页面。