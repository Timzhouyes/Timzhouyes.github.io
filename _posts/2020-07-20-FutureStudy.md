---

layout:     post   				    # 使用的布局（不需要改）
title:      Future相关学习  		# 标题 
subtitle:   剖析FutureTask,附带一些代码样例        #副标题
date:       2020-07-20		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Future
---

在Java之中，多线程的调用方式主要是两个，一个是`Future`，一个是`Thread`。当然，在多线程的情况下建议使用的是`ThreadPool`，但是本文为了突出原理，直接手动开多线程！今天就主要来学习一下`Future`相关的知识。

警告：本篇有些硬核，如果想看相关的总结简析可以直接看开始的重点！

简略版：

**1. 是什么？**

Future实际上是我们想让其他线程执行耗时任务时候的一个”收货凭证“。

**2. 有什么特点？**

	1. 可异步执行任务，只能有一个线程执行，但是可以有多个线程收到结果
	2. 内部的状态转换比较复杂且全面，在正常执行时候收到结果，异常的时候收到Exception消息

**3. 怎么用？**

1. 新建一个`Callable`匿名函数实现类对象，将业务逻辑放在`call()`之中，同时将``Callable`的泛型设置成我们想要的返回结果类型
2. 将`Callable`匿名函数对象作为`FutureTask`的构造参数传入，创建一个`futureTask`对象
3. 再将`futureTask`作为`Thread`的构造参数传入，开启另一线程执行逻辑
4. 在需要得到结果时候调用`futureTask`的`get()`方法。

**4. 如何实现？**

下面是FutureTask的实现简介：

	1. 其是`RunnableFuture`的实现，而`RunnableFuture`本身是extend了`Future`和`Runnable`。我个人的理解，这个接口的意思实际是”可以被线程执行的异步有结果的任务“
 	2. 其内部的成员变量主要有``Thread runner`——用来执行任务的worker，`WaitNode waiters`——线程等待节点和`int state`——线程执行状态。通过状态的变化来标识不同的阶段，同时对worker和waiter做相应的操作：执行或者返回



**本篇重点：**

1. Future模型之中的状态定义和转换方式
2. Future对于`run()`, `get()` 和 `cancel(boolean)` 的实现，以及各种状态机

