---
layout:     post   				    # 使用的布局（不需要改）
title:      《Spring Boot 42讲》学习笔记（2） 				# 标题 
subtitle:   构建基本项目与Spring之中annotation的浅析  #副标题
date:       2019-04-24				# 时间
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



# 第2-1课：Spring Boot对基础Web开发的支持（上）



Spring Boot对于Web的开发的支持很全面，包括开发，测试和部署都有支持。Spring-boot-starter-wew是spring Boot对于Web开发提供支持的组件，其主要包括RESTful，参数校验，使用Tomcat作为内嵌容器。下面是介绍:



#### JSON的支持



JSON(JavaScript Object Notation) 是一种轻量级的数据交换格式，易于阅读和编写。JSON的出现，改变了早期人们使用XML进行数据交互的方式。在现在的Spring Boot之中，在Web层的使用只需要加入一个注解就可以。



在`pom.xml` 之中加入以下代码：



```xml
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-web</artifactId>
</dependency>
```



> 在本教程中，“根目录”所指为Main()所在程序的目录。



Tip：this指代的是当前class之中的变量，所以善用this可以在getter和setter之中省去命名新变量。如下所示：



```java
    public void setName(String name){
        this.name=name;
    }
```



上面的代码就实现了将method之中的name赋值给class之中的`private String name` 的作用。



在根目录下面新建一个model的包，然后在包的下面新建一个实体类User，其信息如下：



```java
public class User {
    private String name;
    private int age;
    private String pass;
    //Getter和Setter可以通过IDE自动生成
```



在项目之中新建一个Web包，且在Web下面新建一个类WebController，类之中创建一个方法返回User，如下：



```java
@RequestMapping(name="/getUser",method= RequestMethod.POST)
    public User getUser(){
        User user=new User();
        user.setName("mint");
        user.setAge(19);
        user.setPass("123456");
        return user;
    }
```





-  `@RestController`的注解相当于将`@ResponseBody`+`@Controller`合在一起使用，使用`@RestController`注解之后，代表整个类都会以JSON方式返回结果。
- `@RequestMapping(name="/getUser",method= RequestMethod.POST)`这句设置了路由“/getUser”之中的返回值，而其中的`method=RequestMethod.POST` 意为只有Post的请求方式是被允许的，如果使用Get的方式，那么会报405不允许访问的错误。错误信息如下：





```html
There was an unexpected error (type=Method Not Allowed, status=405).
Request method 'GET' not supported
org.springframework.web.HttpRequestMethodNotSupportedException: Request method 'GET' not supported
```





- 个人Tip：在这里我试了将上面的语句之中的`name="/getUser"` 改成`name="/getUser123"` ,之后发现在Postman测试时，使用POST方法访问，两个URL都可以获得信息。



#### 测试代码



在test之中新建WebController测试类，对getUser()方法进行测试：



```java
@SpringBootTest
public class WebControllerTest {
    private MockMvc mockMvc;

    @Before
    public void setUp() throws Exception{
        mockMvc= MockMvcBuilders.standaloneSetup(new WebController()).build();
    }

    @Test
    public void getUser() throws Exception{
        String responseString=mockMvc.perform(MockMvcRequestBuilders.post("/getUser")).andReturn().getResponse().getContentAsString();
        System.out.println("result:"+responseString);
    }
}
```



- @Before  之中的作用和之前一样，都是先让程序跑起来，建立测试环境。
- @Test 之中的 `andReturn().getResponse().getContentAsString()` 意为得到相应之后将其转换成String。



#### 返回一个JSON List

下面是将一个由User组成的List返回的方法：



首先，将WebController之中添加getUsers(),代码如下：



```java
    @RequestMapping(value="/getUsers")
    public List<User> getUsers(){
        List<User> users =new ArrayList<User>();
        User user1=new User();
        user1.setName("mint1");
        user1.setAge(19);
        user1.setPass("123456");
        users.add(user1);
        User user2=new User();
        user2.setName("mint3");
        user2.setAge(192);
        user2.setPass("1234516");
        users.add(user2);
        return users;
    }

```



然后添加测试方法：



