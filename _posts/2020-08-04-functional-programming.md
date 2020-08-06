---
layout:     post   				    # 使用的布局（不需要改）
title:      学习函数式编程  		# 标题 
subtitle:   对一些基本概念的理解和掌握        #副标题
date:       2020-08-04		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - functional programming
---

简直就像是递归一样……学Scala之前我们要先弄懂什么是函数式编程。

来吧！让暴风雨来的更猛烈些吧！

笔者先来一句直接概括：

**函数式编程，是只关注操作而不关注实现的一种编程方式。函数可以作为参数传入另一个函数，且不改变传入参数的值。**

参考资料：

https://coolshell.cn/articles/10822.html

http://www.ruanyifeng.com/blog/2012/04/functional_programming.html

由于一些概念比较晦涩难懂，所以本文倒过来，先举例证明笔者的概括是如何得到的，再进行概念上面的总结。本文采用“分-总”结构。

# 1. 函数式编程举例

先看一个连加的对比：

```java
public class addThenAdd {
    public static void main(String[] args) {
        System.out.println(add2(5));
        System.out.println(add5(5));
    }

    public static Integer add2(Integer a) {
        return a + 2;
    }

    public static Integer add5(Integer a) {
        return a + 5;
    }
}
```

如果我们想改一下呢？改成将一个数加上10？那我们的办法就是再写一个函数+10。

当然，有人会问：你为什么不直接传两个参数呢？因为这只是示例啊……

函数式编程怎么写：

```scala
def inc(x):
    def incx(y):
        return x+y
    return incx

inc2 = inc(2)
inc5 = inc(5)

print inc2(5) # 输出 7
print inc5(5) # 输出 10
```

在一个函数之中定义了另一个函数，也就是**将函数当成变量来使用**，关注于**如何描述问题而不是如何实现。**

## 1.1 Map & Reduce

在函数式编程之中，不需要循环迭代和一些额外的变量操作，而是可以直接将操作和对应的数据放在一起传入参数。这也是函数式编程更清晰的一个原因。

```python
name_len = map(len, ["one","two","three"])
print name_len
```

如果java的话，实现方式是将三个字符串传入，然后单独再搞一个数组，一个for循环将其进行长度输出之后返回新的包含长度的数组。这显然是非常麻烦的。

**这样的代码是描述要干什么，而不是怎么干。这是函数式编程更加清晰的一个原因。**

再看一个全部变成大写的例子：

```python
def toUpper(item):
return item.upper()

upper_name = map(toUpper, ["hao", "chen", "coolshell"])
print upper_name
# 输出 ['HAO', 'CHEN', 'COOLSHELL']
```

这个函数里面，只是将传入的值进行一个操作，然后返回。

当然，对于map我们还可以使用lambda表达式，简单理解的话，这个就是一个inline的匿名函数。计算平方的函数可以这样翻译：

```python
squares = map(lambda x: x * x, range(9))
print squares
# 输出 [0, 1, 4, 9, 16, 25, 36, 49, 64]
```

其中lambda之后的参数就是这个表达式之中的变量，后面的计算就是函数体的内容。而`range(9)`意味着从0到9.

> 笔者个人理解：map就是将某一范围之内的参数都做相同的操作，而reduce就是将所有在某一范围之内的参数进行运算合并。比如下面的python例子：
>
> ```python
> print reduce(lambda x, y: x+y, [1, 2, 3, 4, 5])
> # 输出 15
> ```

引用一下原作者的辨析：

相比于指令式编程，函数式编程有下面的好处：

1. 代码更加清晰简单
2. 将数据集，操作和返回值都放在了一起
3. 函数式编程之中没有中间量保存状态，从而没有了循环体。于是就可以少一些循环变量以及将其倒来倒去的逻辑。
4. 代码是干什么的描述，而不是怎么干。

Map在实现的时候，实际上是通过栈来将其中间状态保存，既然只能以递归的形式来写，那么最好写尾递归，这样可以自动优化成循环。

下面是JS代码示例。

```javascript
//map函数
var map = function (mappingFunction, list) {
    var result = [];
    forEach(list, function (item) {
        result.push(mappingFunction(item));
    });
    return result;
};
```

相对而言，函数式编程比较大的不同点在于其不依赖外部的变量来同步状态——每次我都是返回一个新的变量，那么其就非常非常适合并行的任务。

