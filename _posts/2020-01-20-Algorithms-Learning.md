---
layout:     post   				    # 使用的布局（不需要改）
title:      算法学习  		# 标题 
subtitle:   开篇与第一章基础        #副标题
date:       2020-01-20		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - 算法
---

要想当一个好的程序员，算法功底是必不可少的。种一棵树最好的时间是十年前，然后是现在。开搞！

我学习算法所使用的书籍是那本红皮的《算法》。 

下面是一些自己总结的知识点，大部分比较零碎，就当做是个人笔记了吧。

# 第一章 基础

## 1.1 基础编程模型

### 1.1.10.1 二分查找

二分查找之中，我对其函数的结束条件感到十分精妙，先放代码：

```java
package Cha1Sec1;

/**
 * Array must be sorted.Function is to find position of  'key' in 'array'.
 */
public class BinarySearch {
    public static Integer rank(Integer key, Integer[] array) {
        int lo = 0;
        int hi = array.length - 1;
        while (lo <= hi) {
            int mid = lo + (hi - lo) / 2;
            if (key < array[mid]) hi = mid - 1;
            else if (key > array[mid]) lo = mid + 1;
            else return mid;
        }
        return -1;
    }
}

```

可见其逻辑就是 每次对中间下标的数值和 key 进行比较，如果 中间数值 > key ，那么就在前半段进行查找，不然就后半段进行查找。若刚好相等，说明找到了值，直接返回。如果一直找不到，就直接返回 -1。

这段逻辑是非常简单的，让我觉得有趣的是其退出条件。

![image-20200128104358752](../img/image-20200128104358752.png)

可见对于50这个非命中案例，其退出条件是 lo 在 hi 的后一位，即其是通过主动操作下标使其不满足while循环的条件从而退出的。

#### 答疑

1. ```java
   Math.abs(-2147483648) 的返回值是什么？
   ```

   返回值是其本身，-2147483648。 其是整数溢出的典型例子。同时在java 的Math 类的源码也是一样写的：

   ```java
    /**
        * Returns the absolute value of an {@code int} value.
        * If the argument is not negative, the argument is returned.
        * If the argument is negative, the negation of the argument is returned.
        *
        * <p>Note that if the argument is equal to the value of
        * {@link Integer#MIN_VALUE}, the most negative representable
        * {@code int} value, the result is that same value, which is
        * negative.
        *
        * @param   a   the argument whose absolute value is to be determined
        * @return  the absolute value of the argument.
        */
       public static int abs(int a) {
           return (a < 0) ? -a : a;
       }
   ```

   如果其值和Integer的最小值相同，那么其返回的值是这个最小值本身。

2. 嵌套语句之中的 if 的二义性有问题：

   if \<expr1> if \<expr2> \<stmntA> else \<stmntB>  等价于:

   if \<expr1> { if \<expr2> \<stmntA> else \<stmntB> }

   即使我们实际上想要表达的意思是：

   if \<expr1> { if\<expr2> \<stmntA> } else \<stmntB>

   所以最好的做法就是显式的声明所有大括号。

### 习题

习题部分我会写一些自己的思路和心得，在github上面也会同步更新代码。

### 1.2 数据抽象

#### 1.2.1 使用抽象数据类型

1. 在Java之中，**所有的数据类型**都会继承 toString() 方法，来返回调用String表示的该类型的值。但是其默认实现是返回这个对象在内存之中的地址，这个并不实用，因此我们要重载默认实现。

   **所有的数据类型**还会继承 `equals()` , `compareTo()`, `hashCode()` 等等。下面会详细叙述。

2. 在新建一个实例对象的时候，一般我们会写 `Class1 class1 = new Class1()`，之前总是不明白为什么，现在清楚了。在写这一行代码的时候，我们实际是出发了 `Class1` 的默认无参构造函数，这个默认的构造函数的返回值就是 `Class1`，所以新建一个实例对象和使用一个函数没有什么本质的区别。
3. 我们都知道，对象是通过地址来操作的，那么在使用 `new()` 函数之后，实际上会做下面几步操作：
   1. 为新的对象分配空间
   2. 调用 **构造函数** ，初始化对象的值
   3. 返回对象的地址。
4. 静态方法调用的开头是类名，按习惯是大写，而非静态方法调用的开头一般是实例化的对象。静态方法不需要实例化就可以使用。
5. 在Java之中，例如 `Counter[]` 这种内部存储的是 `Counter`的地址而非值。所以其在对象的体积很大的时候可以起到增加效率的作用（地址不会因为数据量大而变大），但对于体积小的对象反而是一种浪费（拿到地址之后还要查找值，不如直接操作值快一些）
6. 正则表达式之中，典型的字符串处理代码是`"\\s+`，其表示一个或者多个制表符，空格，换行符或者回车。

#### 1.2.5 数据类型的设计

##### 等价性

等价性需要：

1. 自反性：`x.equals(x)`必须为true
2. 对称性：当且仅当`y.equals(x)`为true的时候，`x.equals(y)`为true
3. 传递性：如果`x.equals(y)`和`y.equals(z)`为true，那么`x.equals(z)`为true

另外其必须接收一个Object 为参数，并且满足下面性质：

1. 一致性：当两个对象均未被修改的时候，反复调用`x.equals(y)`总是会返回相同的值
2. 非空性：`x.equals(null)`总是返回false

##### 如何设计`equals(Object o)`

书中介绍了一种方法，虽然是针对其Date加入的，但是我认为可以在很多情况下复用。思路如下：

1. 看 this 和 o 是否为同一个引用，如果是的话，直接返回true
2. 看 o 是否为 null，如果是的话，直接返回false
3. 看 this 和 o 是否为一样的类型，使用`getClass()`方法进行确认，如果不是，直接返回false
4. 将Object 转换成对应的Class（上一步的判断通过之后一定可转），按项比较其值是否相同。

搞个示例：

```java
package Code.Cha1Sec2DataAbstract;

public class Counter {

    Integer countTime;

    public boolean equals(Object x) {
        if (this == x) return true;
        if (x == null) return false;
        if (this.getClass() != x.getClass()) return false;
        //Then can make sure the class is a 'Counter' class and do type convert
        Counter c = (Counter) x;
        if(this.countTime != c.countTime) return false;
        return true;
    }
}

```

##### final的局限性

一般来说，对于没有值改变方法的类型，我们使用final修饰，比如Date或者String，其中并没有直接操作值的方法。但是final有一定的局限性，那就是其只能锁定**基本类型**的值，而不能锁定**引用类型**的值。

对于引用类型，其只能锁定这个指针所指向的地址不改变。意味着，**其将永远指向同一个对象，但是所指向的对象的值可以改变**。

在本书之中，final所用来保证的是算法的正确性。比如在二分查找算法之中，如果数据本身是可变的，那么很有可能就会违背了我们”数据是按序排列“这样的默认背景，那也就没办法进行接下来的计算了。

### 1.3 背包，队列和栈

本节目标为：

1. 展示集合之中对象的表现方式可以直接影响各种操作的效率。
2. 介绍**泛型**和**迭代**。
3. 介绍并说明**链式结构**的重要性，特别是经典数据结构：链表。

#### 1.3.1.2 自动装箱

类型参数必须被实例化成*引用类型*，