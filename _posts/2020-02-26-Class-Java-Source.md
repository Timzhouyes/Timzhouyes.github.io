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



# 内部对象

```java
  private static final long serialVersionUID = 3206093459760846163L;
	private static ProtectionDomain AllPermissionsPD;
	private static final int SYNTHETIC = 0x1000;
	private static final int ANNOTATION = 0x2000;
	private static final int ENUM = 0x4000;
	private static final int MEMBER_INVALID_TYPE = -1;

	static final Class<?>[] EmptyParameters = new Class<?>[0];
	
	private transient long vmRef;
	private transient ClassLoader classLoader;

	private transient ProtectionDomain protectionDomain;
	private transient String classNameString;

	private static final class AnnotationVars {
		AnnotationVars() {}
		static long annotationTypeOffset = -1;
		static long valueMethodOffset = -1;

		volatile AnnotationType annotationType;
		MethodHandle valueMethod;
	}
	private transient AnnotationVars annotationVars;
	private static long annotationVarsOffset = -1;

	transient ClassValue.ClassValueMap classValueMap;

	private static final class EnumVars<T> {
		EnumVars() {}
		static long enumDirOffset = -1;
		static long enumConstantsOffset = -1;

		Map<String, T> cachedEnumConstantDirectory;
		T[] cachedEnumConstants;
	}
	private transient EnumVars<T> enumVars;
	private static long enumVarsOffset = -1;
	
	transient J9VMInternals.ClassInitializationLock initializationLock;
	
	private transient Object methodHandleCache;
	
	private transient ClassRepositoryHolder classRepoHolder;
```

下面分点讲：

1. `serialVersionUID` ：其用来标记当前对象的版本。在序列化和反序列化之中，我们有可能在接收和输出的两台机器上面的类型版本不同，那么这种情况序列化和反序列化就可能出现问题。如何应对这种情况？就是每次改动之后修改这个`serialVersionUID`，这样的话在接收端就可以发现这个对象和自己的版本不同。当然，有时候是需要将修改兼容此对象，那么就在修改之后的版本之中保持其值不变。

# 方法

1. 默认构造方法：

   ```java
   **
    * Prevents this class from being instantiated. Instances
    * created by the virtual machine only.
    */
   private Class() {}
   ```

   可以看到其直接将默认构造方法置空。在备注之中也提到了，这种情况是防止这个类被实例化。实例只可以在vm之中被创建。

2. `checkMemberAccess`:

   ```java
   /*
    * Ensure the caller has the requested type of access.
    * 
    * @param		security			the current SecurityManager
    * @param		callerClassLoader	the ClassLoader of the caller of the original protected API
    * @param		type				type of access, PUBLIC, DECLARED or INVALID
    * 
    */
   void checkMemberAccess(SecurityManager security, ClassLoader callerClassLoader, int type) {
   	if (callerClassLoader != ClassLoader.bootstrapClassLoader) {
   		ClassLoader loader = getClassLoaderImpl();
   		if (type == Member.DECLARED && callerClassLoader != loader) {
   			security.checkPermission(com.ibm.oti.util.RuntimePermissions.permissionAccessDeclaredMembers);
   		}
   		if (sun.reflect.misc.ReflectUtil.needsPackageAccessCheck(callerClassLoader, loader)) {	
   			if (Proxy.isProxyClass(this)) {
   				sun.reflect.misc.ReflectUtil.checkProxyPackageAccess(callerClassLoader, this.getInterfaces());
   			} else {
   				String packageName = this.getPackageName();
   				if ((packageName != null) && (packageName != "")) { //$NON-NLS-1$
   					security.checkPackageAccess(packageName);
   				}
   			}
   		}
   	}
   }
   ```

   可见其作用是检查当前线程是否有权限访问该对象。默认的情况，是允许访问`PUBLIC`类型的对象和相同`ClassLoader` 的调用者类。

3. `checkNonSunProxyMemberAccess`:

   ```java
   /**
    * Ensure the caller has the requested type of access.
    * 
    * This helper method is only called by getClasses, and skip security.checkPackageAccess()
    * when the class is a ProxyClass and the package name is sun.proxy.
    *
    * @param		type			type of access, PUBLIC or DECLARED
    * 
    */
   private void checkNonSunProxyMemberAccess(SecurityManager security, ClassLoader callerClassLoader, int type) {
   	if (callerClassLoader != ClassLoader.bootstrapClassLoader) {
   		ClassLoader loader = getClassLoaderImpl();
   		if (type == Member.DECLARED && callerClassLoader != loader) {
   			security.checkPermission(com.ibm.oti.util.RuntimePermissions.permissionAccessDeclaredMembers);
   		}
   		String packageName = this.getPackageName();
   		if (!(Proxy.isProxyClass(this) && packageName.equals(sun.reflect.misc.ReflectUtil.PROXY_PACKAGE)) &&
   				packageName != null && packageName != "" && sun.reflect.misc.ReflectUtil.needsPackageAccessCheck(callerClassLoader, loader)) //$NON-NLS-1$	
   		{
   			security.checkPackageAccess(packageName);
   		}
   	}
   }
   ```

   确定这个caller

