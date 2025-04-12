---
layout:     post                       # 使用的布局（不需改）
title:      java.util.function 之中的 function 详解         # 标题 
subtitle:   对jdk8开始引入的function做解读        #副标题
date:       2025-04-12        # 时间
author:     Haiming                         # 作者
header-img: img/post-bg-2015.jpg     #这篇文章标题背景图片
catalog: true                         # 是否归档
tags:                                #标签
    - Programming
---

jdk8 开始引入了 Function, 下面是每一种的简介和例子. 

可见其多数是对元素做操作, 判定

很多functional interface 实际上就是基于某几个类型(比如 supplier/consumer) 加上某种前缀, 作用就是避免在原始类型 primary type 和 包装类型 之间不断做不必要的拆装箱操作, 在性能敏感的情况下可以减少**内存开销, 提高性能**

# BiConsumer\<T, U>

输入两个参数且不返回结果的操作

例子: 输出一个map之中所有的K-V 对

```java
        Map<String, String> map = new HashMap<>();
        map.put("key1","value1");
        map.put("k2","v2");
        BiConsumer<String,String> biConsumer = (k,v) -> System.out.println(k+";"+v);
        map.forEach(biConsumer);
```

输出:

```java
key1;value1
k2;v2
```

# BiFunction\<T, U, R>

输入两个参数T,U, 且**返回一个结果**R的操作

其中有两个方法:

## java.util.function.BiFunction#apply

举例: 输入两个字符串, 输出其拼接:

```java
        BiFunction<String, String, String> biFunction = (v1, v2) -> v1 + "," + v2;
        System.out.println(biFunction.apply("key1", "value1"));
```

输出:

```java
key1,value1
```

## java.util.function.BiFunction#andThen

方法签名为 `default <V> BiFunction<T, U, V> andThen(Function<? super R, ? extends V> after)`, 其接收一个function(after) 作为参数, 先执行 biFunction, 然后再执行其中的 after 作为最终结果

举例: 对两个字符串拼接的输出做进一步的处理:

```java
        BiFunction<String, String, String> biFunction = (v1, v2) -> v1 + "," + v2;
        Function<String, String> after = result -> "output is: "+result;
        BiFunction<String, String, String> concatBiFunction = biFunction.andThen(after);

        System.out.println(concatBiFunction.apply("key1","value1"));
```

输出:

```java
output is: key1,value1
```

# BinaryOperator\<T>

接收两个相同类型的参数, 且返回相同类型参数的结果

举例: 将一个list 之中的所有元素相加

```java
        List<Integer> integerList = List.of(1, 2, 3);
        BinaryOperator<Integer> sum = (a, b) -> a + b;
        System.out.println(integerList.stream().reduce(0, sum));
```

结果

```java
6
```

# BiPredicate\<T, U>

接收两个参数, 且返回布尔值. 

举例: 确定一个字符串是否长度大于要求

```java
        BiPredicate<String, Integer> biPredicate = (s, i) -> s.length() >= i;
        System.out.println(biPredicate.test("abcd", 3));
```

结果:

```java
true
```

# BooleanSupplier

顾名思义, 返回一个boolean. 注意其返回的是primary type, 为的就是在性能敏感的流操作之中直接操作原始类型, 减少内存开销和提高性能.

一般而言, 其内部应该是很复杂的判断逻辑, 但是最后给出一个boolean值. 在需要的时候才进行 boolean 结果的生产.

举例: 查看一个系统的状态.

```java
        BooleanSupplier booleanSupplier = () -> {
            //实际上的status 可以是很复杂的判断之后得到的boolean值
            boolean status = RandomUtils.nextBoolean();
            return status;
        };

        System.out.println("System status is: " + booleanSupplier.getAsBoolean());
```

结果:

```java
System status is: true
```

# Consumer\<T>

接收一个输入参数但是不返回结果的操作.

**注意, 和其他的functional interface 不同, 其期望使用副作用来操作元素.**

```java
List<String> list = Arrays.asList("A", "B");
Consumer<String> printer = s -> System.out.println(s);
list.forEach(printer);  // 输出: A, B
```

# DoubleBinaryOperator

接收两个 double 参数且返回double的参数. 注意这边返回的也是 primary type 的 double, 和上面同理, 为了性能和减少拆装箱的损耗.

举例: 接收两个 double 相乘

```java
        DoubleStream stream = DoubleStream.of(1.5, 2.5);
        DoubleBinaryOperator multiplier = (a, b) -> a * b;
        System.out.println(stream.reduce(1.0, multiplier));  // 输出: 3.75
```

# DoubleConsumer

同上, consumer 的特化版本

```java
DoubleStream stream = DoubleStream.of(1.1, 2.2);
DoubleConsumer consumer = d -> System.out.println(d);
stream.forEach(consumer);  // 输出: 1.1, 2.2
```

# DoubleFunction\<R>

Function的 double 特化版本

```java
DoubleFunction<String> toString = d -> "Value: " + d;
System.out.println(toString.apply(3.14));  // 输出: Value: 3.14
```

# DoublePredicate

特化版本, 说厌了

```java
DoubleStream stream = DoubleStream.of(1.1, 2.2, 3.3);
DoublePredicate predicate = d -> d > 2.0;
stream.filter(predicate).forEach(System.out::println);  // 输出: 2.2, 3.3
```

# DoubleSupplier

```java
DoubleSupplier random = Math::random;
System.out.println(random.getAsDouble());  // 输出: 随机值 (如 0.73)
```

# DoubleToIntFunction

对于 ToIntFunction 的 double 类型的特化.

```java
DoubleToIntFunction floor = d -> (int) Math.floor(d);
System.out.println(floor.applyAsInt(3.7));  // 输出: 3# DoubleToLongFunction
```

# DoubleToLongFunction

ToLongFunction 的 double 特化

```java
DoubleToLongFunction toLong = d -> (long) d;
System.out.println(toLong.applyAsLong(3.7));  // 输出: 3
```

# DoubleUnaryOperator

UnaryOperator 的 double 特化

```java
DoubleStream stream = DoubleStream.of(1.0, 2.0);
DoubleUnaryOperator square = d -> d * d;
stream.map(square).forEach(System.out::println);  // 输出: 1.0, 4.0
```

# 特化版本不再举例

# Function\<T, R>

接收一个输入参数 T, 返回对应 R 类型的结果

```java
        Function<String, Integer> function = s -> Integer.parseInt(s);
        System.out.println(function.apply("12")); // 输出 12
```

# Supplier\<T>

返回一个类型 T 的结果. 作用为在流式处理之中, 在真正执行时候才进行 T 类型对象的生成

```java
Supplier<String> defaultSupplier = () -> "Default";
String value = Optional.ofNullable(null).orElseGet(defaultSupplier);  // 输出: Default
```

# UnaryOperator\<T>

下面是方法签名:

`public interface UnaryOperator<T> extends Function<T, T>`

可见其就是 T, R 相同的 Function 的一种特化情况. 接收一个参数并且返回相同类型结果的操作.
