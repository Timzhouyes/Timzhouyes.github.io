---
layout:     post   				    # 使用的布局（不需要改）
title:      Scala Study  		# 标题 
subtitle:   Some defination and example code        #副标题
date:       2020-08-04		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Scala
---

Found that if you want to know how to operate Spark, it is better to know how to use Scala.

So learn Scala first~

Scala is a language which based on JVM, and there are a lot of similarities between Scala and Java. If you have a solid Java experience, you can be familiar with Scala very quickly.

[Offical tutorial](https://docs.scala-lang.org/tour/tour-of-scala.html)

[Reference](https://www.tutorialspoint.com/scala/index.htm)

# 0. Hello world

Every time I learn a new programming language, I always start with Hello World. This time also :)

```scala
object HelloWorld{
  def main(args:Array[String]):Unit = {
    println("Hello world")
  }
}
```

# 1. Basic Introduction and Syntax

Tell a joke, the biggest difference between Java and Scala is "Scala does't need to provide ";" at the end of sentence."

Talk about it briefly.

1. `Object`: Object is an instance of a class. Example: a dog has states. The reason why we use `object` in the `HelloWorld` is that we only use it by Singleton. 
2. `Class`: Blueprint of object, describes behaviors and states.
3. `Methods`: The behavior in class, showing how things to be done.
4. `Fields`: One object's state is created by the values assigned to these fields.
5. `Closure`: One function that return value depends on the value of one or more variables declared outside the function.
6. `Traits`: Like `interface`  in java, and encapsulates method and field definitions. Traits are used to define object types by specifying the signature of supported methods.

## 1.1 Syntax

Here are some basic syntaxes in Scala programming

1. Case sensitivity: Scala is case sensitive, take example, `Hello` and `hello` is different in Scala.
2. Class names: For all class names, the first letter should be in Upper Case. 
3. Method names: All method names should start with a Lower Case letter. Like `def myMethodName()`
4. Program File Name: **Name of the program file should exactly match the object name**. If use `HelloWorld` then the file name should be `HelloWorld.scala`
5. `def main(args: Array[String])`: Scala program process starts from the main() method, which is a **mandatory** part if Scala program.

Scala keywords:

| abstract  | case     | catch    | class   |
| --------- | -------- | -------- | ------- |
| def       | do       | else     | extends |
| false     | final    | finally  | for     |
| forSome   | if       | implicit | import  |
| lazy      | match    | new      | Null    |
| object    | override | package  | private |
| protected | return   | sealed   | super   |
| this      | throw    | trait    | Try     |
| true      | type     | val      | Var     |
| while     | with     | yield    |         |
| -         | :        | =        | =>      |
| <-        | <:       | <%       | >:      |
| #         | @        |          |         |

## 1.2 Some interesting points

Scala can do without line breakers(";"), but if somebody wants to place several sentences in one line then needed to use it to seperate these lines.

## 1.3 Blocks

Some expressios surrounding by `{}` can be called `block`.

There can be a lot of expressions in one block, but only value of the last sentence will be treated as the result of the whole block. Like:

```scala
object Run {
  def main(args: Array[String]): Unit = {
    println({
      val x=1+1
      x+1
    })
  }
}
```

This one will output `3` .Because `x+1` is the last sentence.

## 1.4 Functions

Remember what we said on the last blog "Functional programming"? In functional programming, fuction is the fisrt kind of member, which means it can be given value and can be treat as `val`.Like:

```scala
object Run {
  def main(args: Array[String]): Unit = {
    println(add(1))
  }

  val add = (x: Int) => x + 1
}
```

We can see here that we define a annoymous function, and then make it a `val`. After that, we passed value of the parameter in, then we can use the function as a value. 

**Also in methods, The last expression in the body is the method’s return value. (Scala does have a `return` keyword, but it is rarely used.)**

## 1.5 Case class

This is the kind of class which Scala has. By default, instances of case classes are `immutable`, and they are compared `by value`, not reference. Can say this make it easier for `pattern matching`.

Take an example:

```scala
case class Point1(x: Int, y: Int)
```

```scala
  val point = Point1(1, 2)
  val point2 = Point1(1, 2)
  val anotherPoint = Point1(1, 2)

if (point == point2) {
      println(point + " and " + point2 + " are the same")
    } else {
      println(point + " and " + point2 + " are different")
    }
```

And result is:

`Point1(1,2) and Point1(1,2) are the same`

## 1.6 Traits

Traits are abstract data types containing certain fields and methods.

In Scala inheritance, a class can only extend one other class, but can extend multiple `Traits`. It is like interface of Java, but can have default implementations.

Take example:

```scala
trait Greeter {
  def greet(name:String):Unit={
    println("hello "+name)
  }
}
```



```scala
class DefaultGreeter extends Greeter

class CustomizableGreeter(prefix:String,suffix:String) extends Greeter {
  override def greet(name: String): Unit = {
    println(prefix+"This is greet from customizable greet, "+name+" "+suffix)
  }
}

object Run{
  def main(args: Array[String]): Unit = {
    val greeter = new DefaultGreeter
    greeter.greet("Scala developer")

    val customGreeter = new CustomizableGreeter("Prefix","Suffix")
    customGreeter.greet("Just a name")
  }
}

```

# 2. Data types

Because all base on JVM, so Scala has he same memory footprint and precision with Java. Following is the details and data types in Scala. 

But there are still some different parts between Java and Scala:

1. `Unit`: like `void` in Java, means no return value.
2. `Nothing`: **subtype** of every other type, includes no values.
3. `Any`: **supertype** of every other type, **any object is of type Any**
4. `AnyRef`: **supertype** of **reference** type

And **all data types list above are objects.** This means that there are no primitive types like in Java.

| Sr.No |                   Data Type & Description                    |
| ----- | :----------------------------------------------------------: |
| 1     |      **Byte**8 bit signed value. Range from -128 to 127      |
| 2     |     **Short**16 bit signed value. Range -32768 to 32767      |
| 3     | **Int**32 bit signed value. Range -2147483648 to 2147483647  |
| 4     | **Long**64 bit signed value. -9223372036854775808 to 9223372036854775807 |
| 5     |       **Float**32 bit IEEE 754 single-precision float        |
| 6     |       **Double**64 bit IEEE 754 double-precision float       |
| 7     | **Char**16 bit unsigned Unicode character. Range from U+0000 to U+FFFF |
| 8     |                **String**A sequence of Chars                 |
| 9     |   **Boolean**Either the literal true or the literal false    |
| 10    |               **Unit**Corresponds to no value                |
| 11    |               **Null**null or empty reference                |
| 12    | **Nothing**The subtype of every other type; includes no values |
| 13    | **Any**The supertype of any type; any object is of type *Any* |
| 14    |        **AnyRef**The supertype of any reference type         |

## 2.1 Scala Basic Literals

### 2.1.1 Integer Literals

Integer literals are usually of type Int, or of type Long when followed **by a L or l suffix**. Here are some integer literals −

```scala
0
035
21 
0xFFFFFFFF 
0777L
```

### 2.1.2 Floating Point Literals

Floating point literals are of type Float when followed by a floating point type **suffix F or f**, and are of type Double otherwise. Here are some floating point literals −

```scala
0.0 
1e30f 
3.14159f 
1.0e100
.1
```

### 2.1.3 Boolean Literals

true / false.

### 2.1.4 Symbol Literals

> Case class; the type of class Scala use to process some pattern.

Symbol is also a case class, which can be defined as follows:

```scala
package scala
final case class Symbol private (name: String) {
   override def toString: String = "'" + name
}
```

### 2.1.5 Character Literals

A character literal is a single character enclosed in quotes.Either a printable Unicode character or an escape sequence can be described by character. Here are some examples:

```scala
'a' 
'\u0041'
'\n'
'\t'
```

### 2.1.6 String Literals

A string literal is a sequence of characters in double quotes.

```scala
"Hello,\nWorld!"
"This string contains a \" character."
```

### 2.1.7 Multiline Strings

use `""" ... """`

```scala
"""the present string
spans three
lines."""
```

### 2.1.8 Null Values

A **reference** value which refers to a special "null" object.

# 3. Classes, Objects and Type Hierarchy

First, let us see on picture:

![Scala Type Hierarchy](/img/2020-08-04-Scala-study/unified-types-diagram.svg)

This diagram shows a subset of type hierarchy.

Can see from this diagram that `Any` is the supertype of all types. It is also called `top type`. In `Any`, it defined certain universal methods such as `equals`, `hashCode` and `toString`. 

`Any` has 2 subclasses, one is `AnyVal`, one is `AnyRef`, which corresponds `java.lang.Object`.

`AnyVal` represents value types. There are nine predifined value types and are **non-nullable**:

1. Double
2. Float
3. Long
4. Int
5. Short
6. Byte
7. Char
8. Unit
9. Boolean

`Unit` is a little special in Scala, which carries no meaningful information. There is exactly one instance of `Unit` which can be decleared literally like `()`. Because **all functions must return something**, so sometimes `Unit` is a useful return type. 

Take an example:

```scala
  val unit: Unit = {
    3+4
  }

  def main(args: Array[String]): Unit = {
    println(unit)
  }
```

Guess what is the output?

```
()
```

So assign any value to `Unit` is meaningless. 

Because `Any` is supertype of all classes, so if we pass `Any` as the type, we can give any type of value to the list. Example:

```scala
val list: List[Any] = List(
  "a string",
  732,  // an integer
  'c',  // a character
  true, // a boolean value
  () => "an anonymous function returning a string"
)

list.foreach(element => println(element))
```

Output is:

```scala
a String
732
false
c
main.Run$$$Lambda$1/1919892312@6833ce2c
```

The last one represent a function. Because all elements are instance of `Scala.any`,so we can add them to one list.

## 3.1 Type casting

![Scala Type Hierarchy](/img/2020-08-04-Scala-study/type-casting-diagram.svg)

Also example first :)

