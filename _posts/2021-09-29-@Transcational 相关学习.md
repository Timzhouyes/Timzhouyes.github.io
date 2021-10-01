---
layout:     post   				    # 使用的布局（不需要改）
title:      Spring 相同类中@Transcational 相关学习  		# 标题 
subtitle:   包括各种情况下的解决办法        #副标题
date:       2021-09-29		# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - Soring
    - Transactional
---

之前遇到了一些和@Transactional 相关的问题，刚好遇到一骗比较好的博文：https://medium.com/javarevisited/spring-transactional-mistakes-everyone-did-31418e5a6d6b，将其中的内容梳理一下。

# 1. 为什么在同类之中直接@Transactional 不生效

比如作者在文中给出的下面的例子：

```java
public void registerAccount(Account acc) {
    createAccount(acc);

    notificationSrvc.sendVerificationEmail(acc);
}

@Transactional
public void createAccount(Account acc) {
    accRepo.save(acc);
    teamRepo.createPersonalTeam(acc);
}
```

这里面的 `createAccount()`上面的`@Transactional`，在上面的`registerAccount()`之中是不会生效的。原因在于这种 annotation，实际上 spring 是使用AOP 的方式进行的代理类，所以只有**当一个 bean 被另一个 bean 调用的时候**，这个过程才会发生。上面的调用很明显，就是在同一个类之中的调用，因此不会有任何的代理。

# 2. 如何解决@Transactional 在同类之中不生效

作者给出了三种方式：

1. Self-inject：即在自身之中引用自身
2. 创建另一层抽象
3. 在 `registerAccount()`之中用`TransactionTemplate`来包裹`createAccount()`的调用

**第一种方式：**

```java
@Service
@RequiredArgsConstructor
public class AccountService {
    private final AccountRepository accRepo;
    private final TeamRepository teamRepo;
    private final NotificationService notificationSrvc;
    @Lazy private final AccountService self;

    public void registerAccount(Account acc) {
        self.createAccount(acc);

        notificationSrvc.sendVerificationEmail(acc);
    }

    @Transactional
    public void createAccount(Account acc) {
        accRepo.save(acc);
        teamRepo.createPersonalTeam(acc);
    }
}
```

可以看到其在自身之中使用@Lazy 来引用自己，并且使用

**第三种方式**

使用`TransactionManager`来做，同时 `TransactionManager` 之中也可以做不只一个的数据源的Transaction。

```java
@Transactional
public void saveAccount(Account acc) {
    dataSource1Repo.save(acc);
    dataSource2Repo.save(acc);
}
```

可以使用 `ChainedTransactionManager`来做，这种方式可以 declear 多重数据源，并且如果有一场，会按照相反的顺序来进行 rollback。

**但是，本身已经提交了的 commit 不会回滚！比如：**

```bash
1st TX Platform: begin
  2nd TX Platform: begin
    3rd Tx Platform: begin
    3rd Tx Platform: commit
  2nd TX Platform: commit <-- fail
  2nd TX Platform: rollback  
1st TX Platform: rollback
```

这种情况之中，只有前两个操作会回滚，而第三个不会，因为其已经 commit 成功了。
