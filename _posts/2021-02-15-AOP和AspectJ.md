---
layout:     post   				    # 使用的布局（不需要改）
title:      AOP和AspectJ  		# 标题 
subtitle:   一些简要梳理，相关的demo做法和相应的规则列表        #副标题
date:       2021-02-15		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - AOP
    - AspectJ
---

参考：https://zhuanlan.zhihu.com/p/144550148

AOP在某些场景下面，比如同样的重复逻辑部分很好用，而目前一个比较好的实现就是AspectJ。

这个博主的一种解释我觉得很好：OOP是竖向抽取，其是将几个类之中的共同部分抽取出来，变成一个父类，再用继承父类的方式来消除这种类之中的冗余代码。

那么AOP这种“横向抽取”， 就是再深入一层，将方法之内的重复的东西抽取出来。相应的，AOP就有两个功能：

1. 抽取冗余代码
2. 将冗余代码嵌入原代码之中，且不能影响其功能。

做个小思考：不用AOP能不能做？

对于功能的实现而言，没有AOP当然也能做：不就是想要在方法之中再调用其他的方法嘛，我每个调用的地方都把对应的方法调取一遍，这样不就实现了？

但是这种会有问题：

1. 在每个方法之中都要手动嵌入需要调取的方法，非常繁琐，而且万一要做一点修改呢？能保证将所有需要修改的点都找到嘛？
2. 过多的和业务不相关的逻辑会和业务本身杂糅在一起，相应的使整个代码变得啰嗦且难以维护。

那么使用注解形式的AOP就能解决这两个问题：

1. 只要在需要统一逻辑的地方打上注解就可以，植入逻辑的部分让框架本身来做，避免人工可能带来的问题
2. 注解形式本身就已经将和业务无关的逻辑放在了注解之中，相关的代码就只会存留相应的业务逻辑，便于修改和维护。

这种特性，就使得AOP特别适合做**日志管理，实现事务等等“框架类”的功能。**

## AOP的基本概念

1. `Aspect`：切面，通常是一个类，里面可以定义其切入点(`JoinPoint`)和通知(`Advice`)
2. `JoinPoint`：连接点，程序执行的过程之中，明确的点，一般是方法的调用。我个人的理解就是要在哪些方法里面插入注解的逻辑，哪些方法就是连接点。比如在打log这个行为之中，所有的方法都是连接点，因为所有的方法都会被“打log”这个行为覆盖到并且植入打log的逻辑。
3. `Advice`:通知，说白了就是要执行的逻辑，一般有什么`@before`， `@After`这种，其他的还有``afterReturning,afterThrowing,around`
4. `Pointcut`: 切入点，用来书写切入点的表达式，一般都是用来定义哪些方法需要切入
5. AOP 代理：AOP 框架创建的对象，代理，就是对目标对象的加强、Spring 之中AOP 代理可以是 JDK 动态代理，也可以是 CGLIB 代理。前者基于接口，后者基于类。



## 实战演练

1. 当然是要引入 pom 包：

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
                <dependency>
            <groupId>org.aspectj</groupId>
            <artifactId>aspectjweaver</artifactId>
            <version>1.9.6</version>
        </dependency>
```

2. 我们要测试 AspectJ, 那么就要加入相关的类。本次测试两种，一种是基于注解的方式，一种是直接指定哪些范围之内的类需要相应的切面切入；这两种我们都会演示：

```java
package com.study.haiming.demo.service;

import java.lang.annotation.*;

/**
 * @author haiming.zhou
 */
@Documented
@Retention(value = RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Action {
    String name();
}

```

这里面讲一下各注释的内容：

java annotation 中 SOURCE 和 CLASS 的区别？ - RednaxelaFX的回答 - 知乎 https://www.zhihu.com/question/60835139/answer/180750670

> RetentionPolicy: 其中有三种：SOURCE，CLASS 和 RUNTIME。
>
> 1. `Retention.SOURCE`:只是在编译阶段起作用，不会在编译之后的类文件之中出现。
>
>    举个例，比如`@SuppressWarnings`，这个只是用来在编译阶段来抑制警告，当然就没必要在编译之后的 .class 之中出现，所以其的范围就是在 SOURCE 阶段。
>
> 2. `Retention.CLASS`:在编译之后会保留而且写入.class 文件之中，但是 JVM 在加载的时候不需要将其加载成运行时可见（也就是反射可见）的注解。
>
>    这个最重要的一个用处是在编译多个 Java 文件时候的情况：假设要编译 A.java 文件和 B.class 文件，但是 A 类依赖 B 类，并且 B 类上面**有注释想让 A.java 编译的时候看到**，那么 B.ckass 之中就必须持有这些信息才行。比如某些校验参数的注解，希望 A 在编译的时候也能看到。下面是举例
>
>    > 举一个在Android开发的场景：有这样一种注解，@ColorRes，可以用来标识一个方法的参数，比如B类的method方法， public void method(@ColorRes int color)。这个时候A类调用method方法，就必须传入颜色资源，而不能是其他任意的int。A和B属于两个class文件，A依赖B的注解，所以就需要将ColorRes这个注解定义成CLASS的，这样B编译成class文件仍然有这个注解，让A看见。
>
> 3. `Retention.RUNTIME`:在编译的时候会保留，写入 class 文件，并且 JVM 在加载类的时候也会将其加载成反射可见的注解。比如说 Spring 的依赖注入就会在运行的时候扫描类上面的注解来决定要**注入什么**