```scala
  val x: Long = 123456789012L
  val y: Float = x
  val face: Char = '☺'
  val number: Int = face

  def main(args: Array[String]): Unit = {
    println(x)
    println(y)
    println(face)
    println(number)
  }
```

And output is:

```scala
123456789012
1.23456791E11
☺
9786
```

So above is example of casting. But casting is unidireactional. Like below can not compile.

```scala
  val x: Long = 123456789012L
  val y: Float = x
  val z: Int = x
```

Compiler will show:

```scala
type mismatch;
 found   : Long
 required: Int
  val z: Int = x
```

## 3.2 Nothing and Null

`Nothing` is a subtype of **all types**, also called the bottom type. There is **no value** that has type `Nothing`. A common use is to signal non-termination such as throw an Exception, program exit or infinite loop.

`Null` is a subtype of **all reference types** (any subtype of  `AnyRef`). It has **a single value** identified by keyword `null`. `Null` is provided for interperablity with other JVM languages, and should never be used in Scala code. Do you remember that we said all functions have to return a value?

## 3.3. Classes

A class is like below:

```scala
class Point(var x: Int, var y: Int) {
  def move(dx: Int, dy: Int): Unit = {
    x = x + dx
    y = y + dy
  }

  override def toString: String = {
    s"($x,$y)"
  }
}
```

