---
layout:     post   				    # 使用的布局（不需要改）
title:      Docker初探				# 标题 
subtitle:   初步学习Docker及相关知识 #副标题
date:       2019-04-18				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Docker
    - 记录
    - Study
---
# 1. 什么是Docker
Docker的英文定义是：Docker is a computer program that performs operating-system-level virtualization.

在阅读了资料之后，我认为Docker最开始的版本是一个使用了Linux Kernel的特性，例如cgroups和namespaces，来进行资源虚拟和封装的软件。其提供一个额外的软件抽象层，以及操作系统虚拟化的自动管理机制。

## 1.1 Cgroups
先上维基百科定义：cgroups (abbreviated from control groups) is a Linux kernel feature that limits, accounts for, and isolates the resource usage (CPU, memory, disk I/O, network, etc.) of a collection of processes.

即：cgroups是一个Linux Kernel的特性，可以限制，管理和独立一系列进程对于资源的使用（CPU，memory，disk I/O，网络，等等）。

其有特性为：
1. 资源限制：groups可以被限制给配置好的内存容量，也包括了文件系统缓存
2. 优先级：某些groups可以得到更多的CPU使用时间或者磁盘的I/O份额
3. 统计：衡量groups的资源使用，可以用来统计，例如生成账单
4. 控制：冻结，存档或者重启groups

## 1.2 Linux namespaces

还是先上维基百科：Namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources while another set of processes sees a different set of resources. The feature works by having the same name space for these resources in the various sets of processes, but those names referring to distinct resources. Examples of resource names that can exist in multiple spaces, so that the named resources are partitioned, are process IDs, hostnames, user IDs, file names, and some names associated with network access, and interprocess communication.

简而言之，是使不同的进程看到不同的资源。

## 1.3 LXC（Linux Containers)

再来维基：
LXC (Linux Containers) is an operating-system-level virtualization method for running multiple isolated Linux systems (containers) on a control host using a single Linux kernel.

LXC combines the kernel's cgroups and support for isolated namespaces to provide an isolated environment for applications. Early versions of Docker used LXC as the container execution driver, though LXC was made optional in v0.9 and support was dropped in Docker v1.10. 

LXC提供一个OS级别的虚拟化，其有自己的进程和网络空间。其依赖于Linux Kernel cgroups。

# 2. 为什么Docker比虚拟机要快
虚拟机：将整个硬件做一套仿真，在其基础上运行系统镜像。其因为仿真硬件，所以是从底层就开始将其隔离开，每次启动的时候都需要完成所有的，OS启动的步骤。而且资源得不到完整的利用（给虚拟机分配40G的话真的要在硬盘上划40G出来），所以由于步骤繁多和资源利用率低，其效率较低。

Docker:
1. 不需要将硬件资源虚拟化，Docker使用的都是实际物理机的硬件资源。所以资源利用率更高
2. 利用宿主机Kernel，不需要重新加载操作系统。



| |Docker容器|虚拟机（VM）|
|-------|-------|--------|
|操作系统|与宿主机共享OS|宿主机OS上运行宿主机OS|
|存储大小|镜像小，便于存储与传输|镜像庞大（vmdk等）|
|运行性能|几乎无额外性能损失|操作系统额外的cpu、内存消耗|
|移植性|轻便、灵活、适用于Linux|笨重、与虚拟化技术耦合度高|
|硬件亲和性|面向软件开发者|面向硬件运维者|

# 3. Docker的三个主要概念
1. 镜像（Image）： 一个包含文件系统的面向Docker引擎的只读模板。
2. 容器（Container）：极简的Linux系统环境与其中运行的程序。Docker引擎利用容器来隔离各个应用。在容器从镜像启动的时候，Docker在镜像上面添加一个可写层，但是镜像本身不变。我的理解，镜像和容器之间的关系有些类似Class和Object，一个是模板，一个是供实际操作的对象
3. 仓库（Repository）：Docker用来存放镜像的地方。

# 