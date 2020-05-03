---
layout:     post   				    # 使用的布局（不需要改）
title:      gitlab CI与DockerFile/kubernetes File初探		# 标题 
subtitle:   了解一下其中的异同        #副标题
date:       2020-05-03		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Docker
    - Kubernetes
---

因为使用的就是gitlab-ci，加上在开发环境和测试环境上面在部署的时候使用的是docker和kubernetes，今天来初探一下其过程和区别。

# 1. gitlab-ci 用法

参考：

作者：浦东飞猪老莲
链接：https://zhuanlan.zhihu.com/p/68371743
来源：知乎

下面就以我自己手头的这份文件作为剖析：

```yaml
stages:
  - test
  - build
  - deploy

variables:
  GIT_STRATEGY: none
  PROJECT_REPO_NAMESPACE: test
  PROJECT_REPO_NAME: cicd_learn
  DEPLOYMENT_REPO_NAMESPACE: test
  DEPLOYMENT_REPO_NAME: deploy_test

before_script:
  - export ROOT_PATH=$(pwd)
  - echo 'root path:' $ROOT_PATH
  - mkdir $PROJECT_REPO_NAME
  - cd $PROJECT_REPO_NAME
  - <some git manipulation here>
  - echo 'date:' $DATE

test_stage:
  stage: test
  script:
    - <test related command here>
  artifacts:
    paths:
      - xxxx.html
    when: always
  allow_failure: false

build_stage:
  stage: build
  script:
     - <build related command here>
  when: manual
  allow_failure: false
  only:
    - master

deploy:
  stage: deploy
  script:
    - <deploy related command here>
  allow_failure: false
  only:
    - master
```



## 1.1 stages

这个是包含了有多少阶段，比如：

```yaml
  - test
  - build
  - deploy
```

那么就意味着有三个阶段。

## 1.2 variables

此处标识了为了后续流程，从而定义的键值对象。此处定义了namespace 和  repo name

## 1.3 before script

在脚本执行之前，需要指定或者执行的一些命令。比如建个文件夹，新建个文件，打个log之类的。

## 1.4 script

顾名思义，一般而言都是出现在某个Stage之中的。在这个流程之中执行对应的script。比如可以切换目录，使用写好的build脚本来build镜像等等

## 1.5 artifacts

这个用来定义产出，比如让某个stage产出一个html格式的报告来显示各个阶段单元测试的执行情况（相关代码写在项目之内）。数组之中的`paths`和`when`定义了报告的路径和产出场景。

示例之中意味着报告放置于根目录之下，任何时候都要提供报告。

## 1.6 allow_failure

顾名思义，是否允许失败。由于我们这个脚本之中的步骤都是必不可少的（打包，push镜像等等），所以所有此处的设置都是false，也就是不允许失败。

## 1.7 when

如果when是always,那么就意味着其会一直被自动触发。如果这里配置是`manual`，那么就意味着需要自己去手动点击才能触发。

## 1.8 only

这个也很常用，比如我们会有很多本地的开发分支，这些分支可能只是在本机上跑，并不需要去到服务器的环境之中，那么就只设置几个需要跑pipeline的分支就好，比如：

```yaml
  only:
    - develop
    - staging
    - master
```

意思就是只有这三个分支的改动才会触发相应的pipeline

# 2. dockerFile解析

此处的dockerfile指的是服务器上面相应的docker-compose file，也就是在服务器上面指定docker如何部署镜像的file。由于涉及到公司信息，因此具体信息隐去不表。

下面是脱敏之后的信息，供读者参考以及下面解释分析：

```yaml
version: '3.4'

services:
  services-internal-api:
    image: docker.services.net/application-internal-api:${APPLICATION_VERSION}
    environment:
      - SPRING_PROFILES_ACTIVE=${APPLICATION_ENV}
      - APPLICATION_ENV=${APPLICATION_ENV}
      - CONTAINER_HOST=${CONTAINER_HOST}
    volumes:
      - ./services-backend/internal-api/logs:/app/logs
    env_file:
      - ./shared_configs.env
      - ./special_service_configs.env
    ports:
      - 8888:8080
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      restart_policy:
        max_attempts: 2
    logging:
      options:
        max-size: "20m"
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/actuator/info"]
      start_period: 500s
      retries: 3
      interval: 5s
  services-scheduled:
    image: docker.services.net/application-scheduled:${APPLICATION_VERSION}
    environment:
      - SPRING_PROFILES_ACTIVE=${APPLICATION_ENV}
      - APPLICATION_ENV=${APPLICATION_ENV}
      - CONTAINER_HOST=${CONTAINER_HOST}
    env_file:
      - ./shared_configs.env
      - ./scheduled_service_configs.env
    volumes:
      - ./services-backend/scheduled/logs:/app/logs
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        max_attempts: 2
    logging:
      options:
        max-size: "20m"
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/actuator/info"]
      start_period: 500s
      retries: 3
      interval: 5s
```

这是一个包含了两个service的dockerfile。下面就以其作为样本来讲解。

## 2.1 service-name

此处的service-name 就是 services-internal-api和services-scheduled。由此可见，service在一个文件之中可以超过一个，可以进行批量的更新。

由于两个service的内容几乎相同，此处只选择第一个作为示例解读。

## 2.2 image

镜像位置，示例之中为：``docker.services.net/application-internal-api:${APPLICATION_VERSION}`。注意此处的link之中是带有参数的，参数在下面会标识出来。一般而言都是代表拉取image的版本（其他也没啥可以进行标识的了）。

## 