---
layout:     post   				    # 使用的布局（不需要改）
title:      JavaScript基础学习（2）			# 标题 
subtitle:    从第十一节-this 开始                #副标题
date:       2019-05-14 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 日常
    - 记录
    - Study
    - JavaScript
---

# 11-this

解析器在调用函数每次都会向函数内部传递进一个隐含的参数，这个隐含的参数就是this，this指向的是一个对象，这个对象我们称为函数执行的 上下文对象。

根据函数的调用方式的不同，this会指向不同的对象：【重要】

- 1.以函数的形式调用时，this永远都是window。比如`fun();`相当于`window.fun();`
- 2.以方法的形式调用时，this是调用方法的那个对象
- 3.以构造函数(constructor)形式调用时，this是新创建的那个对象
- 4.使用call和apply调用时，this是指定的那个对象

**针对第1条的举例**：

```
    function fun() {
        console.log(this);
        console.log(this.name);
    }

    var obj1 = {
        name: "smyh",
        sayName: fun
    };

    var obj2 = {
        name: "vae",
        sayName: fun
    };

    var name = "全局的name属性";

    //以函数形式调用，this是window
    fun();       //可以理解成 window.fun()
```

打印结果：

```
    Window
    全局的name属性
```

上面的举例可以看出，this指向的是window对象，所以 this.name 指的是全局的name。

**第2条的举例**：

```
        function fun() {
            console.log(this);
            console.log(this.name);
        }

        var obj1 = {
            name: "smyh",
            sayName: fun
        };

        var obj2 = {
            name: "vae",
            sayName: fun
        };

        var name = "全局的name属性";

        //以方法的形式调用，this是调用方法的对象
        obj2.sayName();
```

打印结果：

```
    Object
    vae
```

上面的举例可以看出，this指向的是 对象 obj2 ，所以 this.name 指的是 obj2.name。

#### 类数组 arguments

在调用函数时，浏览器每次都会传递进两个隐含的参数：

- 1.函数的上下文对象 this
- 2.**封装实参的对象** arguments

例如：

```
    function foo() {
        console.log(arguments);
        console.log(typeof arguments);
    }

    foo();
```