> Target:用来说明这个注解放在什么地方，比如类，方法或者构造器。一共有这些：
>
> ```java
> public enum ElementType {
>     /** Class, interface (including annotation type), or enum declaration */
>     TYPE,
> 
>     /** Field declaration (includes enum constants) */
>     FIELD,
> 
>     /** Method declaration */
>     METHOD,
> 
>     /** Formal parameter declaration */
>     PARAMETER,
> 
>     /** Constructor declaration */
>     CONSTRUCTOR,
> 
>     /** Local variable declaration */
>     LOCAL_VARIABLE,
> 
>     /** Annotation type declaration */
>     ANNOTATION_TYPE,
> 
>     /** Package declaration */
>     PACKAGE,
> 
>     /**
>      * Type parameter declaration
>      *
>      * @since 1.8
>      */
>     TYPE_PARAMETER,
> 
>     /**
>      * Use of a type
>      *
>      * @since 1.8
>      */
>     TYPE_USE
> }
> ```
>
> 

3. 下面就是编写具体的切面信息了：

   一般而言，一个切面信息都要包括以下这些方面：

   1. 在类上面标注好`@Aspect`和`@Component`，第一个是注明这个类是一个切面，而第二个注明是让 Spring 托管这个类。
   2. 还有上面所提到的`@PointCut`，用来表明其生效的范围。
   3. 再有之前提及到的那些，什么@Before，@After，这些用来标明顺序的 Advice 具体逻辑。

   下面是两个部分的例子，一个是直接按照方法规则进行拦截并处理，一个是使用注解来进行处理。使用方法拦截规则进行处理的时候，就不需要在某些方法上面注明，而是会被直接覆盖；但是如果是注解形式，那么需要对应的方法上进行说明。

   ~~~java
   package com.study.haiming.demo.service;
   
   import org.aspectj.lang.JoinPoint;
   import org.aspectj.lang.annotation.After;
   import org.aspectj.lang.annotation.Aspect;
   import org.aspectj.lang.annotation.Before;
   import org.aspectj.lang.annotation.Pointcut;
   import org.aspectj.lang.reflect.MethodSignature;
   import org.springframework.stereotype.Component;
   
   import java.lang.reflect.Method;
   
   @Aspect
   @Component
   public class LogAspect {
       @Pointcut("@annotation(com.study.haiming.demo.service.Action)")
       public void annotationPointCut() {
       }
   
       @Before("execution(* com.study.haiming.demo.controller.*.*(..))")
       public void before(JoinPoint joinPoint) {
           MethodSignature signature = (MethodSignature) joinPoint.getSignature();
           Method method = signature.getMethod();
           System.out.println("方法规则式拦截：" + method.getName());
       }
   
       @After("annotationPointCut()")
       public void after(JoinPoint joinPoint) {
           MethodSignature signature = (MethodSignature) joinPoint.getSignature();
           Method method = signature.getMethod();
           Action action = method.getAnnotation(Action.class);
           System.out.println("注释式拦截" + action.name());
       }
   
   
   }
   
   ~~~

4. 当然还有一些必不可少的Controller 部分：

   ```java
   package com.study.haiming.demo.controller;
   
   import com.study.haiming.demo.service.Action;
   import org.springframework.web.bind.annotation.GetMapping;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   @RestController
   @RequestMapping("/test")
   public class TestController {
   
   
       @Action(name = "测试这个日志")
       @GetMapping("/value")
       public String run(String value) {
           System.out.println("日志测试");
           return value;
       }
   
   }
   ```

   这部分之中是我们如何使用对应的方法和类。


    那么在这两种方式之中，所得到的结果是：

   ![image-20210215173204617](/img/2021-02-15-AOP和AspectJ/image-20210215173204617.png)

​	可以看到其的确是按照我们所规定的顺序进行日志的打印。而且我们可以方便的得到对应的方法的属性，用来进一步定位这些数据的来源。

## @Pointcut 的覆盖规则

参考：https://www.jianshu.com/p/3c73065ecbdf

1. 首先让我们来了解下AspectJ类型匹配的通配符：

*：匹配任何数量字符
 ..：匹配任何数量字符的重复，如在类型模式中匹配任何数量子包；而在方法参数模式中匹配任何数量参数（0个或者多个参数）
 +：匹配指定类型及其子类型；仅能作为后缀放在类型模式后边



使用execution(方法表达式)匹配方法执行。

execution格式



```go
execution(modifiers-pattern? ret-type-pattern declaring-type-pattern? name-pattern(param-pattern) throws-pattern?)
```

- 其中带 ?号的 modifiers-pattern?，declaring-type-pattern?，hrows-pattern?是可选项
- ret-type-pattern,name-pattern, parameters-pattern是必选项
- modifier-pattern? 修饰符匹配，如public 表示匹配公有方法
- ret-type-pattern 返回值匹配，* 表示任何返回值，全路径的类名等
- declaring-type-pattern? 类路径匹配
- name-pattern 方法名匹配，* 代表所有，set*，代表以set开头的所有方法
- (param-pattern) 参数匹配，指定方法参数(声明的类型)，(..)代表所有参数，(*,String)代表第一个参数为任何值,第* * 二个为String类型，(..,String)代表最后一个参数是String类型
- throws-pattern? 异常类型匹配



![img](/img/2021-02-15-AOP和AspectJ/webp)