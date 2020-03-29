---
layout:     post   				    # 使用的布局（不需要改）
title:      VSM 与每日记录				# 标题 
subtitle:   Studying Git #副标题
date:       2019-03-15 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 日常
    - 记录
    - Study
    - VSM
---

# Today's record:
1. In Angular, the basic logic is that one component/one thing is composed of one .js file and one .html file .The .js file contains functions of the thing , and the .html file contains apperance of the thing. One is logic, one is apperaence
2. 

# 1. VSM
VSM is a tool to analyse the whole process line. To draw a VSM ,first thing is to figure out the original process of production line, including all the processes such as from the shipping part and then every part we need in the process.

Then , we need to analyse through some methods , such as proccesses can change to flow production, supermarket pull, Kanban pull ,FIFO and others, like reduce the stock in inventory.

The third part is to draw a "future ideal VSM" ,and improve the process line through it.

# 2.What VSM can improve?
The main difference between the former one and the improved one is to 
1. Find out the link which can add value to the production and which can not
2. Cut down the production which can not add value as much as possible ,such as C/O 
3. Improve the sequence stream in the process which is possible to improve 
3. Eliminate the abnormal and unnecessary, Reduce the non-value added but necessary, Put the value-added processes in a natural flow sequence
# 3.What kind of chart users want?
To analyse, the maior thing to compare the time cut down on the whole process line. 

But in the promoted chart, it is impossible to analyse only one process before and after, because it maybe changed, deleted or combined, so the major chart is the time cut down.And if some processes can be comnined, the amount of workers maybe cut down also.

1. For one chart:
- All workers they need in production process
- The ratio of C/T (Effiency production time) with C/O (Time for changing model to produce another product)
- The proportion of C/T of every link to the whole process , to measure which part add the most value to the product
- The propotion of C/O of every link to the whole process, to measure which part in the Production line waste the most time 
2. For two charts (Before and after)
- The amount of processes on production line before and after
- The changes of the whole C/T and C/O , amount of time percentage which be reduced before and after
- The amount of workers that reduced ( But I cannot sure beacuse not everytime the workers can be reduced)



# 2019-10-17 Thur.

在 Groovy 之中，闭包 （clousure） 是一个很有趣，也有点难上手的东西。

下面这段代码之中去掉了敏感信息。

```groovy
 for (Product p : ProductList) {
                List<PromotionItem> discountedList = groupedList[p.id]
                p.variations = p.variations.collect { v ->
                    new ProductVariation(
                        id: v.id,
                        name: v.name
                    )
                }
  }
```

其中这个 v 我一开始看到觉得不明所以，后来在询问前辈之后发现其用法。下面是解释：

v，和其默认的 it 一样，是内部操作的一个变量。这个 collect 函数很迷的地方在于，点进去你会发现这个函数：

```groovy
 /**
     * Iterates through this collection transforming each entry into a new value using the <code>transform</code> closure
     * returning a list of transformed values.
     * <pre class="groovyTestCase">assert [2,4,6] == [1,2,3].collect { it * 2 }</pre>
     *
     * @param self      a collection
     * @param transform the closure used to transform each item of the collection
     * @return a List of the transformed values
     * @since 1.0
     */
    public static <S,T> List<T> collect(Collection<S> self, @ClosureParams(FirstParam.FirstGenericType.class) Closure<T> transform) {
        return (List<T>) collect(self, new ArrayList<T>(self.size()), transform);
    }
```

看看这个注释，一个叫做 collect 的函数，作用居然是 将整个数据按照 clousure 里面的代码规则进行处理之后再返回。为啥能有底气这么叫呢？再点进去实现咱看看。

```groovy
   /**
     * Iterates through this collection transforming each value into a new value using the <code>transform</code> closure
     * and adding it to the supplied <code>collector</code>.
     * <pre class="groovyTestCase">assert [1,2,3] as HashSet == [2,4,5,6].collect(new HashSet()) { (int)(it / 2) }</pre>
     *
     * @param self      a collection
     * @param collector the Collection to which the transformed values are added
     * @param transform the closure used to transform each item of the collection
     * @return the collector with all transformed values added to it
     * @since 1.0
     */
    public static <T,E> Collection<T> collect(Collection<E> self, Collection<T> collector, @ClosureParams(FirstParam.FirstGenericType.class) Closure<? extends T> transform) {
        for (E item : self) {
            collector.add(transform.call(item));
            if (transform.getDirective() == Closure.DONE) {
                break;
            }
        }
        return collector;
    }
```

看，对于每个 item， 都会进行 transfer， 然后再返回。

那么再回头看第一个代码块就很清楚了：作用就是按照闭包里面的内容，将 product p 里面的内容进行匹配 ProductVariation， 再将这个新创建的 ProductVariation 返回给外部的 p.variation。

太有趣了……