---
title: "Modules"
teaching: 10
exercises: 10
questions:
- "What are modules?"
- "Can I control what can be accessed from outside a module?"
objectives:
- "Create a module."
keypoints:
- "Modules are used to package variables, types, and procedures together."
- "Access to variables and procedures within the module can be controlled with the private and public access modifiers."
---

Modules allow procedures (functions and subroutines) and variables to be grouped together as well as some other constructs we will talk about later.

A module is declared as shown below.

~~~
modules <module name>
  
  <variable declarations go here>
  
  contains
  
  <procedures go here>
  
end module
~~~
{: .fortran}

The `contains` keyword separates the variable declarations and the procedure implementations.

Modules are not strictly an object oriented only Fortran feature but are very handy to group together related object oriented constructs as we shall see.

Here is an example of a Fortran module.

<div class="gitfile" markdown="1">
<div class="language-plaintext fortran highlighter-rouge">
<div class="highlight">
<pre class="highlight">
module m_common
  implicit none
  
  integer:: value_one
  real:: value_two
  
  contains
  
  subroutine print_values()
    implicit none
    print *, "value_one=",value_one
    print *, "value_two=",value_two
  end subroutine
  
end module

program main
  use m_common
  implicit none
  
  value_one=1
  value_two=2
  call print_values()
end program
</pre></div></div>
[modules.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/modules.f90)
</div>
In the program `main`, to be able to accesses the variables and procedures defined in the module you must indicate you wish to be able to access them with the `use` keyword followed by the module name you would like your program or procedure to have access to.

Lets download, compile and run the above `modules.f90` program.
~~~
$ wget https://raw.githubusercontent.com/acenet-arc/fortran_oop_as_a_second_language/gh-pages/code/modules.f90
$ gfortran modules.f90 -o modules
$ ./modules
~~~
{: .bash}

~~~
 value_one=           1
 value_two=   2.00000000
~~~
{: .output}

### Access Modifiers
It is possible to control how variables and procedures declared in a module are accessed from outside the module. This can be done either on module wide basis or for specific procedures and variables. If you specify no access modifiers everything will be accessible from outside the module.

There are two access modifiers:
* `private` indicates that the procedure or variable can only be accessed within the module
* `public` indicates it can be accessed from outside the module.

Below is an example of using the `private` access modifier module wide.

<div class="gitfile" markdown="1">
<div class="language-plaintext fortran highlighter-rouge">
<div class="highlight">
<pre class="highlight">
module m_common
  implicit none
  <div class="codehighlight">private</div>
  
  integer:: value_one
  real:: value_two
  
  contains
  
  subroutine print_values()
    ...
  end subroutine
  
end module

program main
  use m_common
  implicit none
  
  value_one=1
  value_two=2
  call print_values()
end program
</pre></div></div>
[modules_access_none.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/modules_access_none.f90)
</div>

> ## Add the `private` access modifier
> Copy the `modules.f90` file to `modules_access_none.f90` and add the `private` access modifier to the `m_common` module, at the module wide level as shown above. Compile and run if you can. What is the result?
> > ## Solution
> > ~~~
> > $ cp modules.f90 modules_access_none.f90
> > $ nano modules_access_none.f90
> > ~~~
> > {: .bash}
> > Then add the `private` access modifier, as shown above, and try to compile with the below command.
> > ~~~
> > $ gfortran modules_access_none.f90 -o modules_access_none
> > ~~~
> > {: .bash}
> > You will get the following errors:
> > ~~~
> > modules_access_none.f90:22:11:
> > 
> >    22 |   value_one=1
> >       |           1
> > Error: Symbol ‘value_one’ at (1) has no IMPLICIT type
> > modules_access_none.f90:23:11:
> > 
> >    23 |   value_two=2
> >       |           1
> > Error: Symbol ‘value_two’ at (1) has no IMPLICIT type
> > ~~~
> > {: .output}
> > 
> > Indicating that the variables `value_one` and `value_two` can not be accessed from outside the module.
> {: .solution}
> 
{: .challenge}

With the `private` access modifier variables declared in the module can't be accessed from outside the module.

> ## Stop using module variables outside the module
> If the lines which reference to `value_one` and `value_two` are commented out and we try to compile again what happens?
> > ## Solution
> > ~~~
> > $ nano modules_access_none.f90
> > ~~~
> > {: .bash}
> > ~~~
> > ...
> > 
> > program main
> >   use m_common
> >   implicit none
> >   
> >   !value_one=1
> >   !value_two=2
> >   call print_values()
> > end program
> > ~~~
> > {: .fortran}
> > ~~~
> > $ gfortran modules_access_none.f90 -o modules_access_none
> > ~~~
> > {: .bash}
> > then I get an error during the linking process like so:
> > ~~~
> > /usr/bin/ld: /tmp/cc5TwvXi.o: in function `MAIN__':
> > modules_access_none.f90:(.text+0x118): undefined reference to `print_values_'
> > collect2: error: ld returned 1 exit status
> > ~~~
> > {: .output}
> > Indicating that the subroutine `print_values` can not be accessed either.
> {: .solution}
{: .challenge}

As mentioned, individual variables and procedures can be selectively made either `private` or `public`.

<div class="gitfile" markdown="1">
<div class="language-plaintext fortran highlighter-rouge">
<div class="highlight">
<pre class="highlight">
module m_common
  implicit none
  private
  
  integer:: value_one
  real:: value_two
  
  <div class="codehighlight">public:: print_values</div>
  contains
  
  subroutine print_values()
    ...
  end subroutine
  
end module

program main
  use m_common
  implicit none
  
  !value_one=1
  !value_two=2
  call print_values()
end program
</pre></div></div>
[modules_access_some.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/modules_access_some.f90)
</div>
This version will compile and run and will print out the values of the two private variables of the module, however they won't have been initialized to anything.

Using access modifiers allows certain data and procedures to be inaccessible from the user of these modules. Restricting access to data and procedures is a common practise in object oriented design.

{% include links.md %}