`Point` class has **4 members**, the variables `x` and `y`, and method `move` and `toString`. 

To use a class, we can use `new` to create an instance of class. 

Constuctors can have optional parameters by providing a default value like so:

```scala
class Point(var x: Int = 0, var y: Int = 0)
```

## 3.4 Private members and Getter/Setter Syntax

A little complex but interesting. Example first:

```scala
class Point {
  private var _x: Int = 0
  private var _y: Int = 0
  private val bound: Int = 100

  def x = _x

  def x_=(newValue: Int): Unit = {
    if (newValue < bound) _x = newValue else printWaring
  }

  def y = _y

  def y_=(newValue: Int): Unit = {
    if (newValue < bound) _y = newValue else printWaring
  }

  def printWaring = println("Out of bounds")
}

object Main {
  def main(args: Array[String]): Unit = {
    val point1 = new Point
    point1.x = 99
    point1.x = 101
  }
}
```

Output will be:

```scala
Out of bounds
```

Now let's analyse:

1. We define 2 private variables, `_x`  and `_y`. 
2. We define methods `x` and `y` as the getter of the private variables
3. We define methods `x_` and `y_` as the setter of private variables.

**Notify that the method has `_=` append to the identifier of the getter and parameters come after. This is special syntax. **

For constructors, primary constructor with `val` and `var` are public. But because `val` is immutable, so cannot write the following:

