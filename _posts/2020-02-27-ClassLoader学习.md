---
layout:     post   				    # 使用的布局（不需要改）
title:      Java ClassLoader 解析 		# 标题 
subtitle:   与 ClassLoader 源码分析        #副标题
date:       2020-02-27		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - 编程
    - Java
    - 源码
---

本篇是[小周和你读源码(1)](https://timzhouyes.github.io/2019/12/18/Java-Code1/) 系列的文章。

在读 Java 源码之中的 Class 源码时（没错，这句话在Class源码开篇似曾相识），发现其中很多东西是和 ClassLoader相关的，那么还是要将 ClassLoader 之中的一些概念性问题搞清楚。下面就是学习心得：

参考：https://blog.csdn.net/briblue/article/details/54973413

本文分两部分，第一部分为此博文的学习笔记，第二部分为 Java 之中的 ClassLoader 的源码解析。

# ClassLoader 详解

首先明确 ClassLoader 的作用，其具体作用是将 class 文件加载进入 jvm 虚拟机之中。只有将 class 文件加载进入 jvm 之中，程序才能正常运行，但是在大型项目，例如 Spring 这种，如果在一开始的时候就将所有的类加载进入 jvm 的内存之中，一定是会崩溃的，因此其启动的时候不是一次性加载 class 文件，而是根据其需要去动态的加载。

## Java 类加载流程

Java 之中有三个类加载器：

1. **Bootstrap ClassLoader** :最顶层的加载类，其主要加载**核心类库**，例如：

   `%JRE_HOME%\lib下的rt.jar、resources.jar、charsets.jar和class`

   其可以通过启动时自定 `-Xbootclasspath` 来改变 Bootstrap ClassLoader 的加载目录，比如：

   `java -Xbootclasspath/a:path`， 这样被指定的文件会**追加**到默认的 bootstrap 目录之中。

2. **Extention ClassLoader**: 扩展的类加载器，加载范围为：

   `%JRE_HOME%\lib\ext目录下的jar包和class文件`

   还可以加载 `-D java.ext.dirs` 选项指定的目录。

3. **Appclass Loader**: 也称为 SystemAppClass, 加载当前应用的 classpath 下面的所有类。

   > 什么是 classpath? 就是例如我们在 windows 里面安装完 java， 那么会让我们配三个环境变量，一个是 `PATH`,一个是`CLASSPATH`，一个是`JAVA_HOME`。
   >
   > `JAVA_HOME` 之中的值是 JDK 安装的位置
   >
   > `PATH` 的作用是为了在命令行之中输入命令可以不必打全路径，而是直接键入名字即可
   >
   > `CLASSPATH` 之中的值是指向 jar 包
   >
   > *在[软件](https://zh.wikipedia.org/wiki/软件)领域，**JAR文件**（Java归档，英语：**J**ava **AR**chive）是一种[软件包](https://zh.wikipedia.org/wiki/软件包格式)[文件格式](https://zh.wikipedia.org/wiki/文件格式)，通常用于聚合大量的[Java类文件](https://zh.wikipedia.org/w/index.php?title=Java类文件&action=edit&redlink=1)、相关的[元数据](https://zh.wikipedia.org/wiki/元数据)和资源（文本、图片等）文件到一个文件，以便分发Java平台[应用软件](https://zh.wikipedia.org/wiki/应用软件)或[库](https://zh.wikipedia.org/wiki/函式庫)。*

## 类加载器的顺序？

其顺序就和我们上面提到的顺序相同。

先看一段源码：

```java
public class Launcher {
    private static Launcher launcher = new Launcher();
    private static String bootClassPath =
        System.getProperty("sun.boot.class.path");

    public static Launcher getLauncher() {
        return launcher;
    }

    private ClassLoader loader;

    public Launcher() {
        // Create the extension class loader
        ClassLoader extcl;
        try {
            extcl = ExtClassLoader.getExtClassLoader();
        } catch (IOException e) {
            throw new InternalError(
                "Could not create extension class loader", e);
        }

        // Now create the class loader to use to launch the application
        try {
            loader = AppClassLoader.getAppClassLoader(extcl);
        } catch (IOException e) {
            throw new InternalError(
                "Could not create application class loader", e);
        }

        //设置AppClassLoader为线程上下文类加载器，这个文章后面部分讲解
        Thread.currentThread().setContextClassLoader(loader);
    }

    /*
     * Returns the class loader used to launch the main application.
     */
    public ClassLoader getClassLoader() {
        return loader;
    }
    /*
     * The class loader used for loading installed extensions.
     */
    static class ExtClassLoader extends URLClassLoader {}

/**
     * The class loader used for loading from java.class.path.
     * runs in a restricted security context.
     */
    static class AppClassLoader extends URLClassLoader {}

```

注意此处的源码是有精简的。

可以看到此处的代码之中，Launcher 初始化了 ExtClassLoader 和 AppClassLoader，但是除了一开始的 bootClassPath 这个地方之外好像没有任何提到 bootstrap classLoader 的东西。我们猜测这个地方就是其 bootstrap classLoader。

但是为什么没有初始化呢？不是讲第一部分就是需要初始化吗？下面会讲。

先测试一下 `sun.boot.class.path` 之中有什么：

`System.out.println(System.getProperty("sun.boot.class.path"));`

结果如下：

```java
C:\Program Files\Java\jre1.8.0_91\lib\resources.jar;
C:\Program Files\Java\jre1.8.0_91\lib\rt.jar;
C:\Program Files\Java\jre1.8.0_91\lib\sunrsasign.jar;
C:\Program Files\Java\jre1.8.0_91\lib\jsse.jar;
C:\Program Files\Java\jre1.8.0_91\lib\jce.jar;
C:\Program Files\Java\jre1.8.0_91\lib\charsets.jar;
C:\Program Files\Java\jre1.8.0_91\lib\jfr.jar;
C:\Program Files\Java\jre1.8.0_91\classes
```

可以看到此处都是 JRE 目录下面的 jar 包，或者是 class 文件。

## ExtClassLoader 源码

下面是对于 `ExtClassLoader` 的源码解读：

```java
/*
     * The class loader used for loading installed extensions.
     */
    static class ExtClassLoader extends URLClassLoader {

        static {
            ClassLoader.registerAsParallelCapable();
        }

        /**
         * create an ExtClassLoader. The ExtClassLoader is created
         * within a context that limits which files it can read
         */
        public static ExtClassLoader getExtClassLoader() throws IOException
        {
            final File[] dirs = getExtDirs();

            try {
                // Prior implementations of this doPrivileged() block supplied
                // aa synthesized ACC via a call to the private method
                // ExtClassLoader.getContext().

                return AccessController.doPrivileged(
                    new PrivilegedExceptionAction<ExtClassLoader>() {
                        public ExtClassLoader run() throws IOException {
                            int len = dirs.length;
                            for (int i = 0; i < len; i++) {
                                MetaIndex.registerDirectory(dirs[i]);
                            }
                            return new ExtClassLoader(dirs);
                        }
                    });
            } catch (java.security.PrivilegedActionException e) {
                throw (IOException) e.getException();
            }
        }

        private static File[] getExtDirs() {
            String s = System.getProperty("java.ext.dirs");
            File[] dirs;
            if (s != null) {
                StringTokenizer st =
                    new StringTokenizer(s, File.pathSeparator);
                int count = st.countTokens();
                dirs = new File[count];
                for (int i = 0; i < count; i++) {
                    dirs[i] = new File(st.nextToken());
                }
            } else {
                dirs = new File[0];
            }
            return dirs;
        }
 
......
    }

```

博文之中对本处代码没有点评，下面是博客作者本人的一些评论：

其作用为加载 extensions， 在一开始创建一个限制读取文件范围的 ExtClassLoader。

中间这部分 try block 之中的代码不大易懂，在网上也基本没有资料，个人的理解是 implement `doPrivileged()`这个方法，然后通过 call `ExtClassLoader.getContext()`这个私有方法来用在一个synthesized ACC 上面，此处的 ACC 经过多种查阅，我认为最贴切的可能是 Authorization Service Provider Contract for Containers ，虽然查到这个其实是 Java 6 提供给 Java EE的一种鉴权方式，大概率是用在 client 和 server 之间的那种……

总之这个部分就是对 class 的访问权限等等的设定和限制了！（自我确定

言归正传，和上面一样，可以通过下面的代码来查看 ExtClassLoader 部分的路径：

`System.out.println(System.getProperty("java.ext.dirs"));`

结果如下：

`C:\Program Files\Java\jre1.8.0_91\lib\ext;C:\Windows\Sun\Java\lib\ext`

## AppClassLoader 源码

