---
layout:     post   				    # 使用的布局（不需要改）
title:      JWT相关				# 标题 
subtitle:   Studying JWT #副标题
date:       2019-04-03				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - JWT
    - 记录
    - Study
---
After reading a [toturial](http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html) of Mr.Ruan, just make some notes to memory.



























# 1. What is JWT ?
JWT is a way for users to save information in client side, so that in server side, we don't need to save sessions. 
# 2. The theory of JWT
After authentication of users, server sends a JSON to client, and after authentication, when users contact with server, it brings the JSON in the head of website. Preventing it from changed by users, when server generates the JWT, it will bring a *digital sign* with it.

And server can be stateless.

# 3. Data structure of JWT
JWT contains three parts
1. Header
2. Payload
3. Signature

## 3.1 Header
In header ,it contains:
1. ALG: the algorithm of signature. Default is HS256,which means **HMAC SHA256**. 
2. TYP:type of token, in JWT, is **JWT**.

Finally, use algorithm **Base64URL** to translate it into the string.
## 3.2 Payload
In payload, it contains:
1. iss (issuer)：签发人
2. exp (expiration time)：过期时间
3. sub (subject)：主题
4. aud (audience)：受众
5. nbf (Not Before)：生效时间
6. iat (Issued At)：签发时间
7. jti (JWT ID)：编号

In payload, we can define private field ,such as we define a **username** in the private field. 

Notice that default option for JWT is not encrypted , so don't put any secret in this part :)

This part also need to use **Base64URL** to convert to a string. 

## 3.3 Signature
In signature ,there is a **secret(密钥）** which only known by server, and then use the algorithm mentioned in header part ,which default is **HMAC SHA256** to encrypt it as the formula below :
> HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret)
  
# 3.4 Base64URL
Because some symbols, such as +, \ or = ,has special meaning in URL , so just change them and get a new algorithm.

# 4. Some features of JWT

1. we can not abolish token in the process of usage, because of server doesn't save session status. So it is better to change the valid period of JWT to shorter.
2. JWT should be transported by HTTPS, not HTTP.
  