[![img](https://camo.githubusercontent.com/1fdfe8a7bc24efa30c2721aabd28ff767c9d898d/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303331355f303930332e706e67)](https://camo.githubusercontent.com/1fdfe8a7bc24efa30c2721aabd28ff767c9d898d/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303331355f303930332e706e67)

arguments是一个类数组对象，它可以通过索引来操作数据，也可以获取长度。

**arguments代表的是实参**。在调用函数时，我们所传递的实参都会在arguments中保存。有个讲究的地方是：arguments**只在函数中使用**。

### 1、返回函数**实参**的个数：arguments.length

arguments.length可以用来获取**实参的长度**。

举例：

```
    fn(2,4);
    fn(2,4,6);
    fn(2,4,6,8);

    function fn(a,b) {
        console.log(arguments);
        console.log(fn.length);         //获取形参的个数
        console.log(arguments.length);  //获取实参的个数

        console.log("----------------");
    }
```

打印结果：

[![img](https://camo.githubusercontent.com/e7fbc0fbf771f8a378760bb7c1669873f175a8e6/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f323134302e706e67)](https://camo.githubusercontent.com/e7fbc0fbf771f8a378760bb7c1669873f175a8e6/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f323134302e706e67)

可见其哪怕传入了多余形参的个数，其也可以识别出来。但是形参的个数并不随着实参个数的改变而改变。

我们即使不定义形参，也可以通过arguments来使用实参（只不过比较麻烦）：arguments[0] 表示第一个实参、arguments[1] 表示第二个实参...

### 2、返回正在执行的函数：arguments.callee

arguments里边有一个属性叫做callee，这个属性对应一个函数对象，就是当前正在指向的函数对象。

```
    function fun() {

        console.log(arguments.callee == fun); //打印结果为true
    }

    fun("hello");
```

在使用函数**递归**调用时，推荐使用arguments.callee代替函数名本身。

### 3、arguments可以修改元素

之所以说arguments是伪数组，是因为：**arguments可以修改元素，但不能改变数组的长短**。举例：

```
    fn(2,4);
    fn(2,4,6);
    fn(2,4,6,8);

    function fn(a,b) {
        arguments[0] = 99;  //将实参的第一个数改为99
        arguments.push(8);  //此方法不通过，因为无法增加元素
    }
```

# 12-对象的创建&构造函数

注意，在 JS 之中，对象之中元素的确定是使用键值对的方式，而不是用等号赋值确定的。

#### 创建自定义对象的几种方法

###### 方式一：对象字面量

**对象的字面量**就是一个{}。里面的属性和方法均是**键值对**。

例如：

```
var o = {
            name: "生命壹号",
            age: 26,
            isBoy: true,
            sayHi: function() {
                console.log(this.name);
            }
        };

console.log(o);
```

控制台输出：

[![img](https://camo.githubusercontent.com/f7768af058951b072f64ed94417935001adf54f6/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f313833342e706e67)](https://camo.githubusercontent.com/f7768af058951b072f64ed94417935001adf54f6/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f313833342e706e67)

### 方式二：工厂模式

工厂模式的步骤是先建一个工厂方法，然后在方法之中创建对象，再把这些对象赋给函数体外面的 var 变量。

```javascript
        /*
         * 使用工厂方法创建对象
         *  通过该方法可以大批量的创建对象
         */
        function createPerson(name, age, gender) {
            //创建一个新的对象
            var obj = new Object();
            //向对象中添加属性
            obj.name = name;
            obj.age = age;
            obj.gender = gender;
            obj.sayName = function() {
                alert(this.name);
            };
            //将新的对象返回
            return obj;
        }

        var obj2 = createPerson("猪八戒", 28, "男");
        var obj3 = createPerson("白骨精", 16, "女");
        var obj4 = createPerson("蜘蛛精", 18, "女");
```

**弊端：**

使用工厂方法创建的对象，使用的构造函数都是Object。**所以创建的对象都是Object这个类型，就导致我们无法区分出多种不同类型的对象**。

### 方式三：利用构造函数

构造函数之中并没有新建一个 Object 的步骤，而是使用this直接赋值。因此在使用构造函数的时候，要对变量 new 。 构造函数之中的this指的是其要新建的对象。

```
        //利用构造函数自定义对象
        var stu1 = new Student("smyh");
        console.log(stu1);
        stu1.sayHi();

        var stu2 = new Student("vae");
        console.log(stu2);
        stu2.sayHi();


        // 创建一个构造函数
        function Student(name) {
            this.name = name;    //this指的是构造函数中的对象实例
            this.sayHi = function () {
                console.log(this.name + "厉害了");
            }
        }
```

打印结果：

[![img](https://camo.githubusercontent.com/f61f151c6854ada278e294903a5dba9c1a7768c5/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f313335302e706e67)](https://camo.githubusercontent.com/f61f151c6854ada278e294903a5dba9c1a7768c5/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132355f313335302e706e67)

##### 下面是详细讲一下构造函数：

构造函数和普通函数的区别就是调用方式的不同。普通函数直接调用，构造函数使用 new 关键字进行调用。

this 的指向也不同，这些我们之前说过了：

- 1.以函数的形式调用时，this永远都是window。比如`fun();`相当于`window.fun();`
- 2.以方法的形式调用时，this是调用方法的那个对象
- 3.以构造函数的形式调用时，this是新创建的那个对象

#### new 一个构造函数的执行流程

（1）开辟内存空间，存储新创建的对象

（2）将新建的对象设置为构造函数中的this，在构造函数中可以使用this来引用 新建的对象

（3）执行函数中的代码（包括设置对象属性和方法等）

（4）将新建的对象作为返回值返回

因为this指的是new一个Object之后的对象实例。于是，下面这段代码：

```
        // 创建一个函数
        function createStudent(name) {
            var student = new Object();
            student.name = name;      //第一个name指的是student对象定义的变量。第二个name指的是createStudent函数的参数。二者不一样
        }
```

可以改进为：

```
        // 创建一个函数
        function Student(name) {
            this.name = name;       //this指的是构造函数中的对象实例
        }
```

注意上方代码中的注释。

#### 类，实例

###### 使用 instanceof 可以检查一个对象是否为一个类的实例

**语法如下**：

```
对象 instanceof 构造函数
```

如果是，则返回true；否则返回false。

```
      function Person() {}

      function Dog() {}

      var person1 = new Person();

      var dog1 = new Dog();

      console.log(person1 instanceof Person); // 打印结果： true
      console.log(dog1 instanceof Person); // 打印结果：false

      console.log(dog1 instanceof Object); // 所有的对象都是Object的后代。因此，打印结果为：true
```

根据上方代码中的最后一行，需要补充一点：**所有的对象都是Object的后代，因此 任何对象 instanceof Object 的返回结果都是true**。

另外，对象和json没有长度，json.length的打印结果是undefined。于是乎，自然也就不能用for循环遍历（因为遍历时需要获取长度length）。

**json遍历的方法：**

json 采用 `for...in...`进行遍历，和数组的遍历方式不同。如下：

```
<script>
    var myJson = {
        "name": "smyhvae",
        "aaa": 111,
        "bbb": 222
    };

    //json遍历的方法：for...in...
    for (var key in myJson) {
        console.log(key);   //获取 键
        console.log(myJson[key]); //获取 值（第二种属性绑定和获取值的方法）
        console.log("------");
    }
</script>
```

打印结果：

[![img](https://camo.githubusercontent.com/95d76ec3b144bc5481dfb761af243a24f9fd7a5a/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303230335f313531382e706e67)](https://camo.githubusercontent.com/95d76ec3b144bc5481dfb761af243a24f9fd7a5a/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303230335f313531382e706e67)



# 13-原型对象(Prototype)

#### 原型的引入

如果我们要使用一个 class 去创建很多个 Object， 那么给每一个 Object 一个方法有些过于浪费空间的奢侈，将函数直接定义在全局作用域之中又会有安全因素，因此使用原型对象。

#### 原型 prototype 的概念

原型对象就相当于一个公共的区域，所有同一个类的实例都是访问一个原型对象。

在应用之中，对于Object ， 可以使用 `__proto__`，对于 Class，可以使用`.prototype`来指向原型对象。

以后就可以将所有对象共有的属性直接放在 prototype 之中了，下面是例子：

```javascript
       function Person(name, age, gender) {
            this.name = name;
            this.age = age;
            this.gender = gender;

        }
        Person.prototype.sayName = function () {
            console.log("Hello大家好，我是:" + this.name);
        };
        Person.prototype.test="test";


        var per1 = new Person("name1", 1, "M");
        var per2=new Person("name2",2,"F");

        console.log(per1.__proto__);
        console.log(per1.sayName());
        console.log("age" in per1);     //true
        console.log("sayName" in per1);     //true
        console.log(per1.hasOwnProperty("sayName"));        //false
        
        console.log("Name of User 2 is "+per2.test);    //All objects from Person can visit
        
        console.log(per1.__proto__ == Person.prototype); // 打印结果：true
```

#### 对象的 toString() 方法

我们先来看下面这段代码：

```
	function Person(name, age, gender) {
	this.name = name;
	this.age = age;
	this.gender = gender;
	}

	var per1 = new Person("vae", 26, "男");

	console.log("per1 = " + per1);
	console.log("per1 = " + per1.toString());
```

打印结果：

```
per1 = [object Object]
per1 = [object Object]
```

上面的代码中，我们尝试打印实例 per1 的内部信息，但是发现，无论是打印 `per1` 还是打印 `per1.toString()`，结果都是`object`，这是为啥呢？分析如下：

- 当我们直接在页面中打印一个对象时，其实是输出了对象的toString()方法的返回值。
- 如果我们希望在打印对象时，不输出[object Object]，可以手动为对象添加一个toString()方法。意思是，重写 toString() 方法。

**想要在页面输出对象，那么需要我们重写 toString() 方法**

```javascript
		function Person(name, age, gender) {
            this.name = name;
            this.age = age;
            this.gender = gender;

        }
        //Method 1 "overwrite function for Person Class"
        Person.prototype.toString = function () {
            return ("Person[name:"+this.name+",age="+this.age+",Gender="+this.gender);


        }
        console.log(per2.toString());
```

上面的方法是针对所有的 Person 类都进行重写，当然我们也可以只针对 per2 进行重写，方法相似，只是换个作用对象。

#### JS 的 GC （垃圾回收） 机制

如果堆内存中的对象，没有任何变量指向它时，这个堆内存里的对象就会成为垃圾。

JS拥有自动的垃圾回收机制，会自动将这些垃圾对象从内存中销毁。我们不需要也不能进行垃圾回收的操作。我们仅仅需要做的是：如果你不再使用该对象，那么，将改对象的引用设置为 null 即可。



# 14-数组简介

#### 什么是数组

使用变量名和索引查找值的数据类型

#### 数组的基本操作

数组之中的元素可以是各种数据类型，包括对象，函数或者是数组。

如果数组之中存储的还是数组，那么我们称为二维数组。

#### 创建数组对象

**方式一**：字面量定义。举例：

```
var arr = [1,2,3];
```

**方式二**：对象定义（数组的构造函数）。

语法：

```
var arr = new Array(参数);
```

如果**参数为空**，则表示创建一个空数组；参数位置是**一个数值**时，表示数组长度；参数位置是**多个数值**时，表示数组中的元素。

上面的两种方式，我来举个例子：

```
    // 方式一
    var arr1 = [11, 12, 13];

    // 方式二
    var arr2 = new Array(); // 参数为空
    var arr3 = new Array(4); // 参数为一个数值
    var arr4 = new Array(15, 16, 17); // 参数为多个数值

    console.log(typeof arr1);  // 打印结果：object

    console.log("arr1 = " + JSON.stringify(arr1));
    console.log("arr2 = " + JSON.stringify(arr2));
    console.log("arr3 = " + JSON.stringify(arr3));
    console.log("arr4 = " + JSON.stringify(arr4));
```

打印结果：

```
object

arr1 = [11,12,13]
arr2 = []
arr3 = [null,null,null,null]
arr4 = [15,16,17]
```

从上方打印结果的第一行里，可以看出，数组的类型其实也是属于**对象**。

#### 向数组之中添加元素

语法：

```
    数组[索引] = 值
```

代码举例：

```
    var arr1 = [];

    // 向数组中添加元素
    arr[0] = 10;
    arr[1] = 33;
    arr[2] = 22;
    arr[3] = 44;
```

### 获取数组中的元素

语法：

```
    数组[索引]
```

数组的索引代表的是数组中的元素在数组中的位置，从0开始。

如果读取不存在的索引（比如元素没那么多），系统不会报错，而是返回undefined。

代码举例：

```
    var arr = [21, 22, 23];

    console.log(arr[0]); // 打印结果：21
    console.log(arr[5]); // 打印结果：undefined
```

**注意此处，如果是超出了索引，系统不会报错，但是会返回 undefined。**

#### 获取数组的长度

对于连续的数组，使用length可以获取到数组的长度（元素的个数）；对于非连续的数组，使用length会获取到数组的最大的索引+1。因此，尽量不要创建非连续的数组。

#### 修改数组的长度（修改length）

- 如果修改的length大于原长度，则多出部分会空出来，置为 null。
- 如果修改的length小于原长度，则多出的元素会被删除，数组将从后面删除元素。

注：想要将数组以 JSON 形式打印出来，要使用 `json.stringify`

# 15- 数组的四个基本方法&数组遍历

先上表：

**数组的四个基本方法如下**：

注意此处的返回值：如果参数是元素，那么返回的是改变之后数组的长度；如果没有参数，返回的是修改的元素。

| 方法      | 描述                                                         | 备注         |
| --------- | ------------------------------------------------------------ | ------------ |
| push()    | 向数组的**最后面**插入一个或多个元素，返回结果为**该数组新的长度** | 会改变原数组 |
| pop()     | 删除数组中的**最后一个**元素，返回结果为**被删除的元素**     | 会改变原数组 |
| unshift() | 在数组**最前面**插入一个或多个元素，返回结果为**该数组新的长度** | 会改变原数组 |
| shift()   | 删除数组中的**第一个**元素，返回结果为**被删除的元素**       | 会改变原数组 |

**遍历数组的方法如下**：

| 方法      | 描述                               | 备注                                                   |
| --------- | ---------------------------------- | ------------------------------------------------------ |
| for循环   | 这个大家都懂                       |                                                        |
| forEach() | 和 for循环类似，但需要兼容IE8以上  | forEach() 没有返回值。也就是说，它的返回值是 undefined |
| filter()  | 返回结果是true的项，将组成新的数组 | 可以起到过滤的作用                                     |
| map()     | 对原数组中的每一项进行加工         |                                                        |
| every()   | 如果有一项返回false，则停止遍历    | 意思是，要求每一项都返回true，最终的结果才返回true     |
| some()    | 只要有一项返回true，则停止遍历     |                                                        |

## 数组的遍历

遍历数组的方法包括：every()、filter()、forEach()、map()、some()

PS：这几个方法**不会修改原数组**。

语法格式：

```
数组/boolean/无 = 数组.every/filter/forEach/map/some(
                            function(element,index,arr){
                                            程序和返回值；
```

##### forEach() 循环遍历

forEach() 需要一个函数作为参数，这种函数是我们创建但是不是我们调用的，称为回调函数。数组之中有几个元素，回调函数就会执行几次。

回调函数之中传递三个参数：

- 第一个：当前正在遍历的元素
- 第二个：当前正在遍历的元素的索引
- 第三个：正在遍历的数组

代码举例：

```
    var arr = ["王一", "王二", "王三"];

    arr.forEach(function(item, index, obj) {
    console.log("item:" + item);
    console.log("index:" + index);
    console.log("obj:" + obj);
    console.log("----------");
    });
```

打印结果：

```
item:王一
index:0
obj:王一,王二,王三
----------

item:王二
index:1
obj:王一,王二,王三
----------

item:王三
index:2
obj:王一,王二,王三
----------
```

注意，forEach() 的返回值是 undefined。也就是说，它没有返回值。如果你尝试 `tempArry = arr.forEach()`这种方式来接收，是达不到效果的。

##### filter()

语法：

```
    Array.prototype.filter(function(item, index){})
```

对数组之中每一项运行回调函数，对于返回结果是 true 的项，将组成新的数组。返回值就是这个新的数组。

其中的function 的参数和之前的一样。

举例1：找出数组 arr1 中大于4的元素，返回一个新的数组。代码如下：

```
    var arr1 = [1, 3, 6, 2, 5, 6];

    var arr2 = arr1.filter(function (item, index) {
        return item > 4; //将arr1中大于4的元素返回
    })
    console.log(arr2);
```

打印结果：

[![img](https://camo.githubusercontent.com/1f7d8482faf3e375eb8c28af65bd500673366a1b/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303430325f303935312e706e67)](https://camo.githubusercontent.com/1f7d8482faf3e375eb8c28af65bd500673366a1b/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303430325f303935312e706e67)

举例2：

```
    var arr1 = ["千古", "宿敌", "南山忆", "素颜"];

    var arr2 = arr1.filter(function (element, index, array) {
        if (element.length > 2) { //arr1中的元素，如果是长度超过2个字符的，我就把它放到arr2中去
            return true;
        }
        return false;
    });
    console.log(arr1);
    console.log(arr2);
```

结果：

[![img](https://camo.githubusercontent.com/828e99007afdafaa4946f503ed25e2708ac000d4/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132365f313431302e706e67)](https://camo.githubusercontent.com/828e99007afdafaa4946f503ed25e2708ac000d4/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132365f313431302e706e67)

##### map() 方法

对数组之中每一项都使用回调函数，然后返回该函数的结果，也就是返回一个加工之后的数组。

解释：对数组中每一项运行回调函数，返回该函数的结果，组成的新数组（返回的是**加工之后**的新数组）。

比如说，有一个已知的数组arr1，我要求让arr1中的每个素加10，这里就可以用到map方法。举例：

```
    var arr1 = [1, 3, 6, 2, 5, 6];

    var arr2 = arr1.map(function (item, index) {
        return item + 10;  //让arr1中的每个元素加10

    })
    console.log(arr2);
```

打印结果：

[![img](https://camo.githubusercontent.com/d060b1224e56f2d1a1b9807cd368dedc80fe0f39/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303430325f303933382e706e67)](https://camo.githubusercontent.com/d060b1224e56f2d1a1b9807cd368dedc80fe0f39/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303430325f303933382e706e67)

举例2：

```
    var arr1 = ["千古", "宿敌", "南山忆", "素颜"];

    var arr2 = arr1.map(function (element, index, array) {
        return element + "vae";  //给arr1中所有的元素增加字符串"vae"，放到arr2中。
    });

    console.log(arr1);
    console.log(arr2);
```

结果：

[![img](https://camo.githubusercontent.com/4318682f9f7ff4f7ffa9e2fc2aece1f40da4de6b/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132365f313432352e706e67)](https://camo.githubusercontent.com/4318682f9f7ff4f7ffa9e2fc2aece1f40da4de6b/687474703a2f2f696d672e736d79687661652e636f6d2f32303138303132365f313432352e706e67)

#### every()方法

解释：对数组中每一项运行回调函数，如果都返回true，every就返回true；如果有一项返回false，则停止遍历，此方法返回false。

注意：every()方法的返回值是boolean值，参数是回调函数。

举例：

```
    var arr1 = ["千古", "宿敌", "南山忆", "素颜"];
    var bool1 = arr1.every(function (element, index, array) {
        if (element.length > 2) {
            return false;
        }
        return true;
    });
    console.log(bool1);  //输出结果：false。只要有一个元素的长度是超过两个字符的，就返回false

    var arr2 = ["千古", "宿敌", "南山", "素颜"];
    var bool2 = arr2.every(function (element, index, array) {
        if (element.length > 2) {
            return false;
        }
        return true;
    });
    console.log(bool2);  //输出结果：true。因为每个元素的长度都是两个字符。
```

#### some()方法

解释：对数组中每一项运行回调函数，只要有一项返回true，则停止遍历，此方法返回true。

# 16-数组的常见方法

数组的常见方法如下：

| 方法      | 描述                                                         | 备注           |
| --------- | ------------------------------------------------------------ | -------------- |
| slice()   | 从数组中**提取**指定的一个或多个元素，返回结果为**新的数组** | 不会改变原数组 |
| splice()  | 从数组中**删除**指定的一个或多个元素，返回结果为**新的数组** | 会改变原数组   |
| concat()  | 连接两个或多个数组，返回结果为**新的数组**                   | 不会改变原数组 |
| join()    | 将数组转换为字符串，返回结果为**转换后的字符串**             | 不会改变原数组 |
| reverse() | 反转数组，返回结果为**反转后的数组**                         | 会改变原数组   |
| sort()    | 对数组的元素,默认按照**Unicode编码**，从小到大进行排序       | 会改变原数组   |

##### slice()

`slice()`：从数组之中提取一个或者多个元素，返回成为新数组

**语法**：

```
	新数组 = 原数组.slice(开始位置的索引, 结束位置的索引);    //注意：包含开始索引，不包含结束索引
```

举例：

```
	var arr = ["a", "b", "c", "d", "e", "f"];

	var result1 = arr.slice(2); //从第二个值开始提取
	var result2 = arr.slice(-2); //提取最后两个元素
	var result3 = arr.slice(2, 4); //提取从第二个到第四个之间的值（不包括第四个值）
	var result4 = arr.slice(4, 2); //空

	console.log("arr:" + JSON.stringify(arr));
	console.log("result1:" + JSON.stringify(result1));
	console.log("result2:" + JSON.stringify(result2));
	console.log("result3:" + JSON.stringify(result3));
	console.log("result4:" + JSON.stringify(result4));
```

打印结果：

```
	arr:["a","b","c","d","e","f"]
	result1:["c","d","e","f"]
	result2:["e","f"]
	result3:["c","d"]
	result4:[]
```

#### **javascript伪数组**

1: 什么是伪数组

```
伪数组是一个含有length属性的json对象，

它是按照索引的方式存储数据，

它并不具有数组的一些方法，只能能通过Array.prototype.slice转换为真正的数组，并且带有length属性的对象。
```



```
    var obj = {0:'a',1:'b',length:2}; // 伪数组
    var arr = Array.prototype.slice.call(obj); // 转化为数组    
    console.log(arr);  // 返回["a","b"]
 
```

2 : 它和数组的关系

```
都是模拟集合
```

3：为什么会有伪数组

```
	 在日常开发中，有许多的对象是由伪数组组成，比如函数内arguments对象，还有像调用getElementsByTagName,document.childNodes之类的，它们都返回NodeList对象都属于伪数组.
```

4：为什么使用Array.prototype.slice.call()方法可以将伪数组转化数组

```
 其实我们也可以通过[].slice.call这种形式实现同样的效果，但是通过prototype的形式执行程序效率更高，同样代码也更加优美。 

这个是V8引擎中Array.js对slice方发的实现过程，有兴趣的同学可以研究下。

我理解的大概思路就是 ↓ ，可能不对，仅供参考。
function slice(obj) {
    var arr =[];
    var len = obj.length; // length 正好对应伪数组中的length属性
    for(var i = 0;i < len;i++){
        arr.push[i] = obj[i]; // i 正好对应伪数组中的索引值
    }
    return arr;
}
 
```



5：Jquery与伪数组

伪数组，就是带有编号，内容和长度的json，其本身并不带有数组的方法，但是可以通过转换形成真的数组。

```
其实Jquery内部大量运用了伪数组。可以说整个Jquery对象，都是构建在伪数组的基础之上的。
```

很多前端开发人员会用 slice()将伪数组，转化为真数组。写法如下：

```
array = Array.prototye.slice.call(arrayLike)
或者
array = [].slice.call(arrayLike)
```

ES6 看不下去这种蹩脚的转化方法，于是出了一个新的 API：（专门用来将伪数组转化成真数组）

```
array = Array.from(arrayLike)
```

##### splice()

`splice()`：从数组中**删除**指定的一个或多个元素，返回结果为**新的数组**（会改变原来的数组，会将指定元素从原数组中删除）。

语法：

```
	新数组 = 原数组.splice(起始索引index, 需要删除的个数, 第三个参数, 第四个参数...);
```

上面的语法之中，第三个及以后的参数，表示向原数组之中添加新的元素，会自动插入到开始位置索引之前。

我个人的认为，splice 的意思其实是从第几位开始从原数组转移到另一个数组之中。下面的代码和输出结果就是：

举例1：

```
	var arr1 = ["a", "b", "c", "d", "e", "f"];
	var result1 = arr1.splice(1); //从第index为1的位置开始，删除元素

	console.log("arr1：" + JSON.stringify(arr1));
	console.log("result1：" + JSON.stringify(result1));

	console.log("-----------------------");

	var arr2 = ["a", "b", "c", "d", "e", "f"];
	var result2 = arr2.splice(-2); //从第一个位置开始，删除元素

	console.log("arr2：" + JSON.stringify(arr2));
	console.log("result2：" + JSON.stringify(result2));

	console.log("-----------------------");

	var arr3 = ["a", "b", "c", "d", "e", "f"];
	var result3 = arr3.splice(1, 3); //从第index为1的位置开始删除元素,一共删除三个元素

	console.log("arr3：" + JSON.stringify(arr3));
	console.log("result3：" + JSON.stringify(result3));

	console.log("-----------------------");
```

打印结果：

```
举例1：

	var arr1 = ["a", "b", "c", "d", "e", "f"];
	var result1 = arr1.splice(1); //从第index为1的位置开始，删除元素

	console.log("arr1：" + JSON.stringify(arr1));
	console.log("result1：" + JSON.stringify(result1));

	console.log("-----------------------");

	var arr2 = ["a", "b", "c", "d", "e", "f"];
	var result2 = arr2.splice(-2); //从第一个位置开始，删除元素

	console.log("arr2：" + JSON.stringify(arr2));
	console.log("result2：" + JSON.stringify(result2));

	console.log("-----------------------");

	var arr3 = ["a", "b", "c", "d", "e", "f"];
	var result3 = arr3.splice(1, 3); //从第index为1的位置开始删除元素,一共删除三个元素

	console.log("arr3：" + JSON.stringify(arr3));
	console.log("result3：" + JSON.stringify(result3));

	console.log("-----------------------");
打印结果：

arr1：["a"]
result1：["b","c","d","e","f"]
-----------------------

arr2：["a","b","c","d"]
result2：["e","f"]
-----------------------

arr3：["a","e","f"]
result3：["b","c","d"]
-----------------------arr1：["a"]
result1：["b","c","d","e","f"]
-----------------------

arr2：["a","b","c","d"]
result2：["e","f"]
-----------------------

arr3：["a","e","f"]
result3：["b","c","d"]
-----------------------
```

可以看到如果第一个参数是1，那么表示从位置为1 （第二个）开始就可以留住，如果是 -2， 那么表示从倒数第二位开始留，以此类推。

举例2：（我们来看看**第三个参数**的用法）

```
var arr4 = ["a", "b", "c", "d", "e", "f"];

//从第index为1的位置开始删除元素,一共删除三个元素。并且在 index=1 的前面追加两个元素
var result4 = arr4.splice(1, 3, "千古壹号", "vae");

console.log("arr4：" + JSON.stringify(arr4));
console.log("result4：" + JSON.stringify(result4));
```

可以看到从第二位开始都进入了另一个数组，与此同时，其在开始的位置插入了两个元素，就是我们的第三个和第四个参数。

#### concat()

`concat()`连接两个或者多个数组，返回结果是新的数组。

语法：

```
	新数组 = 数组1.concat(数组2, 数组3 ...);
```

通常会新建一个数组来保存连接之后的数组，使用`concat()`并不会修改原数组。

#### join()

`join()`:将数组转换成字符串。返回结果为转换之后的字符串。原有数组不会收到改变。

使用 join() 可以指定一个字符串作为参数，这个字符串会成为数组之中元素的**连接符**， 不指定的话，默认连接符是`，` 这个时候和 toString() 是一致的。

语法：

```
	新的字符串 = 原数组.join(参数); // 参数选填
```

#### reserve()

`reserve()` :反转数组，返回结果为反转之后的数组（会改变原来的数组）

