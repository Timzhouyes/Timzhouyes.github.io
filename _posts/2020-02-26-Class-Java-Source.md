---
layout:     post   				    # 使用的布局（不需要改）
title:      Class源码解析  		# 标题 
subtitle:           #副标题
date:       2020-02-26		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
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

   前面讲了，其并没有一个可以被调用的构造方法，所以代码之中是private。

   ```java
    /*
        * Private constructor. Only the Java Virtual Machine creates Class objects.
        * This constructor is not used and prevents the default constructor being
        * generated.
        */
       private Class(ClassLoader loader) {
           // Initialize final field for classLoader.  The initialization value of non-null
           // prevents future JIT optimizations from assuming this final field is null.
           classLoader = loader;
       }
   ```

   代码之中显示了，其是先将 classLoader的field做非null初始化，用来避免之后的 JIT(Just-In-Time)优化将这些final值置null

2. `public String toString()`

   ```java
   /**
        * Converts the object to a string. The string representation is the
        * string "class" or "interface", followed by a space, and then by the
        * fully qualified name of the class in the format returned by
        * {@code getName}.  If this {@code Class} object represents a
        * primitive type, this method returns the name of the primitive type.  If
        * this {@code Class} object represents void this method returns
        * "void".
        *
        * @return a string representation of this class object.
        */
       public String toString() {
           return (isInterface() ? "interface " : (isPrimitive() ? "" : "class "))
               + getName();
       }
   ```

   其会将一个对象转换成String，会根据`interface`和`class`的不同种类来输出不同的种类。

3. `public String toGenericString()`

   这个方法是用来输出其所有的modifier,比如输出是`public final class java.lang.String`，那么前面的public, final 等等都是 modifier

   ```java
     /**
        * Returns a string describing this {@code Class}, including
        * information about modifiers and type parameters.
        *
        * The string is formatted as a list of type modifiers, if any,
        * followed by the kind of type (empty string for primitive types
        * and {@code class}, {@code enum}, {@code interface}, or
        * <code>&#64;</code>{@code interface}, as appropriate), followed
        * by the type's name, followed by an angle-bracketed
        * comma-separated list of the type's type parameters, if any.
        *
        * A space is used to separate modifiers from one another and to
        * separate any modifiers from the kind of type. The modifiers
        * occur in canonical order. If there are no type parameters, the
        * type parameter list is elided.
        *
        * <p>Note that since information about the runtime representation
        * of a type is being generated, modifiers not present on the
        * originating source code or illegal on the originating source
        * code may be present.
        *
        * @return a string describing this {@code Class}, including
        * information about modifiers and type parameters
        *
        * @since 1.8
        */
       public String toGenericString() {
           if (isPrimitive()) {
               return toString();
           } else {
               StringBuilder sb = new StringBuilder();
   
               // Class modifiers are a superset of interface modifiers
               int modifiers = getModifiers() & Modifier.classModifiers();
               if (modifiers != 0) {
                   sb.append(Modifier.toString(modifiers));
                   sb.append(' ');
               }
   
               if (isAnnotation()) {
                   sb.append('@');
               }
               if (isInterface()) { // Note: all annotation types are interfaces
                   sb.append("interface");
               } else {
                   if (isEnum())
                       sb.append("enum");
                   else
                       sb.append("class");
               }
               sb.append(' ');
               sb.append(getName());
   
               TypeVariable<?>[] typeparms = getTypeParameters();
               if (typeparms.length > 0) {
                   boolean first = true;
                   sb.append('<');
                   for(TypeVariable<?> typeparm: typeparms) {
                       if (!first)
                           sb.append(',');
                       sb.append(typeparm.getTypeName());
                       first = false;
                   }
                   sb.append('>');
               }
   
               return sb.toString();
           }
       }
   ```

4. `public static Class<?> forName(String className) throws ClassNotFoundException `:
           

本方法用于知道类的名字之后产生相应的一个类，如果找不到这个类，会直接返回`ClassNotFoundException`。比如从配置文件之中读到名字产生一个类，反射产生一个类等等都是需要用到这个方法。

