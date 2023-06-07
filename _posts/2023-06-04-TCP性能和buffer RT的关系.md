---
layout:     post   				    # 使用的布局（不需要改）
title:      TCP性能和buffer RT的关系  		# 标题 
subtitle:   基础概念，实验步骤重放以及结果分析        #副标题
date:       2023-06-04		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - TCP
---

参考文档：https://plantegg.github.io/2019/09/28/%E5%B0%B1%E6%98%AF%E8%A6%81%E4%BD%A0%E6%87%82TCP--%E6%80%A7%E8%83%BD%E5%92%8C%E5%8F%91%E9%80%81%E6%8E%A5%E6%94%B6Buffer%E7%9A%84%E5%85%B3%E7%B3%BB/

https://plantegg.github.io/2016/08/24/Linux%20tc%20qdisc%E7%9A%84%E4%BD%BF%E7%94%A8%E6%A1%88%E4%BE%8B/

# 基本概念

## QPS和RT

QPS： query per second，is a measure of the amount of search traffic an [information-retrieval](https://en.wikipedia.org/wiki/Information_retrieval) system, such as a [search engine](https://en.wikipedia.org/wiki/Search_engine) or a [database](https://en.wikipedia.org/wiki/Database), receives in one second.[[1\]](https://en.wikipedia.org/wiki/Queries_per_second#cite_note-1)

RT： response time,一个请求完成的时间

## [Little's law](https://en.wikipedia.org/wiki/Little%27s_law)

that the long-term average number *L* of customers in a [stationary](https://en.wikipedia.org/wiki/Stationary_process) system is equal to the long-term average effective arrival rate *λ* multiplied by the average time *W* that a customer spends in the system. Expressed algebraically the law is

![{\displaystyle L=\lambda W.}](../img/2023-06-04-TCP性能和buffer RT的关系/0dad0c564990973535a7f5f5e7507a1dc727f904)

A very brief example is that, one university admit 2000 students per year, and all students need to study 4 years, then whenever the university has 2000*4 = 8000 students.

# 实验步骤

## server side：

1. generate 2G file：`fallocate -l 2G haiming`
2. start monitoring by `tcpdump`: `tcpdump -s 120 -w server.pcap`
3. start one simple http server on port 8089:` python3 -m http.server 8089`



## client side:

1. try ping `google.com`: `ping google.com`
2. start tcpdump: `tcpdump -s 120 -w client.pcap`
3. get the big 2G file: `curl 172.31.24.234:8089/haiming --output ~/haiming`
4. try ping `google.com`: `ping google.com`
5. 

