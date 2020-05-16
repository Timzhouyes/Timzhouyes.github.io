---
layout:     post   				    # 使用的布局（不需要改）
title:      LeetCode 双指针专题 Java实现  		# 标题 
subtitle:   包含题解和想法        #副标题
date:       2020-05-10		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - LeetCode
    - Double Pointer
---

上一份是二叉树的实现和想法，觉得在总结之中放入题目过于冗余，因为大家都会打开leetcode来看原题是什么，因此这份总结之中将题目部分删去，便于阅读。

在下面的资料基础之上加上个人的理解，部分代码进行明晰化，不搞缩写。

仍然是参考大佬：[https://github.com/CyC2018/CS-Notes/blob/master/notes/Leetcode%20%E9%A2%98%E8%A7%A3%20-%20%E5%8F%8C%E6%8C%87%E9%92%88.md](https://github.com/CyC2018/CS-Notes/blob/master/notes/Leetcode 题解 - 双指针.md)

# 1. 有序数组的two sum

167  Two Sum II - Input array is sorted (Easy)

[Leetcode](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/description/) / [力扣](https://leetcode-cn.com/problems/two-sum-ii-input-array-is-sorted/description/)

其过于经典，只要两个指针，一个从前向后，一个从后向前，二者不相遇循环不停止。

当和小于给定值的时候，前面指针向后一位。大于的时候后面指针向前一位。

```java
package Leetcode;

class Solution {
    public int[] twoSum(int[] numbers, int target) {
        int length = numbers.length;
        int i = 0, j = length - 1;
        int[] result = new int[2];
        while (i < j) {
            if (numbers[i] + numbers[j] == target) {
                result[0] = i + 1;
                result[1] = j + 1;
                break;
            } else if (numbers[i] + numbers[j] < target) {
                i++;
            } else if (numbers[i] + numbers[j] > target) {
                j--;
            }
        }
        return result;
    }
}
```

# * 2. 两数平方和

633 Sum of Square Numbers

https://leetcode.com/problems/sum-of-square-numbers/

本题之中最重要的是对右边的剪枝。而且不剪枝的话计算平方的时候，会直接把int撑爆。

如果让开始指针节点为0，那么结束指针节点应该是`Math.sqrt(target)`，这种情况下就会直接去掉很多的冗余的值。注意，`Math.sqrt(target)`之中返回的是double，因此要转换成(int)。

```java
class Solution {
    public boolean judgeSquareSum(int c) {
        int i=0,j=(int)Math.sqrt(c);
        while(i<=j){
            if(i*i+j*j==c) return true;
            else if(i*i+j*j>c) j--;
            else if(i*i+j*j<c) i++;
        }
        return false;
    }
}
```

# 3. 反转元音字符

345 Reverse Vowels of a String

https://leetcode.com/problems/reverse-vowels-of-a-string/

本题之中我和参考资料不大一样：

1. 其使用了HashSet进行存储和寻找元素，但我是直接if比较。相对而言hashSet的时间复杂度更低。

   此处也参阅：https://mp.weixin.qq.com/s/5Y_ES1XfE-xvX88wCTxq3g

   > 1. 对于生成的字节码，switch之中只取出了一次变量和条件进行比较，而if之中每次都要取出变量和条件进行比较
   > 2. switch之中的字节码也不同：在switch的判断条件比较紧凑的时候使用tableswitch，例如1...2...3...4这种依次递增的判断条件。其结构类似于数组，直接使用索引来进行查找，几乎是O(1)的。而case是1...33...555这种非紧凑就是lookupswitch，会逐个分支进行比较，或者使用二分法查询，因此查询的时间复杂度是O(logn)，使用lookupswitch比tableswitch慢。

2. 其将生成数组和值的判断放在一起使用，我是先生成后判断，分开进行。

```java
class Solution {
    public String reverseVowels(String s) {
        if(s.length()==0) return s;
        int i=0,j=s.length()-1;
        char[] charArray = new char[s.length()];
        for(int k=0;k<s.length();k++){
            charArray[k]=s.charAt(k);
            }
        
        while(i<j){
            while(!isVowel(charArray[i]) && i<j){
                i++;
            }
            while(!isVowel(charArray[j]) && i<j){
                j--;
            }
            if(charArray[i]!=charArray[j]){
                char temp = charArray[i];
                charArray[i] = charArray[j];
                charArray[j] = temp;
            }
            i++;
            j--;
        }
        
        StringBuilder sb =new StringBuilder();
        for(char c:charArray){
            sb.append(c);
        }
        return sb.toString();
    }
    
    public boolean isVowel(char c){
        if(c=='a'||c=='e'||c=='i'||c=='o'||c=='u'||c=='A'||c=='E'||c=='I'||c=='O'||c=='U') return true;
        return false;
    }
}
```

# 4. 容许一个字母不符合规则的回文字符串

680. Valid Palindrome II (Easy)

[Leetcode](https://leetcode.com/problems/valid-palindrome-ii/description/) / [力扣](https://leetcode-cn.com/problems/valid-palindrome-ii/description/)

题目之中允许了一个字母不符合规则。也就是如果删掉一个字母，是符合规则的，那么也可以。

本题之中还需要一个辅助函数`boolean isPalindrome(String s,int start,int end)`。

那么就分成了两部分：

1. 直接按照回文串的标准判断，不管其他的部分

2. 如果有一个字符不满足标准，假设此时的前指针是i，后指针是j，那么借助辅助函数来做：

   ```java
   return isPalindrome(s,i+1,j) || isPalindrome(s,i,j-1);
   ```

   也就是将第一个指针往后挪一位，或者将最后一个指针往前挪一位进行判断，因为只要有符合的就可以，所以二者是或的关系。且指针范围之外的部分已经判断完毕，所以可以直接略去。

```java
class Solution {
    public boolean validPalindrome(String s) {
        if(s.length()==0) return true;
        int i=0,j=s.length()-1;
        while(i<=j){
            if(s.charAt(i)==s.charAt(j)){
                i++;
                j--;
            }else{
                return isPalindrome(s,i+1,j) || isPalindrome(s,i,j-1);
            }
        }
        return true;
    }
    
    public boolean isPalindrome(String s,int start,int end){
        if(start>end) return false;
        while(start<=end){
            if(s.charAt(start)!=s.charAt(end)) return false;
            start++;
            end--;
        }
        return true;
    }
}
```

