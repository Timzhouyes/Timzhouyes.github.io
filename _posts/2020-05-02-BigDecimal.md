---
layout:     post   				    # 使用的布局（不需要改）
title:      BigDecimal如何保证计算精度  		# 标题 
subtitle:   与transient方法初探        #副标题
date:       2020-05-02		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Java
    - BigDecimal
---

参考：https://zhuanlan.zhihu.com/p/71796835

在计算机之中，我们知道一切都是二进制的，那么对于一个数字而言，其在内存之中的长度是有限的，这种情况之下，其也就只能保存有限的数字（必须可以表示为2的n次幂）。

这种情况之下，小数的表示就很难了——比如0.3，就没法精确表示。但是生活之中的小数操作是必不可少的，比如钱数的加减。如何使这些操作尽可能的精确呢？就用到了`BigDecimal`

# 1. 什么是BigDecimal

BigDecimal是在进行小数运算的时候，将小数的精确度提高的一种数据结构。

# 2. 如何实现？

```java
package java.math;
 
public class BigDecimal {
    //值的绝对long型表示
    private final transient long intCompact;
    //值的小数点后的位数
    private final int scale;
 
    private final BigInteger intVal;
    //值的有效位数，不包含正负符号
    private transient int precision;
    private transient String stringCache;
     
    //加、减、乘、除、绝对值
    public BigDecimal add(BigDecimal augend) {}
    public BigDecimal subtract(BigDecimal subtrahend) {}
    public BigDecimal multiply(BigDecimal multiplicand) {}
    public BigDecimal divide(BigDecimal divisor) {}
    public BigDecimal abs() {}
}
```

举个例子：

![image-20200502170917843](/img/image-20200502170917843.png)

为啥这里的intCompact的值是`-9223372036854775808`呢？

![image-20200502171218886](/img/image-20200502171218886.png)

这里的这个INFLATED又是啥？

```java
    /**
     * Sentinel value for {@link #intCompact} indicating the
     * significand information is only available from {@code intVal}.
     */
    static final long INFLATED = Long.MIN_VALUE;
```

意思是如果这个是LONG.MIN_VALUE，那么只有在 `intVal`之中的这个值才是准确的。

那么对于我们这个场景，肯定就得从`intVal`之中拿值出来了。

`scale`的值表明了其有多少位的小数。

**重要字段**：

除了上面两处之外，还有：

1. 其有一个叫做`stringCache`的字段，因此在创建BigDecimal的时候，先转换成String类型，比如double转成BigDecimal也是先转成String再转换成BigDecimal。

## 2.1 add方法

其实add方法就是其如何实现精度的一个样板，其他的精度计算原理也是相同，在此就不再赘述了。

```java
   /**
     * Returns a {@code BigDecimal} whose value is {@code (this +
     * augend)}, and whose scale is {@code max(this.scale(),
     * augend.scale())}.
     *
     * @param  augend value to be added to this {@code BigDecimal}.
     * @return {@code this + augend}
     */
    public BigDecimal add(BigDecimal augend) {
        if (this.intCompact != INFLATED) {
            if ((augend.intCompact != INFLATED)) {
                return add(this.intCompact, this.scale, augend.intCompact, augend.scale);
            } else {
                return add(this.intCompact, this.scale, augend.intVal, augend.scale);
            }
        } else {
            if ((augend.intCompact != INFLATED)) {
                return add(augend.intCompact, augend.scale, this.intVal, this.scale);
            } else {
                return add(this.intVal, this.scale, augend.intVal, augend.scale);
            }
        }
    }
```

前面的判断`intCompact`是否为`INFLATED`只是在后面的函数之中使用`intCompact`还是使用`intVal`。

下面是实际业务的方法：

```java
   private static BigDecimal add(BigInteger fst, int scale1, BigInteger snd, int scale2) {
        int rscale = scale1;
        long sdiff = (long)rscale - scale2;
        if (sdiff != 0) {
            if (sdiff < 0) {
                int raise = checkScale(fst,-sdiff);
                rscale = scale2;
                fst = bigMultiplyPowerTen(fst,raise);
            } else {
                int raise = checkScale(snd,sdiff);
                snd = bigMultiplyPowerTen(snd,raise);
            }
        }
        BigInteger sum = fst.add(snd);
        return (fst.signum == snd.signum) ?
                new BigDecimal(sum, INFLATED, rscale, 0) :
                valueOf(sum, rscale, 0);
    }
```