```scala
class Point(val x: Int, val y: Int)
val point = new Point(1, 2)
point.x = 3  // <-- does not compile
```

Also, parameters without `val` or `var` are private values, **visible only within the class**. 

```scala
class Point(x: Int, y: Int)
val point = new Point(1, 2)
point.x  // <-- does not compile
```

## 3.5 Extending a class

Like in Java, we can extend a base Scala class, and use `extend` key word to do the same way as Java. 

There are two restrictions:

1. Method overriding requires the `override` keyword.
2. Only `primary` constructor can pass parameters to base constructor.

Also, you can only extend one class in Scala. 

Below is an example of `extend`:

```scala
class Point(val xc: Int, val yc: Int) {
  var x: Int = xc
  var y: Int = yc

  def move(dx: Int, dy: Int): Unit = {
    x = x + dx
    y = y + dy
    println("Point x location : " + x)
    println("Point y location : " + y)
  }

}

class Location(override val xc: Int, override val yc: Int, zc: Int)
  extends Point(xc, yc) {
  var z: Int = zc

  def move(dx: Int, dy: Int, dz: Int): Unit = {
    x = x + dx
    y = y + dy
    z = z + dz
    println("Location x location : "+x)
    println("Location y location : "+y)
    println("Location z location : "+z)
  }
}

object Demo {
  def main(args: Array[String]): Unit = {
    val pt = new Point(10, 20)
    pt.move(30, 40)

    val location = new Location(1,2,3)
    location.move(10,10,10)
  }
}
```

# 4. Default parameter values

 Differnet from Java, we can point at the sequence of parameter by providing the name.

```scala
object NamedArguments {
  def printName(firstName: String, lastName: String): Unit ={
    println(firstName+" "+lastName)
  }

  def main(args: Array[String]): Unit = {
    printName("John","Smith")
    printName(lastName = "Smith",firstName = "John")
  }
}
```

So can see that we could arrange the order of named arguments. But there are some points we need to give notice:

1.  Named arguments do not work with calls to Java methods.
2. If some arguments are named and others are not, the unnamed arguments must come first and in the order of their parameters in the method signature.

Below is the wrong way using:

```scala
printName(last = "Smith", "john") // error: positional after named argument
```

# 5. Traits

We already introduce it briefly, and can see that traits are similar to Java's interfaces.

Classes and objects can extend traits, but traits cannot be instantiated and therefore **have no parameters**.

To use traits, we can implement it and then override methods, like:

```scala
trait Iterator[A] {
  def hasNext: Boolean

  def next(): A

}

class IntIterator(to: Int) extends Iterator[Int] {
    private var current = 0

  override def hasNext: Boolean = current<to

  override def next(): Int = {
    if(hasNext){
      val t=current
      current+=1
      t
    } else 0
  }
}

object CanRun{
  def main(args: Array[String]): Unit = {
    val iterator = new IntIterator(10)
    println(iterator.next())
    println(iterator.next())
  }
}
```

The `IntIterator` class takes a parameter `to` as the upper bound.

Also, subtype of a trait can be used when a given trait is required. Like:

```scala
trait Pet {
  val name: String
}

class Cat(val name: String) extends Pet

class Dog(val name: String) extends Pet

object PetRun {
  def main(args: Array[String]): Unit = {
    val dog = new Dog("DogName")
    val cat = new Cat("CatName")

    val animals = ArrayBuffer.empty[Pet]
    animals.append(dog).append(cat)
    animals.foreach(pet => println(pet.name))

  }
}
```

