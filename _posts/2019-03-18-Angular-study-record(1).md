---
layout:     post   				    # 使用的布局（不需要改）
title:      Angular study				# 标题 
subtitle:   To study Angular #副标题
description: Try it now
date:       2019-03-18 				# 时间
author:     Haiming 						# 作者
header-img: img/post-bg-2015.jpg 	#这篇文章标题背景图片
catalog: true 						# 是否归档
tags:								#标签
    - Programming
    - 日常
    - 记录
    - Study
    - Angular
---

# 1. What is Angular
Angular is a framework for people to do the data-binding and changes on website of UI more easily.

AngularJS is the 1st edition of Angular.

#### The difference between AngularJS and Angular is that
1. Angular is based on TypeScript and Angular is based on TypeScript, which is a opensourced language developed by Microsoft.
2. AngularJs uses terms of **Scope** and **Controller** .AngularJS also has a **rootScope** for whole application
-  My own understand of **Scope** is a link between controller and view.When we add a *$scope* in controller, HTML file can get these attributes directlhy and just use it .
- The difference between one-way data binding and two-way databinding is that one-way data binding only can get data from model and post them on the Views, but if we use two-way databinding, if we change data on Views, it can also change data in models. So one is from model to view, one is two-directions view and models.

# 2. Study Angular toturial on its own website
1. Install node.js and npm ,after that we can set a workspace,which is the place for one or more projects. 
2. Use the 
> npm new my-app 
to get a new workspace, an initial skeleton app project, an end-to-end test project and one related configuration files.
3. After new a project, Angular already includes a server, which we can use to build and serve or test the app locally.
- Just use the command 'ng serve --open' and it will open the test website. Default is http://localhost:4200
4. **Components** are fundamental binding blocks of Angular applications.What the "fundemental" means is that it is the basic unit of whole program.Such as 
- display data on the screen
- listen for user input
- take action based on that input
5. so after new a project, CLI already created the first component for us.

# 3. Learn Tours of Heroes toturial
It is said on the website that the toturial can provide functions below:
- Acquiring and displaying a list of items

- Editing a selected item's detail

- Navigating among different views of the data

So I start learning it right now.

The goals in the doc is that:
- Use built-in Angular directives to show and hide elements and display lists of hero data.
- Create Angular components to display hero details and show an array of heroes.
- Use one-way data binding for read-only data.
- Add editable fields to update a model with two-way data binding.
- Bind component methods to user events, like keystrokes and clicks.
- Enable users to select a hero from a master list and edit that hero in the details view.
- Format data with pipes.
- Create a shared service to assemble the heroes.
- Use routing to navigate among different views and their components.
#### 1. Application components
1. app.component.ts contains all the classes used in **TypeScript**
2. app.component.html contains the component template which written in HTML
3. app.component.css contains private CSS styles.
#### 2. Basic knowledge
1. The double curly braces are Angular's binding syntax ,which allows us to insert a variable to the Views
- In Angular, we can write every variable in the AppComponent and contain it in 2 curly brackets ，like {{  }}
2. Things in *component.ts*
- selector: select the place where the CSS file used.And it is used when we need to import data in another file
- templateUrl: The location of the template website file
- styleUrl: Location of component's private CSS styles
- ngOnInit: The part for whole program to initialization
- ##### Always export the Component so we can import it everywhere
3. We could add one component.html in another component.html
4. How to initialise a variable in Angular?
- New a .ts file and write the constructor, then use it in the Component
- ##### One important is that <p> cannot contails tags such as <h1> <div> and the same class
5. Functions that use in frontend can use methods with "|" seprate attributes and methods.The "|" in Angular called *Pipe* 
6. Angular uses a two-way data-binding. That means data flow from the component class out to the screen and from the screen back to the class.
- Use <input> form element to do this
- IF you change something in the imput box, it will change immediately
7. Every component need to be decleared in app.module.ts, and if we new a component in CLI, it is auto-componented.
## 3.1 Specific operations on Angular
1. *ngFor is a repeater directive in Angular,and it can be in host elements, such as <li>
2. Styles and stylesheets identified in @Component metadata are scoped to that specific component, so it will not affect all files in the component
3. Commands start with "ng" are CLI commands
### 3.1.1 EventBinding
```<li *ngFor="let hero of heroes" (click)="onSelect(hero)">```

EventBinding is a tool for people to do some operations on system.Such as click, and specify what method it will trigger,like onSelect()

### 3.1.2 Assign value
Create a variable or assign value is through ":"

### 3.1.3 Master/Detail component
###### It is very hard to maintain if all things in one component, and to avoid this thing, we can split the component into some small components, each one focus on just one small thing.


#### 3.HTML knowledge
1. <input> placeholder is a hint for user if there is nothing in the input box
2. <li> and the tags can have operations inside it ,such as ** *ngFor="let A of B"**
3. <div> can have functions that seprate a part from another part. Each part can have its own independent functions.
4. <span> can used to combine eliments in the specified format.
- Badge in the list is shown like labels,but a little rounded.
5. 