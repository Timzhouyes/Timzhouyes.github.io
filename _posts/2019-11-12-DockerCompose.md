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

Or with other specific configurations,like dockerfile and args:

```yaml
version: "3.7"
services:
  webapp:
    build:
      context: ./dir
      dockerfile: Dockerfile-alternate
      args:
        buildno: 1
```

I will mention the args meaning below.

The args are under `build` command, if specify `image` as well as `build`, then Compose specified `image` ,in the example below, it is `webapp` with the option `tag` . This result in an image named `webapp` and tagged with `tag`, built from `./dir`:

```yaml
build: ./dir
image: webapp:tag
```

> **Note**: This option is ignored when [deploying a stack in swarm mode](https://docs.docker.com/engine/reference/commandline/stack_deploy/) with a (version 3) Compose file. The `docker stack` command accepts only pre-built images.

## 2.2 Context

Can be a path to directory containing a Dockerfile, or **a url to git repository**.

Compose builds and tags it with a generated name

```yaml
build:
  context: ./dir
```

## 2.3 Dockerfile

Alternative Dockerfile, it is used as an image.

## 2.4 Args

First specify arguments in Dockerfile:

```Dockerfile
ARG buildno
ARG gitcommithash

RUN echo "Build number: $buildno"
RUN echo "Based on commit: $gitcommithash"
```

Args can be used in 2 ways, like below:

```yaml
build:
  context: .
  args:
    buildno: 1
    gitcommithash: cdc3b19
```

```yaml
build:
  context: .
  args:
    - buildno=1
    - gitcommithash=cdc3b19
```

> Note: in Dockerfile, if specify `ARG` before the `FROM` instruction, `ARG` is not available in the build instructions under from. 
>
> **If want an argument available in both placces, specify it under `FROM` instruction.**

Can omit the value when only specifying a building argument, in this case, at build time,its value is the value in environment where Compose is running.

```yaml
args:
  - buildno
  - gitcommithash
```

> YAML boolean values (`true`, `false`, `yes`, `no`, `on`, `off`) must be enclosed in quotes

## 2.5 Cache_From

This option can not found in our files, so just explain normally.

```yaml
build:
  context: .
  cache_from:
    - alpine:latest
    - corp/web_app:3.14
```

## 2.6 Labels

Add metadata using `Docker Labels` .Can use it either an array or a dictionary.

Recommanded use Reverse-DNS notation to prevent labels from conflicting whit those used by other software.

> Reverse-DNs notation: if your website is `example.com`, Reverse-DNS is `com.example`

```yaml
build:
  context: .
  labels:
    com.example.description: "Accounting webapp"
    com.example.department: "Finance"
    com.example.label-with-empty-value: ""
```

```yaml
build:
  context: .
  labels:
    - "com.example.description=Accounting webapp"
    - "com.example.department=Finance"
    - "com.example.label-with-empty-value"
```

## 2.7 Configs

Config on per-service basis using per-service `config` . Two different syntax variants are supported.

**Short syntax**

Short syntax only specify the config name. 

Code below define my_other_config as an external resource,which means **it has already been defined in Docker**, either by running the `docker config create` command or by another stack deployment.

If the external config does not exist, the stack deployment fails with `config not found` error.

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    configs:
      - my_config
      - my_other_config
configs:
  my_config:
    file: ./my_config.txt
  my_other_config:
    external: true
```

**Long Syntax**

In this format, can define more details on deployment 

- `source`: The name of the config as it exists in Docker.
- `target`: The path and name of the file to be mounted in the service’s task containers. Defaults to `/` if not specified.
- `uid` and `gid`: The numeric UID or GID that owns the mounted config file within in the service’s task containers. Both default to `0` on Linux if not specified. Not supported on Windows.
- `mode`: The permissions for the file that is mounted within the service’s task containers, in octal notation. For instance, `0444` represents world-readable. The default is `0444`. Configs cannot be writable because they are mounted in a temporary filesystem, so if you set the writable bit, it is ignored. The executable bit can be set. If you aren’t familiar with UNIX file permission modes, you may find this [permissions calculator](http://permissions-calculator.org/) useful.

```yaml
version: "3.7"
services:
  redis:
    image: redis:latest
    deploy:
      replicas: 1
    configs:
      - source: my_config
        target: /redis_config
        uid: '103'
        gid: '103'
        mode: 0440
configs:
  my_config:
    file: ./my_config.txt
  my_other_config:
    external: true
```

## 2.8 Image

Specify the image to start container from. Can either be a repository/tag or a partial image ID.

```yaml
image: redis
image: ubuntu:14.04
image: tutum/influxdb
image: example-registry.com:4000/postgresql
image: a4bc65fd
```

## 2.9 Environment

Add environment variables. Can use either an array or a dictionary.

```yaml
environment:
  RACK_ENV: development
  SHOW: 'true'
  SESSION_SECRET:
```

```yaml
environment:
  - RACK_ENV=development
  - SHOW=true
  - SESSION_SECRET
```

## 2.10 Volumes

volume is the way for containers to process persistent data. In compose, we can use 2 ways to specify Volume:

- Use named volume
- Use path in host to create volumes

```yaml
version: "3.2"
services:
  web:
    image: nginx:alpine
    volumes:
      - type: volume
        source: mydata
        target: /data
      - type: bind
        source: ./nginx/logs
        target: /var/log/nginx
  jenkins:
    image: jenkins/jenkins:lts
    volumes:
      - jenkins_home:/var/jenkins_home
      - mydata:/data
volumes:
  mydata:
  jenkins_home:
```

In this config file, we create 3 volumes together, 2 are named volumes `Jenkins_home` and `mydata`. Also one bind type volume for saving nginx log.

## 2.11 Ports

Expose ports.

**Short Syntax**

```yaml
ports:
 - "3000"
 - "3000-3005"
 - "8000:8000"
 - "9090-9091:8080-8081"
 - "49100:22"
 - "127.0.0.1:8001:8001"
 - "127.0.0.1:5000-5010:5000-5010"
 - "6060:6060/udp"
```

**Long Syntax**

The long form syntax allows the configuration of additional fields that can’t be expressed in the short form.

- `target`: the port inside the container
- `published`: the publicly exposed port
- `protocol`: the port protocol (`tcp` or `udp`)
- `mode`: `host` for publishing a host port on each node, or `ingress` for a swarm mode port to be load balanced.

```yaml
ports:
  - target: 80
    published: 8080
    protocol: tcp
    mode: host
```

## 2.12 Deploy

Specify configuration related to the deployment and running of services.

Only take effect when deploying to a swarm with docker stack deploy, and is ignored by `docker-compose up` and `docker-compose run`