---
layout:     post   				    # 使用的布局（不需要改）
title:      浅析JavaScript之中的let和const			# 标题 
subtitle:    #副标题
date:       2019-04-15 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 日常
    - 记录
    - Study
    - JavaScript
---
在ES6之中，新增了let和const的变量形式，在阅读了[阮一峰老师的ES6](http://es6.ruanyifeng.com/#docs/let)教程之后，做一点基础的分析和总结。

先上一张表格：


|声明方式|变量提升|暂时性死区|重复声明|初始值|作用域|
|--------|--------|----------|----|---|---|
|var|允许|不存在|允许|不需要|除块级|
|let|不允许|存在|不允许|不需要|块级|
|const|不允许|存在|不允许|需要|块级|


# 1. Let
## 1.1 基本用法

ES6之中新增了 let 命令用于声明变量，这个变量类型的加入使其终于有了只在块级作用域起作用的变量类型。

例如在for循环之中，就很适合使用let命令作为赋值的变量。

```
var a = [];
for (let i = 0; i < 10; i++) {
  a[i] = function () {
    console.log(i);
  };
}
a[6](); // 6
```

在这种情况之下， 其实每一次的let都是一个新的变量，其每次都知道上一轮循环的值，是因为JavaScript引擎的内部自动记住上一轮循环的值，所以每次循环+1的时候，其都会在上一轮循环的基础上进行计算。

除此之外，for循环的特别之处在于设置循环变量的部分是一个父作用域，而循环体内部是一个单独的子作用域。

```
for (let i = 0; i < 3; i++) {
  let i = 'abc';
  console.log(i);
}
// abc
// abc
// abc
```
上面这部分代码运行结果是输出三次 abc ，说明函数内部的`i`和函数外部的`i`不是一个变量，其各自有各自的作用域。

### 但是如果参数已经声明了的变量，那么函数体内不可以使用`let`进行再次声明。下面这段代码会直接报错：

```
function func(arg=0){
    let arg=0;
}
func();
```

其就是因为上面所提到的原因。

## 1.2 不存在 `变量提升`

在`var`命令之中，会发生“`变量提升`”现象，即变量可以在声明之前就被使用，其值为`undefined`。

但是在`let`之中，这种现象被纠正了。使用`let`声明的变量必须在声明之后使用， 不然会直接报错．


```
// var 的情况
console.log(foo); // 输出undefined
var foo = 2;

// let 的情况
console.log(bar); // 报错ReferenceError
let bar = 2;
```

上面的代码之中 , 如果用到了`let`的话，会直接报错。

## 1.3 暂时性死区
只要块级作用域之中存在`let`命令，其所声明的变量就会暂时被“绑定”在这个区域，不会再受外部变量的影响。

也就是说，在块状区域之中可以使用外部`var`相同名字的变量，但是其可以只在内部操作，并且只在内部起作用。

```
var tmp = 123;

if (true) {
  tmp = 'abc'; // ReferenceError
  let tmp;
}
```

上面代码之中的错误是因为本来有全局变量`tmp`，但是在块级作用域`let`之中又重新声明了一个局部变量`tmp`，这就导致了后者绑定到了块级作用域，所以`let`在声明变量之前对`tmp`赋值就会报错。

ES6之中规定，代码块之中存在`const`或者`let`命令的话，在代码块之中对命令声明的变量，一开始就形成封闭作用域，那么在声明之前就使用这些变量的话，例如对变量进行赋值，就会报错。

总之，暂时性死区的本质就是，只要进入当前作用域的代码块，那么所要定义的，例如let或者const的变量就已经存在了，只是不可以使用。 只有等到声明变量的那一行代码出现，其才可以被获取和使用。

## 1.4 不允许重复声明

`let`不允许在相同作用域之内，重复声明同一个变量。

```
// 报错
function func() {
  let a = 10;
  var a = 1;
}

// 报错
function func() {
  let a = 10;
  let a = 1;
}
```

因此，在函数内部重新声明参数是不被允许的。

```
function func(arg) {
  let arg;
}
func() // 报错

function func(arg) {
  {
    let arg;
  }
}
func() // 不报错
```

# 2.块级作用域
## 2.1 块级作用域的代码影响范围
ES6之中的`let`实际上给JavaScript增加了块级作用域。

```
function f1() {
  let n = 5;
  if (true) {
    let n = 10;
  }
  console.log(n); // 5
}
```

上面这段代码最后输出是5，说明在块级作用域外层的代码不受块级作用域的代码影响。将上面这段代码的`let`换成`var`，那么最后输出的结果会变成10.

## 2.2 块级作用域的嵌套

```
{
  {let insane = 'Hello World'}
  console.log(insane) // 报错
};
```

这句代码之中使用了两层的块级作用域，且外层的作用域无法得到内层作用于的变量。

# 3. const命令
## 3.1 基本用法

`const`声明一个只读的常量。一旦声明之后，常量的值就不可以改变。

```
const PI = 3.1415;
PI // 3.1415

PI = 3;
// TypeError: Assignment to constant variable.
```

上面的这段代码意味着改变常量的值会直接报错。

`const`声明的变量不可以改变值，这就意味着，`const`一旦声明变量，就立刻要初始化，不可以留到以后在进行赋值。

```
const foo;
// SyntaxError: Missing initializer in const declaration
```

这段代码表示，对于`const`而言，只声明不赋值，会直接报错。

`const`声明的变量只在声明的块级作用域之内有效，这一点和`let`相同。同样的，`const`存在暂时性死区，只可以在声明的位置后面使用。`const`也不可以重复声明。

```
if (true) {
  const MAX = 5;
}

MAX // Uncaught ReferenceError: MAX is not defined
```

```
if (true) {
  console.log(MAX); // ReferenceError
  const MAX = 5;
}
```

重复声明报错代码：

```
var message = "Hello!";
let age = 25;

// 以下两行都会报错
const message = "Goodbye!";
const age = 30;
```

## 3.2 本质
`const`实际上保证的是：*变量所指向的内存地址的保存数据* 不可改动。

因此，对于简单类型的数据（数值，字符串，布尔值）， 值就保存在变量指向的那个内存地址，也就等同于常量。 但是对于复合类型的数据，例如对象和数组，变量所指向的内存地址只是一个指向实际数据的指针，`const`只可以保证这个指针是固定的，即总是指向另一个固定的地址，但是其指向的数据是不是可变的，就完全不能控制。所以将对象声明为常量要格外小心。

```
const foo = {};

// 为 foo 添加一个属性，可以成功
foo.prop = 123;
foo.prop // 123

// 将 foo 指向另一个对象，就会报错
foo = {}; // TypeError: "foo" is read-only
```

在上面这个例子之中，可以为`foo`添加属性，但是不可以将其指向另外一个对象。