[参考](https://mp.weixin.qq.com/s/NEWzco3AHx5XLP72M54hIQ)

# 0. 个人Q&A

在一开始的案例演示之中，我对这个结果有了一些疑惑：

![image-20200723154604721](/img/2020-07-20-FutureStudy/image-20200723154604721.png)

按理来讲，多线程之中的线程彼此之间是互不干扰的，也没有一个规定的顺序。但是实际在测试之中，发现main的语句总能在最前面。难不成总是先执行几句main的函数再执行新的线程？

实则不然。是因为main总是一开始就开启了的线程，所以在main线程调用其他线程的时候，实际上已经执行了一阵，也就是已经跑了一些语句了。那么一个先跑，一个后跑，总会让人觉得main跑的快不是么？多线程之间，在没有加入外界限制的情况下，彼此实际上并没有什么约束。

# 1. 什么是Future

Future可以当成是我们收货的凭证，当某些任务非常耗时的时候，我们可以先另起一个线程异步执行这个耗时的任务，同时拿到这个Future凭证。当我们这个线程结束相关的任务，想要获得结果的时候，就调用其中的`get()`方法获得结果。

`Future` 和 `Thread`的区别在于`Future`一定是有返回结果的，而`Thread`没有。

# 2. 如何使用Future

简析都在上面，下面放上代码：

```java
public static void main(String[] args) throws Exception {
        FutureTask<String> futureTask = new FutureTask<>(new Callable<String>() {
            @Override
            public String call() throws Exception {
                System.out.println(Thread.currentThread().getName() + ":" + "Start boiling water");
                Thread.sleep(3000);
                System.out.println(Thread.currentThread().getName() + ":" + "Water already boiled");
                return "boiled water";
            }
        });


        Thread thread = new Thread(futureTask);
        thread.start();
        System.out.println(Thread.currentThread().getName() + ":" + "Now start another thread executing logic in futureTask, now we can start doing other things");
        Thread.sleep(5000);
        System.out.println(Thread.currentThread().getName() + ":" + "Food already prepared");
        String shicai = "Food";
        String boilWater = futureTask.get();
        System.out.println(Thread.currentThread().getName() + ":" + boilWater + " and " + shicai + " already prepared, we can start eating");
    }
```

那么最后的结果是：

```java
main:Now start another thread executing logic in futureTask, now we can start doing other things
Thread-0:Start boiling water
Thread-0:Water already boiled
main:Food already prepared
main:boiled water and Food already prepared, we can start eating

```

# 3.  FutureTask 结构分析

简析直接在前面。先上图

![image-20200723155737797](/img/2020-07-20-FutureStudy/image-20200723155737797.png)

`Runnable`之中只有一个`run()`,而`Future`之中有：

1. `boolean cancel(boolean mayInterruptIfRunning)`：尝试取消任务执行，注意此处只是发出一个线程中断的信号。
2. `boolean isCancelled()`：判断任务是否取消了
3. `boolean isDone()`：反正只要没在跑就done，返回true的情况包括正常停止，异常或者任务取消。
4. `V get() throws InterruptedException, ExecutionException`： 获取任务的执行结果，**注意是阻塞等待来获取任务执行结果**——很正常，我现在就差你这个结果等着要了，不排队等你还有啥办法？
5. ` V get(long timeout, TimeUnit unit)
       throws InterruptedException, ExecutionException, TimeoutException`：和上面的一样，只是多个一个超时就报异常的操作。

`RunnableFuture`上面讲过了，不赘述。

下面来剖析`FutureTask`类的api：

![image-20200726221137388](/img/2020-07-20-FutureStudy/image-20200726221137388.png)

对于一个任务，最重点的就是`run()`,`get()`和`cancel(boolean)`。执行，取结果，取消；这三个是一个任务的基本操作。

# 4. FutureTask 分析

## 4.1 FutureTask 成员变量

```java
// FutureTask.java

/** 封装的Callable对象，其call方法用来执行异步任务 */
private Callable<V> callable;
/** 在FutureTask里面定义一个成员变量outcome，用来装异步任务的执行结果 */
private Object outcome; // non-volatile, protected by state reads/writes
/** 用来执行callable任务的线程 */
private volatile Thread runner;
/** 线程等待节点，reiber stack的一种实现 */
private volatile WaitNode waiters;
/** 任务执行状态 */
private volatile int state;

// Unsafe mechanics
private static final sun.misc.Unsafe UNSAFE;
// 对应成员变量state的偏移地址
private static final long stateOffset;
// 对应成员变量runner的偏移地址
private static final long runnerOffset;
// 对应成员变量waiters的偏移地址
private static final long waitersOffset;
```

此处的`Callable`是实现任务的被委托者。

## 4.2 FutureTask的状态转换

状态有：

```java
/**
     * The run state of this task, initially NEW.  The run state
     * transitions to a terminal state only in methods set,
     * setException, and cancel.  During completion, state may take on
     * transient values of COMPLETING (while outcome is being set) or
     * INTERRUPTING (only while interrupting the runner to satisfy a
     * cancel(true)). Transitions from these intermediate to final
     * states use cheaper ordered/lazy writes because values are unique
     * and cannot be further modified.
     *
     * Possible state transitions:
     * NEW -> COMPLETING -> NORMAL
     * NEW -> COMPLETING -> EXCEPTIONAL
     * NEW -> CANCELLED
     * NEW -> INTERRUPTING -> INTERRUPTED
     */
    private volatile int state;
    private static final int NEW          = 0;
    private static final int COMPLETING   = 1;
    private static final int NORMAL       = 2;
    private static final int EXCEPTIONAL  = 3;
    private static final int CANCELLED    = 4;
    private static final int INTERRUPTING = 5;
    private static final int INTERRUPTED  = 6;
```

其中的cancel为`public boolean cancel(boolean mayInterruptIfRunning)`。

可见其中的状态变化有：

1. `NEW -> COMPLETING -> NORMAL`:这个状态变化表示异步任务的正常结束，其中`COMPLETING`是一个瞬间临时的过渡状态，由`set`方法设置状态的变化；
2. `NEW -> COMPLETING -> EXCEPTIONAL`:这个状态变化表示异步任务执行过程中抛出异常，由`setException`方法设置状态的变化；
3. `NEW -> CANCELLED`:这个状态变化表示被取消，即调用了`cancel(false)`，由`cancel`方法来设置状态变化；
4. `NEW -> INTERRUPTING -> INTERRUPTED`:这个状态变化表示被中断，即调用了`cancel(true)`，由`cancel`方法来设置状态变化。

## 4.3 **FutureTask构造函数**

其构造函数有两种，一种接收`Callable`,一种接收`Runnable`。而因为`Runnable`是没有返回值的，所以其在处理的时候实际上就是加上一个返回值组装成`Callable`。

FutureTask在创建之后，state会被初始化成NEW。

下面是两个的对比：

```java
// FutureTask.java

// 第一个构造函数
public FutureTask(Callable<V> callable) {
    if (callable == null)
        throw new NullPointerException();
    this.callable = callable;
    this.state = NEW;       // ensure visibility of callable
}
```

```java
// FutureTask.java

// 另一个构造函数
public FutureTask(Runnable runnable, V result) {
    this.callable = Executors.callable(runnable, result);
    this.state = NEW;       // ensure visibility of callable
}
```

## 4.4 **FutureTask.run——执行异步任务**

总而言之，就是判断状态——满足条件执行任务或者不满足条件去往别的分支——返回结果或者返回异常，同时对相应的状态做修改。

此处注意：在判断线程是否满足执行异步任务的条件时，`runner`是否是null是调用CAS方法`compareAndSwapObject`来设置的。同时前面我们提到了`runnerOffset`，其是`compareAndSwapObject`用来给`runner`赋值的偏移量。`runner`被`volatile`修饰，也是一旦某个线程修改其变量值，就会立刻刷写进入主存，同时被其他线程可见。

```java
public void run() {
    // 【1】,为了防止多线程并发执行异步任务，这里需要判断线程满不满足执行异步任务的条件，有以下三种情况：
    // 1）若任务状态state为NEW且runner为null，说明还未有线程执行过异步任务，此时满足执行异步任务的条件，
    // 此时同时调用CAS方法为成员变量runner设置当前线程的值；
    // 2）若任务状态state为NEW且runner不为null，任务状态虽为NEW但runner不为null，说明有线程正在执行异步任务，
    // 此时不满足执行异步任务的条件，直接返回；
    // 1）若任务状态state不为NEW，此时不管runner是否为null，说明已经有线程执行过异步任务，此时没必要再重新
    // 执行一次异步任务，此时不满足执行异步任务的条件；
    if (state != NEW ||
        !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                     null, Thread.currentThread()))
        return;
    try {
        // 拿到之前构造函数传进来的callable实现类对象，其call方法封装了异步任务执行的逻辑
        Callable<V> c = callable;
        // 若任务还是新建状态的话，那么就调用异步任务
        if (c != null && state == NEW) {
            // 异步任务执行结果
            V result;
            // 异步任务执行成功还是始遍标志
            boolean ran;
            try {
                // 【2】，执行异步任务逻辑，并把执行结果赋值给result
                result = c.call();
                // 若异步任务执行过程中没有抛出异常，说明异步任务执行成功，此时设置ran标志为true
                ran = true;
            } catch (Throwable ex) {
                result = null;
                // 异步任务执行过程抛出异常，此时设置ran标志为false
                ran = false;
                // 【3】设置异常，里面也设置state状态的变化
                setException(ex);
            }
            // 【3】若异步任务执行成功，此时设置异步任务执行结果，同时也设置状态的变化
            if (ran)
                set(result);
        }
    } finally {
        // runner must be non-null until state is settled to
        // prevent concurrent calls to run()
        // 异步任务正在执行过程中，runner一直是非空的，防止并发调用run方法，前面有调用cas方法做判断的
        // 在异步任务执行完后，不管是正常结束还是异常结束，此时设置runner为null
        runner = null;
        // state must be re-read after nulling runner to prevent
        // leaked interrupts
        // 线程执行异步任务后的任务状态
        int s = state;
        // 【4】如果执行了cancel(true)方法，此时满足条件，
        // 此时调用handlePossibleCancellationInterrupt方法处理中断
        if (s >= INTERRUPTING)
            handlePossibleCancellationInterrupt(s);
    }
}
```

### 4.4.1 FutureTask的set，setException方法与finishCompletion方法

先说`set`和`setException`。两个都是使用CAS机制进行设置的，也都是验证状态是否为NEW，而且都有将其修改成COMPLETING的动作。区别简言之，就是一个是正常执行结束，从而返回的是正常结果。一个是在异步执行的过程之中抛出异常，从而返回的也是异常。另外，一个是最终改成NORMAL，一个最终改成EXCEPTIONAL。

```java
protected void set(V v) {
    // 【1】调用UNSAFE的CAS方法判断任务当前状态是否为NEW，若为NEW，则设置任务状态为COMPLETING
    // 【思考】此时任务不能被多线程并发执行，什么情况下会导致任务状态不为NEW？
    // 答案是只有在调用了cancel方法的时候，此时任务状态不为NEW，此时什么都不需要做，
    // 因此需要调用CAS方法来做判断任务状态是否为NEW
    if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
        // 【2】将任务执行结果赋值给成员变量outcome
        outcome = v;
        // 【3】将任务状态设置为NORMAL，表示任务正常结束
        UNSAFE.putOrderedInt(this, stateOffset, NORMAL); // final state
        // 【4】调用任务执行完成方法，此时会唤醒阻塞的线程，调用done()方法和清空等待线程链表等
        finishCompletion();
    }
}
```

```java
protected void setException(Throwable t) {
    // 【1】调用UNSAFE的CAS方法判断任务当前状态是否为NEW，若为NEW，则设置任务状态为COMPLETING
    // 【思考】此时任务不能被多线程并发执行，什么情况下会导致任务状态不为NEW？
    // 答案是只有在调用了cancel方法的时候，此时任务状态不为NEW，此时什么都不需要做，
    // 因此需要调用CAS方法来做判断任务状态是否为NEW
    if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
        // 【2】将异常赋值给成员变量outcome
        outcome = t;
        // 【3】将任务状态设置为EXCEPTIONAL
        UNSAFE.putOrderedInt(this, stateOffset, EXCEPTIONAL); // final state
        // 【4】调用任务执行完成方法，此时会唤醒阻塞的线程，调用done()方法和清空等待线程链表等
        finishCompletion();
    }
}
```

也可以看到两个方法在最后都是调用了`finishCompletion()`。这个方法主要用来唤醒我们之前讲到的为了等待结果而阻塞的线程。阻塞线程的列表是LIFO，实际上是一个栈的实现。

```java
private void finishCompletion() {
    // assert state > COMPLETING;
    // 取出等待线程链表头节点，判断头节点是否为null
    // 1）若线程链表头节点不为空，此时以“后进先出”的顺序（栈）移除等待的线程WaitNode节点
    // 2）若线程链表头节点为空，说明还没有线程调用Future.get()方法来获取任务执行结果，固然不用移除
    for (WaitNode q; (q = waiters) != null;) {
        // 调用UNSAFE的CAS方法将成员变量waiters设置为空
        if (UNSAFE.compareAndSwapObject(this, waitersOffset, q, null)) {
            for (;;) {
                // 取出WaitNode节点的线程
                Thread t = q.thread;
                // 若取出的线程不为null，则将该WaitNode节点线程置空，且唤醒正在阻塞的该线程
                if (t != null) {
                    q.thread = null;
                    //【重要】唤醒正在阻塞的该线程
                    LockSupport.unpark(t);
                }
                // 继续取得下一个WaitNode线程节点
                WaitNode next = q.next;
                // 若没有下一个WaitNode线程节点，说明已经将所有等待的线程唤醒，此时跳出for循环
                if (next == null)
                    break;
                // 将已经移除的线程WaitNode节点的next指针置空，此时好被垃圾回收
                q.next = null; // unlink to help gc
                // 再把下一个WaitNode线程节点置为当前线程WaitNode头节点
                q = next;
            }
            break;
        }
    }
    // 不管任务正常执行还是抛出异常，都会调用done方法
    done();
    // 因为异步任务已经执行完且结果已经保存到outcome中，因此此时可以将callable对象置空了
    callable = null;        // to reduce footprint
}
```

### 4.4.2 FutureTask的handlePossibleCancellationInterrupt方法

前面分析的`run`方法里的最后有一个`finally`块，此时若任务状态`state >= INTERRUPTING`，此时说明有其他线程执行了`cancel(true)`方法，此时需要让出`CPU`执行的时间片段给其他线程执行。

源码：

```java
// FutureTask.java

private void handlePossibleCancellationInterrupt(int s) {
    // It is possible for our interrupter to stall before getting a
    // chance to interrupt us.  Let's spin-wait patiently.
    // 当任务状态是INTERRUPTING时，此时让出CPU执行的机会，让其他线程执行
    if (s == INTERRUPTING)
        while (state == INTERRUPTING)
            Thread.yield(); // wait out pending interrupt

    // assert state == INTERRUPTED;

    // We want to clear any interrupt we may have received from
    // cancel(true).  However, it is permissible to use interrupts
    // as an independent mechanism for a task to communicate with
    // its caller, and there is no way to clear only the
    // cancellation interrupt.
    //
    // Thread.interrupted();
}
```

## **4.5 FutureTask.get方法,获取任务执行结果**

简述：在get的时候，先查看其状态是否是执行完毕，没有的话就调用`awaitDone`方法阻塞等待。在任务执行完毕之后，才会调用`report`方法报告任务结果。这个时候可能情况有三种：正常，异常和取消。

前面也讲到了，只可以有一个线程执行任务，但是可以有多个线程等待结果。多个线程在等待的时候会调用`LockSupport.park(this);`方法阻塞当前线程。当结束之后会调用`finishCompletion`来唤醒并且移除`WaitNode`。

下面是判断过程的详述：

### 4.5.1 FutureTask.awaitDone方法

`FutureTask.awaitDone`方法会阻塞获取异步任务执行结果的当前线程，直到异步任务执行完成。

```java
// FutureTask.java

private int awaitDone(boolean timed, long nanos)
    throws InterruptedException {
    // 计算超时结束时间
    final long deadline = timed ? System.nanoTime() + nanos : 0L;
    // 线程链表头节点
    WaitNode q = null;
    // 是否入队
    boolean queued = false;
    // 死循环
    for (;;) {
        // 如果当前获取任务执行结果的线程被中断，此时移除该线程WaitNode链表节点，并抛出InterruptedException
        if (Thread.interrupted()) {
            removeWaiter(q);
            throw new InterruptedException();
        }

        int s = state;
        // 【5】如果任务状态>COMPLETING，此时返回任务执行结果，其中此时任务可能正常结束（NORMAL）,可能抛出异常（EXCEPTIONAL）
        // 或任务被取消（CANCELLED，INTERRUPTING或INTERRUPTED状态的一种）
        if (s > COMPLETING) {
            // 【问】此时将当前WaitNode节点的线程置空，其中在任务结束时也会调用finishCompletion将WaitNode节点的thread置空，
            // 这里为什么又要再调用一次q.thread = null;呢？
            // 【答】因为若很多线程来获取任务执行结果，在任务执行完的那一刻，此时获取任务的线程要么已经在线程等待链表中，要么
            // 此时还是一个孤立的WaitNode节点。在线程等待链表中的的所有WaitNode节点将由finishCompletion来移除（同时唤醒）所有
            // 等待的WaitNode节点，以便垃圾回收；而孤立的线程WaitNode节点此时还未阻塞，因此不需要被唤醒，此时只要把其属性置为
            // null，然后其有没有被谁引用，因此可以被GC。
            if (q != null)
                q.thread = null;
            // 【重要】返回任务执行结果
            return s;
        }
        // 【4】若任务状态为COMPLETING，此时说明任务正在执行过程中，此时获取任务结果的线程需让出CPU执行时间片段
        else if (s == COMPLETING) // cannot time out yet
            Thread.yield();
        // 【1】若当前线程还没有进入线程等待链表的WaitNode节点，此时新建一个WaitNode节点，并把当前线程赋值给WaitNode节点的thread属性
        else if (q == null)
            q = new WaitNode();
        // 【2】若当前线程等待节点还未入线程等待队列，此时加入到该线程等待队列的头部
        else if (!queued)
            queued = UNSAFE.compareAndSwapObject(this, waitersOffset,
                                                 q.next = waiters, q);
        // 若有超时设置，那么处理超时获取任务结果的逻辑
        else if (timed) {
            nanos = deadline - System.nanoTime();
            if (nanos <= 0L) {
                removeWaiter(q);
                return state;
            }
            LockSupport.parkNanos(this, nanos);
        }
        // 【3】若没有超时设置，此时直接阻塞当前线程
        else
            LockSupport.park(this);
    }
}
```

`FutureTask.awaitDone`方法主要做的事情总结如下：

1. 首先`awaitDone`方法里面是一个死循环；
2. 若获取结果的当前线程被其他线程中断，此时移除该线程WaitNode链表节点，并抛出InterruptedException；
3. 如果任务状态`state>COMPLETING`，此时返回任务执行结果；
4. 若任务状态为`COMPLETING`，此时获取任务结果的线程需让出CPU执行时间片段；
5. 若`q == null`，说明当前线程还未设置到`WaitNode`节点，此时新建`WaitNode`节点并设置其`thread`属性为当前线程；
6. 若`queued==false`，说明当前线程`WaitNode`节点还未加入线程等待链表，此时加入该链表的头部；
7. 当`timed`设置为true时，此时该方法具有超时功能，关于超时的逻辑这里不详细分析；
8. 当前面6个条件都不满足时，此时阻塞当前线程。

### 4.5.2 FutureTask.report方法

在`get`方法中，当异步任务执行结束后即不管异步任务正常还是异常结束，亦或是被`cancel`，此时获取异步任务结果的线程都会被唤醒，因此会继续执行`FutureTask.report`方法报告异步任务的执行情况，此时可能会返回结果，也可能会抛出异常。

```java
// FutureTask.java

private V report(int s) throws ExecutionException {
    // 将异步任务执行结果赋值给x，此时FutureTask的成员变量outcome要么保存着
    // 异步任务正常执行的结果，要么保存着异步任务执行过程中抛出的异常
    Object x = outcome;
    // 【1】若异步任务正常执行结束，此时返回异步任务执行结果即可
    if (s == NORMAL)
        return (V)x;
    // 【2】若异步任务执行过程中，其他线程执行过cancel方法，此时抛出CancellationException异常
    if (s >= CANCELLED)
        throw new CancellationException();
    // 【3】若异步任务执行过程中，抛出异常，此时将该异常转换成ExecutionException后，重新抛出。
    throw new ExecutionException((Throwable)x);
}
```

## 4.6 FutureTask.cancel方法,取消执行任务

前面提到过，cancel分为两种，其最后的结果也不同：可能是INTERRUPTED（发出中断信号），可能是CANCELLED（不发出中断信号）。且最后都要调用`finishCompletion`来唤醒等待进程并且移除`WaitNode`

详解：

```java
public boolean cancel(boolean mayInterruptIfRunning) {
    // 【1】判断当前任务状态，若state == NEW时根据mayInterruptIfRunning参数值给当前任务状态赋值为INTERRUPTING或CANCELLED
    // a）当任务状态不为NEW时，说明异步任务已经完成，或抛出异常，或已经被取消，此时直接返回false。
    // TODO 【问题】此时若state = COMPLETING呢？此时为何也直接返回false，而不能发出中断异步任务线程的中断信号呢？？
    // TODO 仅仅因为COMPLETING是一个瞬时态吗？？？
    // b）当前仅当任务状态为NEW时，此时若mayInterruptIfRunning为true，此时任务状态赋值为INTERRUPTING；否则赋值为CANCELLED。
    if (!(state == NEW &&
          UNSAFE.compareAndSwapInt(this, stateOffset, NEW,
              mayInterruptIfRunning ? INTERRUPTING : CANCELLED)))
        return false;
    try {    // in case call to interrupt throws exception
        // 【2】如果mayInterruptIfRunning为true，此时中断执行异步任务的线程runner（还记得执行异步任务时就把执行异步任务的线程就赋值给了runner成员变量吗）
        if (mayInterruptIfRunning) {
            try {
                Thread t = runner;
                if (t != null)
                    // 中断执行异步任务的线程runner
                    t.interrupt();
            } finally { // final state
                // 最后任务状态赋值为INTERRUPTED
                UNSAFE.putOrderedInt(this, stateOffset, INTERRUPTED);
            }
        }
    // 【3】不管mayInterruptIfRunning为true还是false，此时都要调用finishCompletion方法唤醒阻塞的获取异步任务结果的线程并移除线程等待链表节点
    } finally {
        finishCompletion();
    }
    // 返回true
    return true;
}
```

从`FutureTask.cancel`源码中我们可以得出答案，该方法并不能真正中断正在执行异步任务的线程，只能对执行异步任务的线程发出中断信号。如果执行异步任务的线程处于`sleep`、`wait`或`join`的状态中，此时会抛出`InterruptedException`异常，该线程可以被中断；此外，如果异步任务需要在`while`循环执行的话，此时可以结合以下代码来结束异步任务线程，即执行异步任务的线程被中断时，此时`Thread.currentThread().isInterrupted()`返回`true`，不满足`while`循环条件因此退出循环，结束异步任务执行线程。

**注意**：调用了`FutureTask.cancel`方法，只要返回结果是`true`，假如异步任务线程虽然不能被中断，即使异步任务线程正常执行完毕，返回了执行结果，此时调用`FutureTask.get`方法也不能够获取异步任务执行结果，此时会抛出`CancellationException`异常。请问知道这是为什么吗？

因为调用了`FutureTask.cancel`方法，只要返回结果是`true`，此时的任务状态为`CANCELLED`或`INTERRUPTED`,同时必然会执行`finishCompletion`方法，而`finishCompletion`方法会唤醒获取异步任务结果的线程等待列表的线程，而获取异步任务结果的线程唤醒后发现状态`s >= CANCELLED`，此时就会抛出`CancellationException`异常了。