In this example, we can see that we use `Pet` in the `ArrayBuffer`, but we use the subtype of it, such as `Dog` and `Cat` to implement it. This is how we use the traits.

# 6. Tuples

Tuples are used to contain  fixed number of elements, and each with a distinct type. 

**Tuples are immutable.** And also be used for returning multiple values from a method.

We can define a tuple like this:

`val ingredient = ("Sugar" , 25)`

See here we don't need to figure the kind of tuple. However, tuple in Scala is a little dfferent from what other kinds of data structures:

> As shown, just put some elements inside parentheses, and you have a tuple. Scala tuples can contain between two and 22 items, and they’re useful for those times when you just need to combine a few things together, and don’t want the baggage of having to define a class, especially when that class feels a little “artificial” or phony.
>
> > Technically, Scala 2.x has classes named `Tuple2`, `Tuple3` … up to `Tuple22`. As a practical matter you rarely need to know this, but it’s also good to know what’s going on under the hood. (And this architecture is being improved in Scala 3.)

**How to use tuples?**

If we want to get elements in tuples, we can use a special grammer which begins with 1 to get it. 

**Pattern matching on tuples**

A tuple also can be taken apart using pattern matching.

Here is an example on all things we mentioned above. 

```scala
object LearnTuple {
  def main(args: Array[String]): Unit = {
    val ingredient = ("Sugar", 25)
    val (name, quality) = ingredient
    println(ingredient._1)
    println(ingredient._2)
    println(name)
    println(quality)

    val planets = List(("Mercury", 57.9), ("Venus", 108.2), ("Earth", 149.6), ("Mars", 227.9), ("Jupiter", 778.3))
    planets.foreach {
      case ("Earth", distance) => println(s"Our planet is $distance km from Sun")
      case _ =>
    }

    val numPairs = List((2, 5), (3, -7), (20, 56))
    for ((a, b) <- numPairs) {
      println(a * b)
    }
  }
}

```

Results;

```scala
Sugar
25
Sugar
25
Our planet is 149.6 km from Sun
10
-21
1120
```

# 7. Class composition with mixins

One trait extends an abstract class is called a `mixin`

Simple examples first:

```scala
abstract class A {
  val message: String
}

class B extends A {
  val message = "I am an instance of class B"
}

trait C extends A {
  def loudMessage = message.toUpperCase()
}

class D extends B with C

object LearnMixins {
  def main(args: Array[String]): Unit = {
    val d = new D
    println(d.message)
    println(d.loudMessage)
  }
}

```

Result is:

```scala
I am an instance of class B
I AM AN INSTANCE OF CLASS B
```

Now we analyse the code:

Class `D` has superclass `B` and a mixin `C`. Classes can only have one superclass, but can have a lot of mixins -- by using keywords `extends` and `with` respectively. Mixins and superclass can have the same supertype.

In this fragment of code, we can see that class D has a supertype class A, and use the mixin C.

What if we don't want to figure the type of data in traits?

We can define a abstract class with type and some methods we want, and then define a mixin to extend it, in the below example, we define a mixin which has function `foreach`. Then we compose them up, and use them.

```scala
abstract class AbsIterator {
  type T

  def hasNext: Boolean

  def next(): T
}

class StringIterator(s: String) extends AbsIterator {
  type T = Char
  private var i = 0

  override def hasNext: Boolean = i < s.size

  override def next(): Char = {
    val ch = s.charAt(i)
    i += 1
    ch
  }
}

trait RichIterator extends AbsIterator {
  def foreach(f: T => Unit): Unit = while (hasNext) f(next())
}

object MixinOnAbstractClass {
  class RichStringIter extends StringIterator("Scala") with RichIterator

  def main(args: Array[String]): Unit = {
    val richStringIter = new RichStringIter
    richStringIter.foreach(println)
  }

}
```