1. 检查两者的小数位数，并且取位数多的作为结果的小数位数
2. 使用BigInteger进行加减，说白了，就是两个不带小数点，但是带有符号的BigInteger 相加。
3. 最后将小数点位置搞回去

下面这个例子说明其也不是完美的表示，但是大部分情况下这种精度是足够使用的。

```java
        n1 = new BigDecimal(0.33);
        n2 = new BigDecimal(0.66);
        result = n1.multiply(n2);
        System.out.println(result.doubleValue());
```

结果为：

```java
0.21780000000000002
```

# 3. transient的用法

看到之前的定义域之中的`    private transient int precision;`了么？这个transient是干嘛的？

参考：https://www.cnblogs.com/lanxuezaipiao/p/3369962.html

## 3.1 transient的作用

将我们不想进行序列化的属性屏蔽，那么就不会被序列化。这个词本身的意思是“短暂的”，那么其的生命周期只能在内存之中，而不会被持久化。

```java
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * @description 使用transient关键字不序列化某个变量
 *        注意读取的时候，读取数据的顺序一定要和存放数据的顺序保持一致
 *        
 * @author Alexia
 * @date  2013-10-15
 */
public class TransientTest {
    
    public static void main(String[] args) {
        
        User user = new User();
        user.setUsername("Alexia");
        user.setPasswd("123456");
        
        System.out.println("read before Serializable: ");
        System.out.println("username: " + user.getUsername());
        System.err.println("password: " + user.getPasswd());
        
        try {
            ObjectOutputStream os = new ObjectOutputStream(
                    new FileOutputStream("C:/user.txt"));
            os.writeObject(user); // 将User对象写进文件
            os.flush();
            os.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
            ObjectInputStream is = new ObjectInputStream(new FileInputStream(
                    "C:/user.txt"));
            user = (User) is.readObject(); // 从流中读取User的数据
            is.close();
            
            System.out.println("\nread after Serializable: ");
            System.out.println("username: " + user.getUsername());
            System.err.println("password: " + user.getPasswd());
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}

class User implements Serializable {
    private static final long serialVersionUID = 8294180014912103005L;  
    
    private String username;
    private transient String passwd;
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPasswd() {
        return passwd;
    }
    
    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }

}
```

其结果为：

```java
read before Serializable: 
username: Alexia
password: 123456

read after Serializable: 
username: Alexia
password: null
```

那么就可以看出在反序列化的时候根本没有在文件之中获得到信息。

## 3.2 怎么用？

1. 变量被 transient修饰，那么不再是对象持久化的一部分，其在序列化之后无法访问
2. transient只能修饰变量，无法修饰方法和类。
3. static的变量无法被修饰

第三点为什么呢？实际上序列化只是针对对象，而不是针对于类。所以static这种类之中的属性就没法被修饰。

## 3.3 我就想序列化transient修饰的对象，有没有方法？

有。

我们知道在Java中，对象的序列化可以通过实现两种接口来实现，若实现的是Serializable接口，则所有的序列化将会自动进行，若实现的是Externalizable接口，则没有任何东西可以自动序列化，需要在writeExternal方法中进行手工指定所要序列化的变量，这与是否被transient修饰无关。因此第二个例子输出的是变量content初始化的内容，而不是null。

```java
import java.io.Externalizable;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInput;
import java.io.ObjectInputStream;
import java.io.ObjectOutput;
import java.io.ObjectOutputStream;

/**
 * @descripiton Externalizable接口的使用
 * 
 * @author Alexia
 * @date 2013-10-15
 *
 */
public class ExternalizableTest implements Externalizable {

    private transient String content = "是的，我将会被序列化，不管我是否被transient关键字修饰";

    @Override
    public void writeExternal(ObjectOutput out) throws IOException {
        out.writeObject(content);
    }

    @Override
    public void readExternal(ObjectInput in) throws IOException,
            ClassNotFoundException {
        content = (String) in.readObject();
    }

    public static void main(String[] args) throws Exception {
        
        ExternalizableTest et = new ExternalizableTest();
        ObjectOutput out = new ObjectOutputStream(new FileOutputStream(
                new File("test")));
        out.writeObject(et);

        ObjectInput in = new ObjectInputStream(new FileInputStream(new File(
                "test")));
        et = (ExternalizableTest) in.readObject();
        System.out.println(et.content);

        out.close();
        in.close();
    }
}
```

结果：

`是的，我将会被序列化，不管我是否被transient关键字修饰`