```java
       /**
        * Returns the {@code Class} object associated with the class or
        * interface with the given string name.  Invoking this method is
        * equivalent to:
        *
        * <blockquote>
        *  {@code Class.forName(className, true, currentLoader)}
        * </blockquote>
        *
        * where {@code currentLoader} denotes the defining class loader of
        * the current class.
        *
        * <p> For example, the following code fragment returns the
        * runtime {@code Class} descriptor for the class named
        * {@code java.lang.Thread}:
        *
        * <blockquote>
        *   {@code Class t = Class.forName("java.lang.Thread")}
        * </blockquote>
        * <p>
        * A call to {@code forName("X")} causes the class named
        * {@code X} to be initialized.
        *
        * @param      className   the fully qualified name of the desired class.
        * @return     the {@code Class} object for the class with the
        *             specified name.
        * @exception LinkageError if the linkage fails
        * @exception ExceptionInInitializerError if the initialization provoked
        *            by this method fails
        * @exception ClassNotFoundException if the class cannot be located
        */
       @CallerSensitive
       public static Class<?> forName(String className)
                   throws ClassNotFoundException {
           Class<?> caller = Reflection.getCallerClass();
           return forName0(className, true, ClassLoader.getClassLoader(caller), caller);
       }
   
```

5. `public static Class<?> forName(String name, boolean initialize,
                                         ClassLoader loader)
              throws ClassNotFoundException`：

      实际上，一看就知道这个方法是上面那个方法的全名。实际在代码和注释之中说了，如果没有填相应的field，那么

      ```java
           * <blockquote>
           *  {@code Class.forName("Foo")}
           * </blockquote>
           *
           * is equivalent to:
           *
           * <blockquote>
           *  {@code Class.forName("Foo", true, this.getClass().getClassLoader())}
           * </blockquote>
      ```

      其实相当于直接调用这个方法，只是将后面的 initialize 和 loader 填成默认的值。

      此处如果这个 loader 是 null，那么整个类会由 bootstrap class loader 来作为loader。

      虽然在注释之中特别注明了其并不检查是否caller有访问其的权限，但是在下面又有另一种情况，是如果loader部分是null，并且一个security manager是存在的， 那么其方法会call security manager 的 `checkPermission()` 方法的来获取 RuntimePermission("getClassLoader")去检查是否 bootstrap loader（默认的那个）具有权限。

      ```java
         /**
           * Returns the {@code Class} object associated with the class or
           * interface with the given string name, using the given class loader.
           * Given the fully qualified name for a class or interface (in the same
           * format returned by {@code getName}) this method attempts to
           * locate, load, and link the class or interface.  The specified class
           * loader is used to load the class or interface.  If the parameter
           * {@code loader} is null, the class is loaded through the bootstrap
           * class loader.  The class is initialized only if the
           * {@code initialize} parameter is {@code true} and if it has
           * not been initialized earlier.
           *
           * <p> If {@code name} denotes a primitive type or void, an attempt
           * will be made to locate a user-defined class in the unnamed package whose
           * name is {@code name}. Therefore, this method cannot be used to
           * obtain any of the {@code Class} objects representing primitive
           * types or void.
           *
           * <p> If {@code name} denotes an array class, the component type of
           * the array class is loaded but not initialized.
           *
           * <p> For example, in an instance method the expression:
           *
           * <blockquote>
           *  {@code Class.forName("Foo")}
           * </blockquote>
           *
           * is equivalent to:
           *
           * <blockquote>
           *  {@code Class.forName("Foo", true, this.getClass().getClassLoader())}
           * </blockquote>
           *
           * Note that this method throws errors related to loading, linking or
           * initializing as specified in Sections 12.2, 12.3 and 12.4 of <em>The
           * Java Language Specification</em>.
           * Note that this method does not check whether the requested class
           * is accessible to its caller.
           *
           * <p> If the {@code loader} is {@code null}, and a security
           * manager is present, and the caller's class loader is not null, then this
           * method calls the security manager's {@code checkPermission} method
           * with a {@code RuntimePermission("getClassLoader")} permission to
           * ensure it's ok to access the bootstrap class loader.
           *
           * @param name       fully qualified name of the desired class
           * @param initialize if {@code true} the class will be initialized.
           *                   See Section 12.4 of <em>The Java Language Specification</em>.
           * @param loader     class loader from which the class must be loaded
           * @return           class object representing the desired class
           *
           * @exception LinkageError if the linkage fails
           * @exception ExceptionInInitializerError if the initialization provoked
           *            by this method fails
           * @exception ClassNotFoundException if the class cannot be located by
           *            the specified class loader
           *
           * @see       java.lang.Class#forName(String)
           * @see       java.lang.ClassLoader
           * @since     1.2
           */
          @CallerSensitive
          public static Class<?> forName(String name, boolean initialize,
                                         ClassLoader loader)
              throws ClassNotFoundException
          {
              Class<?> caller = null;
              SecurityManager sm = System.getSecurityManager();
              if (sm != null) {
                  // Reflective call to get caller class is only needed if a security manager
                  // is present.  Avoid the overhead of making this call otherwise.
                  caller = Reflection.getCallerClass();
                  if (sun.misc.VM.isSystemDomainLoader(loader)) {
                      ClassLoader ccl = ClassLoader.getClassLoader(caller);
                      if (!sun.misc.VM.isSystemDomainLoader(ccl)) {
                          sm.checkPermission(
                              SecurityConstants.GET_CLASSLOADER_PERMISSION);
                      }
                  }
              }
              return forName0(name, initialize, loader, caller);
          }
      ```

