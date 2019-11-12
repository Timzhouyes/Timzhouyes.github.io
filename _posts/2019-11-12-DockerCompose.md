---
layout:     post   				    # 使用的布局（不需要改）
title:      Docker Compose File explaination  		# 标题 
subtitle:   Simple analyse on examples from official website   #副标题
date:       2019-11-12		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Docker
---

How to depoly docker image to server, based on constructed CI/CD pipeline? This article is about the specific steps and details on it. 

# 1. Example Code

There are several versions of Conpose file: 1,2, 2,x and 3.x. Here is example code on official website based on version 3.7 on Yaml.

```yaml
version: "3.7"
services:

  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]

  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure

  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints: [node.role == manager]

  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]

networks:
  frontend:
  backend:

volumes:
  db-data:
```

Now I will explain details of the config file.

This file is defined into 3 big parts, services, networks and volumns. 

A service defination contains configuration that is appiled to each container ,and start for that service So pass command-line parameters to 

```
docker container create
```

. Likewise, if you want to define network or volume, can use command like `docker network create` or `docker volume create` .

Also can use environment variables in configurations like `{VARIABLE}` syntax. 

## 2. 'Service' part

## 2.1 build

This part is for configurations applied at build time.

Build part can only specified by a path:

```yaml
version: "3.7"
services:
  webapp:
    build: ./dir
```