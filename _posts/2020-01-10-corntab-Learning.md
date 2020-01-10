---
layout:     post   				    # 使用的布局（不需要改）
title:      学习corntab 定时任务  		# 标题 
subtitle:   记一次项目之中定时任务的学习        #副标题
date:       2020-01-10		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - corntab
---

由于今天要写一个定时任务的项目，今天学习一下crontab的写法。

https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/crontab.html

# crontab用来干什么？

通过corntab，可以在固定的时间间隔上面执行指定的系统指令，或者是shell script 脚本。不只是时间间隔，也可以是某个或者某些时间点。

# 命令格式？

crontab [-u user] file crontab [-u user] [-e | -l | -r]

但是因为我们是在Spring之中集成，所以不需要掌握此处的命令，直接使用Annotation即可。

# 命令参数

同上，因为是在Spring之中集成，所以此处的命令参数只是介绍。

- -u user：用来设定某个用户的crontab服务；
- file：file是命令文件的名字,表示将file做为crontab的任务列表文件并载入crontab。如果在命令行中没有指定这个文件，crontab命令将接受标准输入（键盘）上键入的命令，并将它们载入crontab。
- -e：编辑某个用户的crontab文件内容。如果不指定用户，则表示编辑当前用户的crontab文件。
- -l：显示某个用户的crontab文件内容，如果不指定用户，则表示显示当前用户的crontab文件内容。
- -r：从/var/spool/cron目录中删除某个用户的crontab文件，如果不指定用户，则默认删除当前用户的crontab文件。
- -i：在删除用户的crontab文件时给确认提示。

# 文件格式

此处不仅是文件格式，还有在Annotation之中使用的语句的格式。

分 时 日 月 星期几 要执行的命令

- 第1列分钟0～59
- 第2列小时0～23（0表示子夜）
- 第3列日1～31
- 第4列月1～12
- 第5列星期0～7（0和7表示星期天）
- 第6列要运行的命令

![Thumbnail](/img/45b1947d455a43e71d169dba7ca042fea49b6968c1697f3433a1a92e12c5786c.png)

# 使用实例

### 实例1：每1分钟执行一次myCommand

```
* * * * * myCommand
```

### 实例2：每小时的第3和第15分钟执行

```
3,15 * * * * myCommand
```

### 实例3：在上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * * myCommand
```

### 实例4：每隔两天的上午8点到11点的第3和第15分钟执行

```
3,15 8-11 */2  *  * myCommand
```

### 实例5：每周一上午8点到11点的第3和第15分钟执行

```
3,15 8-11 * * 1 myCommand
```

### 实例6：每晚的21:30重启smb

```
30 21 * * * /etc/init.d/smb restart
```

### 实例7：每月1、10、22日的4 : 45重启smb

```
45 4 1,10,22 * * /etc/init.d/smb restart
```

### 实例8：每周六、周日的1 : 10重启smb

```
10 1 * * 6,0 /etc/init.d/smb restart
```

### 实例9：每天18 : 00至23 : 00之间每隔30分钟重启smb

```
0,30 18-23 * * * /etc/init.d/smb restart
```

### 实例10：每星期六的晚上11 : 00 pm重启smb

```
0 23 * * 6 /etc/init.d/smb restart
```

### 实例11：每一小时重启smb

```
* */1 * * * /etc/init.d/smb restart
```

### 实例12：晚上11点到早上7点之间，每隔一小时重启smb

```
0 23-7 * * * /etc/init.d/smb restart
```