6. `private static native Class<?> forName0(String name, boolean initialize,
                                            ClassLoader loader,
                                              Class<?> caller)
          throws ClassNotFoundException;`
  
  首先可以看到上面的方法在SecurityManager检测是否有权限之后调用了这个方法，然后发现其关键字之中有 `native`，那么其就没有任何的结构体，是JVM层面的方法。
  
7. `public T newInstance()`

      其会创建一个本 Class 相对的新的 instance， 这个 Class 会被一个`new` 表达式来进行空 argument的实例化，如果这个 Class 没有初始化， 那么会先对其进行初始化。

      本段为Google 翻译：请注意，此方法传播由nullary构造函数引发的所有异常，包括已检查的异常。 使用此方法可以有效地绕过编译时异常检查，否则编译器将执行该检查。

      其源码内部大概的内容是：如果 `SecurityManager` 不是空，那么执行检查。**但是如果是空，那么下面也没有进行任何处理，意味着也会执行检查**。其下面使用了两个 Class 类之中设置的 private 变量：

      ```java
      private volatile transient Constructor<T> cachedConstructor;
      private volatile transient Class<?>       newInstanceCallerCache;
      ```

      如果 cacheConstructor 为空，那么先检查是否实例化 Class 类本身，是的话抛出异常。不是的话先做一个空类，然后试着调用`getConstructor0`这个方法（按照命名规律来看猜测是一个native 方法），并且在方法之中`setAccessible(true)`，这也对应了我们前面的”如果没有 `SecurityManager`这个对象，那么不去检查其是否可以被 access。

      在这之后，会检查 modifiers ，如果调用`quickCheckMemberAccess(this, modifiers)` 之后发现结果是false，那么会直接生成一个 caller，这个caller如果和`newInstanceCallerCache`不同，那么先使用

      `Reflection.ensureMemberAccess(caller, this, null, modifiers);`

      之后将caller赋给`newInstanceCallerCache`。最后由 constructor 创建 newInstance。