```java
    @Test
    public void getUsers() throws Exception{
        String responseString=mockMvc.perform(MockMvcRequestBuilders.get("/getUsers")).andReturn().getResponse().getContentAsString();
        System.out.println("result"+responseString);
    }
```



注意，测试方法之中省去了 @Before 的部分。



### 个人提醒

@RequestMapping 的 name 属性几乎没用，想要限定 route 的路径需要使用 value 属性。 具体可以看我在StackOverflow 上面的提问：[Confusion for @RequestMapping solving one value and a list values](https://stackoverflow.com/questions/55844721/confusion-for-requestmapping-solving-one-value-and-a-list-values)





# 第2-1课：Spring Boot对基础Web开发的支持（下）



#### 数据校验



很多时候在处理应用的业务逻辑时，要考虑数据校验的问题。程序必须保证送进来的数据是正确的。



在Spring MVC之中有两种方式可以验证输入，一种是Spring自带的验证框架，另一种是利用JSR实现。



**JSR**（Java规范请求，*Java Specification Requests*），指定了一整套API，通过标注给对象添加约束。Hibernate Validator 就是 JSR 规范的具体实现。 Spring Boot的参数校验依赖于hibernate validator来进行，使用其校验数据，需要定义一个接收的数据模型，使用注解的形式描述字段校验的规则。



下面以User为对象演示如何使用。



首先在WebController之中添加一个saveUser的方法，参数为User



```java
    @RequestMapping("/saveUser")
    public void saveUser (@Valid User user, BindingResult result) {
        System.out.println("user:" + user);
        if (result.hasErrors()) {
            List<ObjectError> list = result.getAllErrors();
            for (ObjectError error : list) {
                System.out.println(error.getCode() + "-" + error.getDefaultMessage());
            }
        }
    }
```



- `@Valid` ：在 User 前面添加了 @Valid 的 annotation， 代表这个对象经过了参数校验。
- `BindingResult` 参数校验的结果会存在这个对象之中，可以根据属性判断是否校验通过，若没有通过，就将错误信息打印出来。



下面是添加了 annotation 之后的注解， 对不同的属性，添加不同的内容： 



```java
public class User {
    @NotEmpty(message="Name can not be null!")
    private String name;
    @Max(value=200,message = "Age can not larger than 200")
    @Min(value=18,message="You have to be adult!")
    private int age;
    @NotEmpty(message = "Password can not be null")
    @Length(min = 6,message = "Password can not shorter than 6 characters")
    private String pass;
//……
}
```



所有的 message 之中的信息，都是自己定义的错误提示信息



下面是测试方法：



```java
    @Test
    public void saveUsers() throws Exception{
        mockMvc.perform(MockMvcRequestBuilders.post("/saveUser").param("name","").param("age","666").param("pass","abcd"));

    }
```



测试得到的返回值如下，注意此处的 user 的返回值和教程不同。



```
user:com.neo.hello.model.User@619bfe29
Length-Password can not shorter than 6 characters
NotEmpty-Name can not be null!
Max-Age can not larger than 200
```



- 个人测试：如果在测试之中，将 age 的传入参数改为 “asd", 会在 Age 的限定处返回：



`typeMismatch-Failed to convert property value of type 'java.lang.String' to required type 'int' for property 'age'; nested exception is java.lang.NumberFormatException: For input string: "asd"`



### 自定义Filter



Filter。过滤器，可以在前端拦截用户的请求。Web开发者通过Filter技术，可以对Web服务器管理的所有Web资源，例如JSP，Servlet，静态图片文件或者HTML文件进行拦截，从而实现某些特殊的功能：URL级别的权限访问限制，过滤敏感词汇，排除有XSS威胁的字符，记录请求日志等等。



Spring Boot有内置的Filter,也支持我们通过自己的需求来自定义Filter。



自定义Filter有两种方式，一种是使用@WebFilter，第二种是使用FilterRegistrtionBean. 教程之中不推荐第一种，因为其实践之后发现 @WebFilter 自定义的优先级顺序不能生效， 因此推荐第二个方案。 



使用FilterRegistrationBean自定义过滤器的方案如下:

- 实现Filter接口，实现其中的doFilter()方法
- 添加@Configuration注解，将自定义Filter加入过滤链。



此处需要加以注意，我在Filter之中加入了`java.util.logging.Filter;`这个引用，可能是由于IDEA自动加入的，但是这个引用导致了我在程序之中的`@Override` 全部提示错误。查阅资料之后发现，这个引用的作用为将Log之中的内容做过滤筛选，这自然不是我们想要的。使用IDEA的时候要注意这一点。下面这段代码，我把引用部分加上了，除了这三个之外的自动补全要小心。



```java
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

public class MyFilter implements Filter {

    @Override
    public void init(FilterConfig arg0) throws ServletException {
        // TODO Auto-generated method stub
    }

    @Override
    public void doFilter(ServletRequest srequest, ServletResponse sresponse, FilterChain filterChain) throws IOException, ServletException
    {
        HttpServletRequest request=(HttpServletRequest) srequest;
        System.out.println(("this is my Filter, url:"+request.getRequestURI()));
        filterChain.doFilter(srequest, sresponse);
    }
    
    @Override
    public void destroy(){
        //// TODO: 4/26/2019
    }
}
```



将自定义的Filter加入过滤链：



```java
@Configuration
public class WebConfiguration {
    @Bean
    public FilterRegistrationBean testFliterRegisteration(){

        FilterRegistrationBean registration=new FilterRegistrationBean();
        registration.setFilter(new MyFilter());
        registration.addUrlPatterns("/*");
        registration.setName("MyFilter");
        registration.setOrder(6);
        return registration;
    }

    @Bean
    public FilterRegistrationBean test2FilterRegisteration(){
        FilterRegistrationBean registration = new FilterRegistrationBean();
        registration.setFilter(new MyFilter2());
        registration.addUrlPatterns("/*");
        registration.setName("MyFilter2");
        registration.setOrder(1);
        return registration;
    }
}
```





注意下面的代码是加入了两个Filter，其中Filter2 的构造和Filter一样，只是将名字改换一下而已。其中的`registration.setOrder()` 命令是设置Filter的过滤顺序，值越小说明越先过滤。



下面是输出的结果：



```
this is my Filter222222, url:/getUsers
this is my Filter, url:/getUsers
this is my Filter222222, url:/favicon.ico
this is my Filter, url:/favicon.ico
```



可见在console之中输出的结果，Filter2在Filter之前。说明我们顺序的设置是起作用的。



### 配置文件

配置文件，在我看来就是整个文件的全局变量，是一开始就被初始化写到整个程序里面的内容。下面是如何使用`resources/application.properties` 之中的变量来传值的步骤：



注意，等号右边哪怕是String，也不要加双引号。不然会报错。



```
neo.hello.title=Zhou Haiming
neo.hello.description=Do is better than say

```



在test 下面加入一个PropertiesTest的class：



```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class PropertiesTest {
    @Value("${neo.hello.title}")
    private String title;

    @Test
    public void testSingle(){
        Assert.assertEquals(title, "Zhou Haiming");
//        System.out.println("title "+ title);
    }
}

```



可见在这个Test之中可以将`application.properties` 之中的值放到title里面，下面直接进行验证。



```java
    @Test
    public void testMore() throws Exception{
        System.out.println("title:"+ properties.getTitle());
        System.out.println("description:"+properties.getDescription());
    }
```



注意在此之前要

```java
    @Resource
    private NeoProperties properties;
```



### 自定义配置文件

有的时候需要自定义配置文件，用来和application.properties 区分开。下面是自定义配置文件的做法：

注意：此处说的自定义配置文件指的是新建properties文件，和上面的`NeoProperties`用来一次性导入多个`application.properties` 的使用方法不同。

在resources目录下面新建一个`other.properties` 文件，内容如下：

```
other.title=keep smile
other.blog=timzhouyes.github.io
```



定义`OtherProperties` 类来接受配置文件的内容：



```java
@Component
@ConfigurationProperties(prefix="other")
@PropertySource("classpath:other.properties")
public class OtherProperties {
    private String title;
    private String blog;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBlog() {
        return blog;
    }

    public void setBlog(String blog) {
        this.blog = blog;
    }
}
```

- 要注意，此处多了一个`@PropertySource("classpath:other.properties")`,用来指定我们的配置文件的位置。



#### 添加测试

```java
    @Resource
    private OtherProperties otherProperties;
	…………
	
	@Test
    public void testOther() throws Exception{
        System.out.println("title:"+ otherProperties.getTitle());
        System.out.println("blog:"+otherProperties.getBlog());
    }
```



最终结果之中输出结果即表明自定义的配置文件传值成功。





### Spring之中annotation的浅析



在编程过程之中发现自己对于一些annotation的问题还不够清晰，下面是对于`@Component`， `@Repository`，`@Controller` ， `@Service` 的浅析



> **相似点**
>
> 对于BeanDefination之中的scan-auto-detection和dependency injection，这些annotation都是一样的，都可以被扫描并注入。
>
> 
>
> 
>
> **不同点**
>
> **@Component**
>
> 只是一个Component的标准注解。其特殊点在于：
>
> `<context:component-scan>`只是扫描`@Component`，不寻找其他的annotation。
>
> 
>
> 
>
> **@Repository**
>
> 用于表明当前类定义了一个data repository
>
> @Repository是抓取平台的特殊exception并且将它们当作Spring的统一的unchecker exception 给re-throw出来。
>
> 
>
> 
>
> **@Controller**
>
> @Controller 表明了一个特殊的类承担着controller的职责。
>
> @Controller不可以和其他的annotation，例如 @Service 和 @Repository 互换，因为调度程序会扫描所有的 @Controller 并且扫描其中的 @RequestMapping 注解。我们只可以在 @Controller 之中使用 @RequestMapping 注解。
>
> 
>
> 
>
> **@Service**
>
> @Service  之中有 business logic ， 并且可以call在 Repository layer的method。
>
> 个人认为，@Service 是一个**无状态的的可重用的对象**。 



# 第2-2课：Spring Boot项目中使用JSP



JSP(Java Server Pages)， Java服务器页面，其根本是一个简化的Servlet设计。其是由Sun Microsystems公司倡导，许多公司一起建立的一种动态网页技术标准。

JSP技术类似ASP技术，是在传统的HTML文件(.html) 之中插入Java程序段(Scriptlet)和 JSP tag 形成的 JSP 文件。

JSP实际上就是Java为了支持Web开发推出的类前端Servlet，可以在 JSP 之中写 Java 或者 Html语法等等，后端根据 JSP 语法渲染后返回到前端进行显示。


### 1. 快速上手



其与上一版目录的区别在于java目录下多了一个webapp 的文件夹，用于存放目录 JSP 文件。

首先在`application.properties` 之中添加两个配置行



```
spring.mvc.view.prefix=/WEB-INF/jsp/
spring.mvc.view.suffix=.jsp
```

- 其中`spring.mvc.view.prefix`代表的是jsp文件在webapp下面的哪个目录
- `spring.mvc.view.suffix`指明jsp文件以什么后缀结尾



#### 引入依赖包

在pom里面加入依赖：

```
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>jstl</artifactId>
		</dependency>
		<dependency>
			<groupId>org.apache.tomcat.embed</groupId>
			<artifactId>tomcat-embed-jasper</artifactId>
		</dependency>
```



- `spring-boot-starter-web`依赖了`spring-boot-starter-tomcat`, 所以Tomcat不需要再单独配置

- JSTL： 一个 JSP标签集合， 封装了 JSP 应用的通用核心功能

- `tomcat-embed-jasper` 用来支持 JSP 的解析和运行

#### 编写页面

在`welcome.jsp` 里面编写一个页面：



```html
<!DOCTYPE html>
<html lang="en">
    <body>
        Time: ${time}
        <br>
        Message: ${message}
    </body>
</html>
```



页面功能极其简单，就是展示后端传过来的时间和信息。



#### 后端程序



```java
@Controller
public class WelcomeController {

    @GetMapping("/")
    public String welcome(Map<String,Object> model)
    {
        model.put("time", new Date());
        model.put("message", "hello world");
        return "welcome";
    }
}
```



其作用为将时间和信息作为key-value对放入程序之中并返回。



### 2. 常用示例

页面常用的展示后端传值，if判断，循环等功能，可以使用 jstl 语法进行处理，也可以直接写 Java 代码实现这些逻辑。 JSP 页面之中两种方式都支持， 但是不建议在 JSP 之中写入大量的 Java 代码，从而导致前端业务复杂，可读性差等等问题。

在`WelcomeController` 之中定义一个 user() 的方法，将一些值传到前端：

```java
    @GetMapping("/user")
    public String user(Map<String,Object> model, HttpServletRequest request)
    {
        model.put("username", "neo");
        model.put("salary", 3000);
        request.getSession().setAttribute("count",6);
        return "user";
    }
```



将参数和值以 Key-Value 的形式存储在 Map 里面， JSP页面可以直接根据属性名来获取值（前两个的`model.put`)，也可以使用`request` 来传递后端属性和值， 返回值会以 Key-Value 的格式传递到 `user.jsp` 页面。

