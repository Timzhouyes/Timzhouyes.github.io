---
layout:     post   				    # 使用的布局（不需要改）
title:      LeetCode 动态规划 Java实现 		# 标题 
subtitle:   包含题解和想法        #副标题
date:       2020-05-11		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - LeetCode
    - Dynamic programming
---

基于参考，进行自己的解读和代码编写。

动态规划，要将问题进行转换，从底到顶的进行求解。同时，要能将状态的转换抽象出状态转移方程，将方程之间的状态流转表示出来。

还是参照大佬的答案：

[https://github.com/CyC2018/CS-Notes/blob/master/notes/Leetcode%20%E9%A2%98%E8%A7%A3%20-%20%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92.md](https://github.com/CyC2018/CS-Notes/blob/master/notes/Leetcode 题解 - 动态规划.md)

# 斐波那契数列变种

## 1. 爬楼梯

70 Climbing Stairs (Easy)

[Leetcode](https://leetcode.com/problems/climbing-stairs/description/) / [力扣](https://leetcode-cn.com/problems/climbing-stairs/description/)

有n阶楼梯，每次上一阶或者两阶，问有多少种方式可以上楼梯？

为了表示方便，下标从1开始，下标是几就代表上几阶。

自底向上：

1. n=0,方式种类0
2. n=1,方式种类1
3. n=2,方式种类2

状态转移：

对于每一个台阶，其都是下一阶和下两阶的种类进行累加：`dp[n]=dp[n-1]+dp[n-2]`

暂存变量：

状态转移方程之中，每个状态只和两个其他状态相关，因此暂存变量两个即可。

循环次数：

0，1，2的次数都已经有了，那么从3开始循环。既然是到第n阶，那么循环应该包括第n阶。

代码：

```java
class Solution {
    public int climbStairs(int n) {
        if(n<3) return n;
        int pre =1,cur =2;
        for(int i=3;i<=n;i++){
            int sum = pre+cur;
            pre = cur;
            cur = sum;
        }
        return cur;
    }
}
```

## 2. 强盗抢劫，不可抢相邻屋子

198 House Robber

[Leetcode](https://leetcode.com/problems/house-robber/description/) / [力扣](https://leetcode-cn.com/problems/house-robber/description/)

自底向上：

1. nums.length==0：没有数组，抢不到
2. nums.length==1：只有一户，就抢他
3. nums.length==2：有两户，抢多的

状态转移方程：

对于每一个屋子，要么是抢其之前的+这个屋子，要么抢比其小一号的屋子:

`dp[i]=Math.max(dp[i-2]+nums[i-1],dp[i-1)`

暂存变量：

可以看出每次和状态来说，只和其之前的两个状态相关，因此只要保存之前的两个状态

循环次数：

从3开始，自然也还是要包括本身

```java
class Solution {
    public int rob(int[] nums) {
        if(nums.length==0) return 0;
        if(nums.length==1) return nums[0];
        if(nums.length==2) return Math.max(nums[0],nums[1]);
        int cur = Math.max(nums[0],nums[1]),pre = nums[0];
        for(int i=3;i<=nums.length;i++){
            int sum = Math.max(pre+nums[i-1],cur);
            pre = cur;
            cur = sum;
        }
        return cur;
    }
}
```

## 