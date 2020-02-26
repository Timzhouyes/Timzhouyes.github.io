---
layout:     post   				    # 使用的布局（不需要改）
title:      Class源码解析  		# 标题 
subtitle:           #副标题
date:       2020-02-26		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Java
    - 源码
---

本篇是[小周和你读源码(1)](https://timzhouyes.github.io/2019/12/18/Java-Code1/) 系列的文章。

本是准备先看Boolean类，但是发现其中涉及到了太多关于Class类的内容，如果不先了解 Class 类，很难进一步将其讲清，因此转而先写本文。

还是先从概述开始吧。

# 概述

```java
/**
 * Instances of the class {@code Class} represent classes and
 * interfaces in a running Java application.  An enum is a kind of
 * class and an annotation is a kind of interface.  Every array also
 * belongs to a class that is reflected as a {@code Class} object
 * that is shared by all arrays with the same element type and number
 * of dimensions.  The primitive Java types ({@code boolean},
 * {@code byte}, {@code char}, {@code short},
 * {@code int}, {@code long}, {@code float}, and
 * {@code double}), and the keyword {@code void} are also
 * represented as {@code Class} objects.
 *
 * <p> {@code Class} has no public constructor. Instead {@code Class}
 * objects are constructed automatically by the Java Virtual Machine as classes
 * are loaded and by calls to the {@code defineClass} method in the class
 * loader.
 *
 * <p> The following example uses a {@code Class} object to print the
 * class name of an object:
 *
 * <blockquote><pre>
 *     void printClassName(Object obj) {
 *         System.out.println("The class of " + obj +
 *                            " is " + obj.getClass().getName());
 *     }
 * </pre></blockquote>
 *
 * <p> It is also possible to get the {@code Class} object for a named
 * type (or for void) using a class literal.  See Section 15.8.2 of
 * <cite>The Java&trade; Language Specification</cite>.
 * For example:
 *
 * <blockquote>
 *     {@code System.out.println("The name of class Foo is: "+Foo.class.getName());}
 * </blockquote>
 *
 * @param <T> the type of the class modeled by this {@code Class}
 * object.  For example, the type of {@code String.class} is {@code
 * Class<String>}.  Use {@code Class<?>} if the class being modeled is
 * unknown.
 *
 * @author  unascribed
 * @see     java.lang.ClassLoader#defineClass(byte[], int, int)
 * @since   JDK1.0
 */
public final class Class<T> implements java.io.Serializable,
                              GenericDeclaration,
                              Type,
                              AnnotatedElement 
```

首先，第一段举例了在Java之中的所有class和interface都是class，哪怕是基本类型，例如bool等等也是class。

class之中没有公共的constructor，代替的，Class 对象是被Java VM 自动建立的。

# 内部对象

```java
    private static final int ANNOTATION= 0x00002000;
    private static final int ENUM      = 0x00004000;
    private static final int SYNTHETIC = 0x00001000;

    private static native void registerNatives();
    static {
        registerNatives();
    }
```

可以显然看出其是下面判定之中所需要的static 值，下面在具体使用的时候会解释。而这些值的判定方式也是和其他一样，每一个都是之前的2倍，符合二进制的值分配规则。

下面这个`registerNatives()`方法前面有 native 修饰，而且其中没有任何代码块，这意味着其为一个 jvm 层面的问题，其只是相当于声明了一个 jvm 对外界暴露的接口。同时，下面这种用static 将其包裹的形式，作用为将其执行。如果没有这个static包裹，那么其只是会被声明而不会被执行。

# 方法

1. 构造方法：

   前面讲了，