8. `    public native boolean isInstance(Object obj);`

      其原理是检查obj非空，而且在Cast到相应的Class过程之中不发生`ClassCastException`，否则返回false。

      其检查结果很有趣，在注释之中有特殊说明：

      - 如果检验的是已经声明的类，那么当其为该类或者其子类的时候返回true

      - 如果检验的是array，那么其可以转换或者widening reference conversion 成 array的时候返回true

        > A *widening reference conversion* exists from any reference type S to any reference type T, provided S is a subtype of T

      - 如果其是一个interface ,那么当参数的类型或者superclass 可以 implement 当前的 interface 时候会返回true

      - 如果其是一个基本类型，直接返回false。

      ```java
         /**
           * Determines if the specified {@code Object} is assignment-compatible
           * with the object represented by this {@code Class}.  This method is
           * the dynamic equivalent of the Java language {@code instanceof}
           * operator. The method returns {@code true} if the specified
           * {@code Object} argument is non-null and can be cast to the
           * reference type represented by this {@code Class} object without
           * raising a {@code ClassCastException.} It returns {@code false}
           * otherwise.
           *
           * <p> Specifically, if this {@code Class} object represents a
           * declared class, this method returns {@code true} if the specified
           * {@code Object} argument is an instance of the represented class (or
           * of any of its subclasses); it returns {@code false} otherwise. If
           * this {@code Class} object represents an array class, this method
           * returns {@code true} if the specified {@code Object} argument
           * can be converted to an object of the array class by an identity
           * conversion or by a widening reference conversion; it returns
           * {@code false} otherwise. If this {@code Class} object
           * represents an interface, this method returns {@code true} if the
           * class or any superclass of the specified {@code Object} argument
           * implements this interface; it returns {@code false} otherwise. If
           * this {@code Class} object represents a primitive type, this method
           * returns {@code false}.
           *
           * @param   obj the object to check
           * @return  true if {@code obj} is an instance of this class
           *
           * @since JDK1.1
           */
          public native boolean isInstance(Object obj);
      ```

9. `public native boolean isAssignableFrom(Class<?> cls);`

      `Class1.isAssignableFrom(class2);`当class1是 class2的父类或者同类的时候返回true，不然返回false。

      其实际操作是检查其可否直接转换，或者通过widening reference conversion 转换过去。

      ```java
          /**
           * Determines if the class or interface represented by this
           * {@code Class} object is either the same as, or is a superclass or
           * superinterface of, the class or interface represented by the specified
           * {@code Class} parameter. It returns {@code true} if so;
           * otherwise it returns {@code false}. If this {@code Class}
           * object represents a primitive type, this method returns
           * {@code true} if the specified {@code Class} parameter is
           * exactly this {@code Class} object; otherwise it returns
           * {@code false}.
           *
           * <p> Specifically, this method tests whether the type represented by the
           * specified {@code Class} parameter can be converted to the type
           * represented by this {@code Class} object via an identity conversion
           * or via a widening reference conversion. See <em>The Java Language
           * Specification</em>, sections 5.1.1 and 5.1.4 , for details.
           *
           * @param cls the {@code Class} object to be checked
           * @return the {@code boolean} value indicating whether objects of the
           * type {@code cls} can be assigned to objects of this class
           * @exception NullPointerException if the specified Class parameter is
           *            null.
           * @since JDK1.1
           */
          public native boolean isAssignableFrom(Class<?> cls);
      ```

10. `public native boolean isPrimitive();`

       检查其是否是基本类型。此处可以返回 true 的有九种类型，null 和以下八种：

       ```java
       * @see     java.lang.Boolean#TYPE
       * @see     java.lang.Character#TYPE
       * @see     java.lang.Byte#TYPE
       * @see     java.lang.Short#TYPE
       * @see     java.lang.Integer#TYPE
       * @see     java.lang.Long#TYPE
       * @see     java.lang.Float#TYPE
       * @see     java.lang.Double#TYPE
       * @see     java.lang.Void#TYPE
       ```

       下面这句会返回true：

       ```java
               System.out.println(int.class.isPrimitive());
       ```

       源代码：

       ```java
        /**
            * Determines if the specified {@code Class} object represents a
            * primitive type.
            *
            * <p> There are nine predefined {@code Class} objects to represent
            * the eight primitive types and void.  These are created by the Java
            * Virtual Machine, and have the same names as the primitive types that
            * they represent, namely {@code boolean}, {@code byte},
            * {@code char}, {@code short}, {@code int},
            * {@code long}, {@code float}, and {@code double}.
            *
            * <p> These objects may only be accessed via the following public static
            * final variables, and are the only {@code Class} objects for which
            * this method returns {@code true}.
            *
            * @return true if and only if this class represents a primitive type
            *
            * @see     java.lang.Boolean#TYPE
            * @see     java.lang.Character#TYPE
            * @see     java.lang.Byte#TYPE
            * @see     java.lang.Short#TYPE
            * @see     java.lang.Integer#TYPE
            * @see     java.lang.Long#TYPE
            * @see     java.lang.Float#TYPE
            * @see     java.lang.Double#TYPE
            * @see     java.lang.Void#TYPE
            * @since JDK1.1
            */
           public native boolean isPrimitive();
       ```