在`user.jsp`开头添加两个标签：

```
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><html lang="en">
```

- 第一个是在网页之中支持中文显示
- 第二个是页面使用 JSTL 语法来处理页面逻辑。



#### Java 代码

在 jsp 之中，如果一行代码直接用<%= %> 就可以，如果是多行代码，则使用<% %>的语法。示例如下：



```html
<h3>一行 Java 代码</h3>
<p>
    Date today is <%= (new java.util.Date())%>
</p>
<h3>多行 Java 代码</h3>
<p>Your IP Address is :
<%
    out.println("Your IP address is "+request.getRemoteAddr()+"</br>");
    out.println("一段代码");
%>
</p>
```



##### For 循环

```html
<h3>For循环实例</h3>
<%
    int count=(int) session.getAttribute("count");
    for(int fontSize=1;fontSize<=count;fontSize++){
      %>
A good smile<br/>
<%}%>
```

 上面这段代码会打印出 A good smile 六次，因为之前的User传入信息之中 count 值是6 。

##### jstl语法：c:if , c: choose 和 c:when



页面常常会实现一些逻辑，使用 jstl 语法很容易实现这些功能。



```html
<h3>标签 c:if</h3>
<c:if test="${username!=null}">
<p>用户名为:${username}</p>
</c:if>
```

