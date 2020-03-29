---
layout:     post   				    # 使用的布局（不需要改）
title:      《Spring Boot 42讲》学习笔记（1） 				# 标题 
subtitle:   从Hello world开始……  #副标题
date:       2019-04-23				# 时间
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



# 第 1-1 课：Spring Boot产生的背景及其设计理念



Spring是Rod Johnson在不满当时的Java EE和EJB过于臃肿，不是所有的项目都需要这种大型框架的情况下自行开发的。在其interface21一炮走红之后，一对一的J2EE设计和开发开始流行起来。2003年，其和同伴在这个基础上开发了一个全新的框架，命名为Spring。随后Spring的发展进入了快车道。



#### 到底啥是J2EE？



> J2EE(Java 2 Platform Enterprise Edition) 企业版
> J2EE是功能最丰富的一个版本，主要用于开发高访问量、大数据量、高并发量的网站，例如美团、去哪儿网的后台都是J2EE。
> 通常所说的JSP开发就是J2EE的一部分。
> J2EE包含J2SE中的类，还包含用于开发企业级应用的类，例如EJB、servlet、JSP、XML、事务控制等。
> J2EE也可以用来开发技术比较庞杂的管理软件，例如ERP系统（Enterprise Resource Planning，企业资源计划系统）。



下面贴一个自己觉得有用的知乎回答：



> Java各种标准的制定是通过Java Community Process - JCP进行的。JCP的成员可以根据需要提出Java Specification Request - JSR。每个JSR都要经过提交给JCP，然后JCP讨论，修订，表决通过，并最终定稿；当然，运气不好的就被拒绝/废弃了。
> **而JavaEE是一组被通过的JSR的合集**。JSR和JavaEE的关系就好像是文章和经过编辑整理过的文集。
> 作者：大宽宽
>
> 链接：https://www.zhihu.com/question/268742981/answer/341770209
>
> 来源：知乎
>
> 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。





#### Spring Boot的诞生

随着使用的人数越来越多，Spring集成的开源软件也越来越多，慢慢的到后期Spring开发大项目需要引入巨量的配置文件，太多的配置不仅难以理解，还很容易配置出错。

而在2013年的SpringOne 2GX会议上，pivotal的CTO回应了这些批评，且提到该平台将来的目标就是实现免XML配置的开发体验。后来我们看到了，Spring Boot的实现功能远远超过了这个任务的描述。开发人员不仅不需要写XML，在一些场合下甚至不需要写import语句。

2013年，微服务的概念也逐渐兴起，Spring刚好处于交叉点上。Spring Boot的目标不是为已解决的问题提供新的解决方案，而是为平台带来另一种的开发体验，从而简化这些技术的使用。

#### 约定优于配置

约定优于配置，（convention over configuration），也称作按约定变成，旨在减少软件开发人员需做决定的数量，而又不失灵活性。

其本质是开发人员仅需要规定应用之中不符合约定的部分。只有在偏离约定的时候，才需要写有关的配置。

Spring Boot 即采用这种思想。

### Spring Boot Starters

其基于约定优于配置来设计，其中有两个核心组件，自动配置代码和提供自动配置模块及其他有用的依赖。其意味着我们引入某个Starter，就拥有了这个软件的默认使用能力。

在没有Spring Boot之前，对于风格不同的开源软件的特性，有很多不同的调用风格在项目之中，这使得组件包集成这件事情变得很困难。但是Spring Boot融合了一系列的Starter，让我们在集成的时候只是需要很少的代码和配置即可完成，可以说是Spring Boot最大的优势之一。

由于Spring Boot足够强大，很多第三方社区都进行了主动的集成，在Spring Boot下面使用这些软件，只需要引入对应的Starter包。
 
 
# 第1-3课：Spring Boot依赖环境和项目结构介绍

两个基础环境：Java编译环境，构建工具环境
一个开发工具：IDE开发工具

Spring Boot 2.0 要求Java8作为最低版本。

构建工具是一个将源代码生成可执行应用程序的自动化工具，在Spring Boot之中使用的构建工具是Maven。

IDE选择IDEA。

#### settings.xml配置

Maven解压之后会有一个settings.xml文件，用来配置Maven的仓库和本地Jar包存储地址。Maven仓库地址代表从哪去下载项目之中的依赖包Jar包。

#### 项目结构介绍

Spring Boot的基础结构共有三个文件，具体：
- src/main/java：程序开发以及主程序⼊入⼝；
- src/main/resources：配置文件；
- src/test/java：测试程序


Spring Boot的建议目录结构如下：

src/main/java/com.neo 下：
- Application.java: 放到根目录下，作为项目的启动类，Spring Boot项目只可以有一个Main（）方法
- comm：建议放置公共的类，如全局的配置文件，工具类等等
- model：主要用于Entity和Repository
- repository：是数据库访问层代码
- service：是业务类代码
- web：负责页面访问控制

src/main/resources 下：
- static：存放web页面的静态资源，如js,css，图片等等
- templates存放页面模板
- application.properties 存放下项目的配置信息。
- 
test目录存放单元测试的代码，pom.xml用于哦欸之项目的依赖包和其他配置。