11. `public boolean isAnnotation()`

       检验其是否为Annotation，注意，如果`isAnnotation`返回true，那么`isInterface`也返回true，因为 所有的 annotation 类型也是 interface。

       其实现就是用到了之前的那个`    private static final int ANNOTATION= 0x00002000;`和Boolean之中的判断异曲同工。

       ```java
       /**
            * Returns true if this {@code Class} object represents an annotation
            * type.  Note that if this method returns true, {@link #isInterface()}
            * would also return true, as all annotation types are also interfaces.
            *
            * @return {@code true} if this class object represents an annotation
            *      type; {@code false} otherwise
            * @since 1.5
            */
           public boolean isAnnotation() {
               return (getModifiers() & ANNOTATION) != 0;
           }
       ```

12. `public String getName()`

       其就是直接返回该类的名字，但是在某些情况下要单独分析：

       ```java
       * <p> If this class object represents a class of arrays, then the internal
            * form of the name consists of the name of the element type preceded by
            * one or more '{@code [}' characters representing the depth of the array
            * nesting.  The encoding of element type names is as follows:
            *
            * <blockquote><table summary="Element types and encodings">
            * <tr><th> Element Type <th> &nbsp;&nbsp;&nbsp; <th> Encoding
            * <tr><td> boolean      <td> &nbsp;&nbsp;&nbsp; <td align=center> Z
            * <tr><td> byte         <td> &nbsp;&nbsp;&nbsp; <td align=center> B
            * <tr><td> char         <td> &nbsp;&nbsp;&nbsp; <td align=center> C
            * <tr><td> class or interface
            *                       <td> &nbsp;&nbsp;&nbsp; <td align=center> L<i>classname</i>;
            * <tr><td> double       <td> &nbsp;&nbsp;&nbsp; <td align=center> D
            * <tr><td> float        <td> &nbsp;&nbsp;&nbsp; <td align=center> F
            * <tr><td> int          <td> &nbsp;&nbsp;&nbsp; <td align=center> I
            * <tr><td> long         <td> &nbsp;&nbsp;&nbsp; <td align=center> J
            * <tr><td> short        <td> &nbsp;&nbsp;&nbsp; <td align=center> S
            * </table></blockquote>
       ```

       如果是这些的数组对象（例如 int[]），那么其在输出的时候会使用后面的缩写（比如 `I[` )。void 的 getName 还是 void，但是 Integer[] 的输出会是 `[Ljava.lang.Integer` 其他的示例输出在下面：

       ```java
            * <p> Examples:
            * <blockquote><pre>
            * String.class.getName()
            *     returns "java.lang.String"
            * byte.class.getName()
            *     returns "byte"
            * (new Object[3]).getClass().getName()
            *     returns "[Ljava.lang.Object;"
            * (new int[3][4][5][6][7][8][9]).getClass().getName()
            *     returns "[[[[[[[I"
            * </pre></blockquote>
       
       ```

13. `private native String getName0();`

       这里还有另外的一个私有变量定义：

       `private transient String name;`

       其有一个注释是下面这句：

       > ```
       > // cache the name to reduce the number of calls into the VM
       > ```

       其意义就是将名字缓存在此处，避免较多的进入VM拿数据的消耗

       命名规则是和之前的一样，使用 native 修饰，并且后缀带有0， 那么就是 JVM 的方法。

       