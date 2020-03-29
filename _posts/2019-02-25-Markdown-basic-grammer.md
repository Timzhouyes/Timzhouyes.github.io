---
layout:     post   				    # 使用的布局（不需要改）
title:      Markdown basic grammer 				# 标题 
subtitle:   Basic grammer of Markdown #副标题
date:       2019/02/25			# 时间
author:     Timzhou						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Markdown
    - Programming
    - Programming
---

对了Markdown没有缩进……缩进是CSS的事情，或者说将输入法切换成全角之后用力双击两下空格也是土办法hhh
# 1.Title
Markdown mark the title with "# ", notice there is a space after '#'. And if you want to create multilevel of titles, such as 
## Second level title
### Third level title
#### Fourth level title
You can just use "## " to create a second level title and so on.The maximum level of title is 6


# 2.List
There are two kinds of lists in Markdown:ordered list and Unordered list. 
####Unordered list add '-' or '*' before 
##### Unordered list
* Apple
- Peer
- Mango
#### Ordered list add 'number.' before, such as '1. ' and don't forget the space
##### Inorder list
1. Apple
2. Peer 
3. Mango

# 3. Quote
Quote format is like this one: add '> 'before the sentence.Also don't forget the space~
Besides,if you put two lines of quotes together, it will only show one Quote
> Quote thing here.
> Quote things there

# 4.Pictures and Links
Add pictures:
> ![PictureName] (http://your-picture-is-here.com)

Add links:
> [LinkName] (http://I-want-this-link.com)

Here is sample:

![Science](https://raw.githubusercontent.com/Timzhouyes/Timzhouyes.github.io/master/img/post-bg-re-vs-ng2.jpg)
#[Welcome to TimZhou's blog](https://timzhouyes.github.io/)

# 5.Bold and Italic
### Bold:
Use two * contain the format of Bold

**Here is my Bold**

### Italic
Use one * contain the format of Italic

*Here is my Italic*

# 6.Tables
Well......The table is a tiring part.Let's look at the format first:

this|is|a|table

-|-:|:-:|:-

First|Line|of|table
Second|line|of|table
### And the output is:

this|is|a|table
-|-:|:-:|:-
First|Line|of|table
Second|line|of|table

In the table, we can use left-justifying with ':---' , and use right-justifuing with '---:'

if you wanna use align center, you can use ':---'

Also you can put other formats with table~ whatever you want

# 7.Codes
Just use ``` to wrap the code block and you will make it.
```
public static void main(){
	console.writeline("this is a part of code");
}
```
	
# 8.Splits
You can draw a split with 3 *
Like :
***

So this is the end of this blog. If you have any questions, please tell me and we can discuss together~~~