#### Pom包介绍

Pom.xml文件主要描述了项目包的依赖和项目构建时候的配置，在默认的pom.xml之中分为五大块：

##### 1. 项目的描述信息

```
<groupId>com.neo</groupId>
<artifactId>hello</artifactId>
<version>2.0.5.RELEASE</version>
<packaging>jar</packaging>
<name>hello</name>
<description>Demo project for Spring Boot</description>
```

- groupid：项目的包路径
- artifactid：项目名称
- version：项目版本号
- packaging：一般有两个值，jar,war,表示用Maven打包的时候构建哪种包
- name：项目名称
- description：项目描述


##### 2.项目的依赖配置信息

```
<parent>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-parent</artifactId>
<version>2.0.5.RELEASE</version>
<relativePath/> <!-- lookup parent from repository -->
</parent>
<dependencies>
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-devtools</artifactId>
<scope>runtime</scope>
</dependency>
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-test</artifactId>
<scope>test</scope>
</dependency>
</dependencies>
```

- Parent：标签内配置Spring Boot父级版本Spring-boot-starter-parent,Maven支持父子结构，引入父级之后会默认继承父级的配置。
- dependencies: 项目所需要的依赖包。在Spring Boot之中的以来组件不需要填写具体的版本号，spring-boot-starter-parent维护了体系内所有依赖包的版本信息。


下面说一下`spring-boot-starter-parent`的提供特性：
- 默认使用Java8
- 使用UTF-8编码
- 一个引用管理的功能，使得上面提到的dependencies之中不需要再填写version信息，这些会从`spring-boot-dependencies`之中继承
- 资源过滤（sensible resource filtering)
- 识别插件配置（ Sensible plugin configuration)
- 识别application.properties和application.yml类型的文件


##### 3. 构建时需要的公共变量

```
<properties>
<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
<java.version>1.8</java.version>
</properties>
```

- 第一行是项目构建时候使用的编码
- 第二行是项目输出时候所用的编码
- 第三行是项目使用的JDk版本

##### 4. 构建配置

```
<build>
<plugins>
<plugin>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-maven-plugin</artifactId>
</plugin>
</plugins>
</build>
```

使用Maven构建Spring Boot项目依赖于spring-boot-maven-plugin组件，其以Maven的方式为应用提供Spring Boot的支持。spring-boot-maven-plugin 可以将Spring boot 应用打包为可执行的jar或者war文件，然后以简单的方式运行Spring Boot应用。


# 第1-4课：写一个Hello World来感受Spring Boot

#### 1. Pom.xml之中有一个默认模块：

```
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-test</artifactId>
<scope>test</scope>
</dependency>
```

- `<scope>test</scope> `表示依赖的组件仅参与测试相关的工作，不会被打包包含进去
- ` spring-boot-startee-test` 是spring boot提供项目测试的工具包，内置了多种测试工具。


#### 2. 编写controller内容
```
@RestController
public class HelloController {

    @RequestMapping("/hello")
    public String hello() {
        return "hello world";
    }
}
```

- `@RestController`的意思是Controller之中的方法都使用JSON格式输出。如果这个配置是`@Controller`，代表输出内容到页面。
- `@requestMapping("/hello")` 提供路由信息，"/hello" 上面的HTTP Request都会被映射到 `/hello` 方法上进行处理。


#### 3. 启动主程序

在这里我遇到了问题:使用IDEA启动可以成功，但是使用` mvn spring-boot:run` 就不行，直接报错如下：

`[ERROR] No plugin found for prefix 'spring-boot' in the current project and in the plugin groups`


后来发现这个问题是因为没有在`pom.xml`的目录下面启动导致的。在更换到`pom.xml`的目录之后启动此命令，仍然报错，报错信息为：

`[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.8.0:compile (default-compile) on project hello: Compilation failure
[ERROR] No compiler is provided in this environment. Perhaps you are running on a JRE rather than a JDK?`

再次搜索之后发现是因maven在User/m.2/repository下面和我自己定义的文件夹下面都下载了依赖包，解决方案为删除在m.2/repository下面的依赖包即可。

#### 4.如果想传入参数怎么办
下面是通过URL传参的演示：

只要在后端处理请求的方法之中有和参数键相同名称的属性，在请求的过程中会自动将参数赋值到属性之中，最后在方法中直接使用即可。下面还是我们创建的`hello()`为例进行演示


```java
@RestController
public class HelloController {
    @RequestMapping("/hello")
    public String hello(String name) {
        return "hello world, " +name;
    }
}
```

### 热部署

想实现在修改Controller内的代码，无需重新启动项目即可运行，就需要用到热启动了。热启动要在一开始引入组件：spring-boot-devtools 

首先在`pom.xml` 之中添加组件：

```xml
<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-Devtools</artifactId>
<optional>true</optional>
</dependency>
```

然后在`pom.xml`之中将其中添加Fork属性并且设为ture。修改完应该是下面所示：

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <fork>true</fork>
                </configuration>
        </plugin>
    </plugins>
</build>
```
