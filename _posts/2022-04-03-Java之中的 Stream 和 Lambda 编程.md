---
layout:     post   				    # 使用的布局（不需要改）
title:      Java之中的 Stream 和 Lambda 编程 		# 标题 
subtitle:   一些基本的注意点        #副标题
date:       2022-04-03		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Lambda
    - Stream
---

参考：https://www.liaoxuefeng.com/wiki/1252599548343744/1255943847278976

# 什么是函数式编程

函数式编程，就是说函数可以作为参数来传入函数之中。函数也是一等公民。

Java 是一门 OOP 的语言，其本身并不支持函数式编程，但是从另一个角度看：

> 静态方法可以看做独立的函数（其本身不依赖某个实例），实例方法可以看做自带 this 的函数（要在函数之中传入对象自己）。

> 函数式编程就是一种抽象程度很高的编程范式，纯粹的函数式编程语言编写的函数没有变量，因此，任意一个函数，只要输入是确定的，输出就是确定的，这种纯函数我们称之为没有副作用。而允许使用变量的程序设计语言，由于函数内部的变量状态不确定，同样的输入，可能得到不同的输出，因此，这种函数是有副作用的。

# Lambda 表达式

在 Java 之中，我们经常遇到一大堆FunctionalInterface，也就是只有一个方法的接口。这些接口当然可以通过先 new 一个对象然后再 implement 的方式来使用，但是多少有些繁琐了（因为我们只是想用这一个方法，而不是使用这个对象。相当于我们要一个饼干还必须带盒子）。

使用 Comparator 在 jdk8之前的写法：

```java
String[] array = ...
Arrays.sort(array, new Comparator<String>() {
    public int compare(String s1, String s2) {
        return s1.compareTo(s2);
    }
});
```

所以我们可以使用 lambda 表达式对其进行替换，也就是直接传入一个函数：

```java
public class Main {
    public static void main(String[] args) {
        String[] array = new String[] { "Apple", "Orange", "Banana", "Lemon" };
        Arrays.sort(array, (s1, s2) -> {
            return s1.compareTo(s2);
        });
        System.out.println(String.join(", ", array));
    }
}
```

我们摘出 lambda 的部分：

```java
(s1, s2) -> {
            return s1.compareTo(s2);
        }
```

- `(s1,s2)` ：这部分参数可以省略，因为由传入的 array 可以自动判断出是 String 类型
- `{}`内部是方法体，如果只有一行那么可以省去`{}`。

## 方法引用

还可以直接传入相关的引用，比如：

```java
public class Main {
    public static void main(String[] args) {
        String[] array = new String[] { "Apple", "Orange", "Banana", "Lemon" };
        Arrays.sort(array, Main::cmp);
        System.out.println(String.join(", ", array));
    }

    static int cmp(String s1, String s2) {
        return s1.compareTo(s2);
    }
}
```

我们知道sort 的第一个参数应该是对应的 array，另一个参数应该是一个 Comparator，那为什么后面这个可以直接传入`Main::cmp`呢？

因为**其方法签名和接口恰好一致**。

Comparator\<String> 的接口定义的是`int compare(String, String)`。

我们都知道，对于一个方法而言，签名是三部分：参数类型和数量，方法名和返回值类型、但是在方法引用之中，只看**参数类型**和**返回值类型**两个部分，所以对于 Comparator 来说，我们定义的 cmp 方法和其的*参数*与*返回值*相符，那么就可以传入其中作为替代。但是传入的方法必须是 static 的，不可以是其他的部分。

# Stream

Stream 意味着任意 Java 对象的序列，看起来也可以用 List 来表示，但是二者本质的不同在于，Stream 之中可以存储**一系列的规则**，那么规则可以衍生出来的序列可以是无限的。

比如要存储全体自然数，List 是不可能的，但是 Stream 可以：

```java
Stream<BigInteger> naturals = createNaturalStream(); // 全体自然数
```

然后在输出的时候，对其做一定数量的 limit 限制。

那么对于 Stream 来说，有两个关键的部分：一个是中间状态，只是做一定的规则存储，一个是最终的状态，用来做结果的输出。中间状态，可以理解为只是存储“规则“，

```java
Stream<BigInteger> naturals = createNaturalStream(); // 不计算
Stream<BigInteger> s2 = naturals.map(BigInteger::multiply); // 不计算
Stream<BigInteger> s3 = s2.limit(100); // 不计算
s3.forEach(System.out::println); // 计算
```

## 基本类型

生成 Stream 有几种方法， 都比较基本，有一个生成方法需要注意，那就是 Java 的泛型不支持基本类型，所以无法使用`Stream<int>`这种类型，其会发生编译错误。为了保存`int`，只能用`Stream<Integer>`，这种情况会频繁的产生装箱和拆箱的操作。

为了提高效率（避免过多的拆装想 ），Java 提供了IntStream, LongStream 等等基本类型的 Stream，其使用方法和泛型 Stream没区别，主要是提高效率：

```java
// 将int[]数组变为IntStream:
IntStream is = Arrays.stream(new int[] { 1, 2, 3 });
// 将Stream<String>转换为LongStream:
LongStream ls = List.of("1", "2", "3").stream().mapToLong(Long::parseLong);
```