这段代码会判断 username 是否为空， 根据结果显示是否显示 username。

如果多个条件判断怎么办？ 使用 < c: choose>, < c: when> 和 <c: otherwise> 搭配进行判断。

```html
<h3>标签 c:choose</h3>
<c:choose>
    <c:when test="${salary<=0}">
        要死了
    </c:when>
    <c:when test="${salary>2000}">
        极其有钱
    </c:when>
    <c:when test="${salary>1000}">
        可以存活
    </c:when>
    <c:otherwise>
        啥也没有
    </c:otherwise>
</c:choose>
```

- 注意，这里经过实际测试，发现只会输出“极其有钱”，而不是“极其有钱”和”可以存活“，其原因是因为第一个

判断条件成立之后其直接会跳出，不会再继续进行判断。将这两个test调换一下位置，那么只会输出”可以存活“，也是一样的道理。



##### 页面布局

有些元素，例如页眉和页脚，是所有网页之中都相同的，适合提取出来然后复用。JSP 可以通过 include 指令实现这个效果，include 指令作用在于在编译阶段包括一个文件，这个指令告诉容器在编译阶段，将其他外部文件的内容合并到JSP文件之中，可以在JSP页面的任何位置使用include进行编码。

include 有两种用法：`<%@include file="relative url"%>` 和 `<jsp:include page="relative url" flush=”true”/>` 。前者在翻译阶段进行，后者在请求处理阶段进行。前者叫做静态包含，后者叫做动态包含，会在执行的时候检查包含内容变化。 下面是示例：

新建一个`footer.jsp`， 内容如下：

```html
<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<body>
我是页尾
</body>
</html>
```

然后在我们的`user.jsp`之中加入其内容，在这里我使用了上面提到的两种方式：

```html
<h3>布局</h3>
<%@include file="footer.jsp"%>
<jsp:include page="footer.jsp" flush="true"/>
```

再次访问`user.jsp`的时候，可以看到`footer.jsp`已经被展示到`user.jsp` 页面所引入的位置，且两个语句在本页面之中显示效果相同。