From the code segment, we define a `AbsIterator` which is an abstract class,  also has the `T` as type. Then we define a class to implement these methods it has. After that, we define a trait which implement the abstract class, to emhance it by defining `foreach` function. Last, we use them together.

Result is:

```scala
S
c
a
l
a
```

# 8. Higher-order functions

In Scala, we can pass in functions as parameters, and also can return functions as return value.

Here is functions that accept functions as parameters:

```Scala
object SalaryRaiser {
  private def promotion(salaries: List[Double], promotionFunc: Double => Double): List[Double] = {
    salaries.map(promotionFunc)
  }

  def smallPromotion(salaries: List[Double]): List[Double] =
    promotion(salaries, salary => salary * 1.1)

  def middlePromotion(salaries: List[Double]): List[Double] =
    promotion(salaries, salary => salary * 1.5)

  def hugePromotion(salaries: List[Double]): List[Double] =
    promotion(salaries, salary => salary * 2)
}
```

Can see that we pass the `promotionFunc` as parameter for the function. 

In Scala, if we want to define a function, the easiest way is like this: `(Type1 var1, Type2 var2)=>Type3`

So in the same way we can define functions that can return functions as the return values, such as :

```scala
def urlBuilder(ssl: Boolean, domainName: String): (String, String) => String ={
    val schema = if(ssl) "https://" else "http://"
    (endPoint:String,query:String)=>s"$schema$domainName/$endPoint?$query"
  }
```

and can be used like:

```scala
		val domainName = "www.example.com"
    def getURL = urlBuilder(ssl=true, domainName)
    val endpoint = "users"
    val query = "id=1"
    val url = getURL(endpoint, query)
    println(url)
```

# 9. Nested Methods

In a method we can define another method, like this:

```scala
object NestedMethodsStudy {
  def factorial(x: Int): Int = {
    def fact(x: Int, accumulator: Int): Int = {
      if (x <= 1) accumulator
      else fact(x - 1, x * accumulator)
    }

    fact(x, 1)
  }

  def main(args: Array[String]): Unit = {
    println("Factorial of 10 "+factorial(10))
  }
}
```

And output is:

```scala
Factorial of 10 3628800
```

We can refer from the API which Scala provided `foldLeft`:

`def foldLeft[B](z:B)(op(B,A)=>B):B`

`foldLeft` applies a two-parameter function `op` to an initial value `z` and all elements of this collection, going from left to right. 

Example:

```scala
    val res = numbers.foldLeft(0)((m, n) => m + n)
```

# 10. Case classes

Case classes are mostly like normal classes, but have some difference. 

1. When create a case class with parameters, the parameters are public `val`s.It means that you cannot change them. 

```scala
case class Message(sender: String, recipient: String, body: String)

def main(args: Array[String]): Unit = {
    val message1 = Message("guillaume@quebec.ca",
      "jorge@catalonia.es",
      "Ça va ?"
    )
    println(message1.sender)
    message1.sender="I wanna change" //will cause compile failed, "reassignment to val"
  }
```

2. When we would like to change some values in case classes, we can use `copy` method. It will create  **a shallow copy** of an instance class.And we could optionally change the constuctor arguments.

```scala
case class Message(sender: String, recipient: String, body: String)
val message4 = Message("julien@bretagne.fr", "travis@washington.us", "Me zo o komz gant ma amezeg")
val message5 = message4.copy(sender = message4.recipient, recipient = "claire@bourgogne.fr")
message5.sender  // travis@washington.us
message5.recipient // claire@bourgogne.fr
message5.body  // "Me zo o komz gant ma amezeg"
```

3. When we use case classes to do comparison, they will be compared by structure not by reference. It means if two things the value are the same, then it will return true unless they are different objects.

```scala
   case class Message(sender: String, recipient: String, body: String)
   
   val message2 = Message("jorge@catalonia.es", "guillaume@quebec.ca", "Com va?")
   val message3 = Message("jorge@catalonia.es", "guillaume@quebec.ca", "Com va?")
   val messagesAreTheSame = message2 == message3  // true
```

   

