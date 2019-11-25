---
layout:     post   				    # 使用的布局（不需要改）
title:      对于Spring Feign的一些学习总结  		# 标题 
subtitle:   包括一个官网负载均衡教程的自我总结        #副标题
date:       2019-11-25		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Spring Feign
---

教程地址：https://www.jianshu.com/p/a0d50385e598

在工作之中对于Spring Feign 的应用比较多。Feign，作为一个声明式的 Web Service 客户端，提供了HTTP 请求的模版，只要通过简单的编写接口和插入注解，就可以定义HTTP的参数，格式地址等等信息。而Feign则会完全代理HTTP请求，我们只需要像调用方法一样调用就可以完成服务请求和相关处理。

Feign之中整合了Ribbon和Hystrix， 可以让我们不需要再显式的使用这两个组件。另外，Spring Cloud还对Spring Feign提供了 Spring MVC注解的支持，这样我们可以在web之中使用同一个 `HttpMessageConverter`

> Hystrix 是一个管理依赖隔离的组件，由于分布式系统的规模很大， 很难保证各个服务所需要的依赖在所有时间之中都可用。一般来说，某个依赖会由很多组件使用，一个依赖的失效会导致很多服务宕机，这是不可允许的。Hystrix就是这样一个组件，其会根据组件的情况自动决定调用状态和调用某个组件。
>
> Ribbon 的主要功能是为客户端提供负载均衡算法。Ribbon客户端组件提供一系列的完善的配置项，比如连接超时，重试等等。简单而言，其就是一个客户端负载均衡器。

总的而言，Feign包含以下特性：

- 可插拔的注解支持，包括Feign注解和JAX-RS 注解
- 支持可插拔的HTTP编码器和HTTP解码器
- 支持Hystrix 和其 Fallback
- 支持 Ribbon 的负载均衡
- 支持 HTTP 请求和响应的压缩

下面，我会从官网：https://cloud.spring.io/spring-cloud-openfeign/reference/html/ 来具体介绍一下 Spring OpenFeign的各种参数和其用法。

# Declarative REST Client: Feign

All things we already mentioned in the part above. One additional point is Spring Cloud Loadbalancer provide a load-balanced http client when we use Feign.

## How to include Feign?

If we want to include Feign in our project, we should use starter with `org.springframework.cloud` and `spring-starter-openfeign`. 

StoreClient.java

```java
@FeignClient("stores")
public interface StoreClient {
    @RequestMapping(method = RequestMethod.GET, value = "/stores")
    List<Store> getStores();

    @RequestMapping(method = RequestMethod.POST, value = "/stores/{storeId}", consumes = "application/json")
    Store update(@PathVariable("storeId") Long storeId, Store store);
}
```

In code above, we have created one `@FeignClient('stores')` .This one is used to create the load-balancer in either `Ribbon` or `Spring Cloud LoadBalancer`.

Can also specify a URL using `url` attribute, but not recommanded. If there is part of url for all, we should put it into configuration file, so that we can change it easily. Not only the url case, but other cases ,if usually used, we should use configuration file to "One defination, everywhere use".

Above we mentioned that we have load-balancer. So in the annotation above we can use it to discover addresses for 'stores' service. 

## Overriding Feign Defaults

First of all, a central concept of Spring Cloud's Feign support is that the named client. This is used for build a group of components combine together to achieve one goal. And this is defined by the name of FeignClient, which we mentioned above. 

Spring Cloud created a new ensemble 