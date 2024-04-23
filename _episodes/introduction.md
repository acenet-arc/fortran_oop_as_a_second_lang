---
title: "Introduction"
teaching: 5
exercises: 0
questions:
- "What is object oriented design?"
- "What features does Fortran include to support object oriented design?"
objectives:
- "Gain a high level understanding of object oriented design (OOP)."
- "Know some of the features that have been introduced to Fortran to support OOP."
keypoints:
- "Fortran supports object oriented design."
- "Some consideration for performance should be taken with object oriented design early on, e.g. create objects containing arrays rather than arrays of objects."
---

Many modern languages support the practice of Object Oriented Programming (OOP). The basic idea here is that data and functionality can be grouped together into a single unit.

There are some basic principles of OOP:
* **Abstraction**: wrap up complex actions into simple verbs.
* **Encapsulation**: keep state and logic internal.
* **Inheritance**: new types can inherit properties and function from existing types and modify and extend those.
* **Polymorphism**: different types of objects can have the same methods that are internally handled differently depending on the type.

Many features have been added to Fortran over the years which has allowed Fortran programs to be written with increasingly object-oriented designs if desired.

However, I should note that care should be taken while designing programs to make use of OOP practices. If not carefully designed OOP can result in very bad outcomes for performance. It has been stated that premature optimization is the root of all evil, and to some degree that is true. In that you shouldn't worry too much about optimizing code until you know what is important to optimize, e.g. what takes most of the time. However, when using OOP designs some consideration needs to be given up front to performance otherwise significant re-writing will have to happen to allow for later optimizations. For example, it is often a bad idea to have an array of objects and one should instead favor an object containing arrays.

Here is an example, as a grad student I was writing a hydrodynamics code for a course. I made every cell in my grid an object with members like, density, pressure and velocities. To create my grid I made an array of cell objects and for every cell I called a constructor to initialize it. More over, when updating a property such as density over the whole grid, all the other cell properties had to be loaded into the smaller and faster caches along with it. This would increase the likely hood of cache misses and cause data to be loaded/unloaded into the caches more than otherwise needed. I got very poor performance as compared to other students who didn't use an OOP style. That isn't to say I couldn't have used an OOP style and gotten comparable performance, if I for example made the grid an object which contained arrays of the basic properties of the fluid. So blindly applying the ideas of OOP can have some serious performance implications and require some major structural changes to code if left to later optimization stages. Some up front thought about performance isn't always a bad thing. The trick is not to worry about details too early, but rather try to limit it to larger code design decisions.

There are of course benefits to the basic OOP principles, in particular they help to reduce the mental load when dealing with large complex code bases by allowing the person reading the code to get a high level understanding of what is going on by abstracting away details. It also helps by reducing the need for duplicating code by using inheritance and polymorphism to allow the same code to operate on different data types. This reduces the amount of code that needs to be debugged and maintained.

The above principles of OOP should be considered as general guidelines rather than perfect rules to always follow.

* Fortran 90 introduced:
  * modules
  * derived data types
  * interface blocks
  * operator overloading
* Fortran 2003 introduced:
  * type extension
  * type-bound procedures

In this part of the workshop we will briefly introduce these features and their role in object oriented programming in Fortran.

{% include links.md %}

