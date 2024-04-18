---
title: "Interface Blocks"
teaching: 10
exercises: 0
questions:
- "What is an interface block?"
- "How can one be used to create a constructor for a derived type?"
objectives:
- "How do you create an interface block."
keypoints:
- "An interface block can act as either a block of definitions of your procedures (explicit interface) or as a means of associating different procedures with one common name (generic interface)."
- "Procedures that are part of the same generic interface block must be distinguishable from each other based on the number, order, and type of arguments passed."
---

As mentioned previously it is a very common task to create new objects of a derived type and perform some initialization of the members. We have already created some functions to do this. One of the functions, `create_empty_vector` takes no arguments and creates a new empty vector, while `create_sized_vector` creates a new vector of a specific size passed to the function. Both of these functions do the same thing, create a new `t_vector` object and initialize it. One might imagine many different such initialization routines, perhaps ones that take another `t_vectors` or `t_vector_3` objects to use to initialize a new `t_vector` object as a copy of the passed vector. All of these creation, or initialization, functions do basically the same thing but in a slightly different way depending on the arguments passed to them. It starts to get a bit tedious to have to remember all the names of these different initialization functions. If the compiler could somehow distinguish these functions automatically based on the number and type of arguments rather than the procedure name so that we could call the same generic procedure name and it would pick the correct procedure implementation based on the arguments we passed it.

It turns out there was a feature added to Fortran 2003, called **interface blocks** which allow multiple procedures to be mapped to one name. The basic syntax of an interface block is as follows.
~~~
interface <new-procedure-name>
  procedure:: <existing-procedure-name-1>
  procedure:: <existing-procedure-name-2>
  ...
end interface
~~~
{: .fortran}

This allows one to call the procedure `<new-procedure-name>` and will be mapped onto different procedure implementations `<existing-procedure-name1>`, `<existing-procedure-name-2>`, etc. based on the type, number, and order of arguments passed to the procedure when calling it. Since the number, type, and order of arguments is the only way for the compiler to know which procedure to call, all procedures listed in the interface block must have different types and or number of arguments.

Lets use interface blocks to group our creation functions for `t_vector` and `t_vector_3` into one procedure name to initialize each of the derived types. It is common to use the name of the derived type as the name of creation function which returns a new object of that type. Functions defined in this way are referred to as **constructors** as they *construct* new objects of the derived type.

~~~
$ cp type_extension.f90 interface_blocks.f90
$ nano interface_blocks.f90
~~~
{: .bash}

<div class="gitfile" markdown="1">
<div class="language-plaintext fortran highlighter-rouge">
<div class="highlight">
<pre class="highlight">
module m_vector
  implicit none
  
  type t_vector
    ...
  end type
  
<span class="codehighlight">  interface t_vector
    procedure:: create_empty_vector
    procedure:: create_sized_vector
  end interface</span>
  
  type,extends(t_vector):: t_vector_3
  end type
  
<span class="codehighlight">  interface t_vector_3
    procedure:: create_size_3_vector
  end interface</span>
  
  contains
  
  type(t_vector) function create_empty_vector()
    ...
  end function
  
  type(t_vector) function create_sized_vector(vec_size)
    ...
  end function
  
  type(t_vector_3) function create_size_3_vector()
    ...
  end function
  
end module

program main
  use m_vector
  implicit none
  type(t_vector) numbers_none,numbers_some
  type(t_vector_3) location
  
  numbers_none=<span class="codehighlight">t_vector()</span>
  print*, "numbers_none%num_elements=",numbers_none%num_elements
  
  numbers_some=<span class="codehighlight">t_vector(4)</span>
  numbers_some%elements(1)=2
  print*, "numbers_some%num_elements=",numbers_some%num_elements
  print*, "numbers_some%elements(1)=",numbers_some%elements(1)
  
  location=<span class="codehighlight">t_vector_3()</span>
  location%elements(1)=1.0
  print*, "location%elements(1)=",location%elements(1)
  
end program
</pre></div></div>
{: .fortran}
[interface_blocks.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/interface_blocks.f90)
</div>

~~~
$ gfortran interface_blocks.f90 interface_blocks
$ ./interface_blocks
~~~
{: .bash}
~~~
 numbers_none%num_elements=           0
 numbers_some%num_elements=           4
 numbers_some%elements(1)=   2.00000000    
 location%elements(1)=   1.00000000    
~~~
{: .output}

The way we have used interface blocks above is what is called a **generic interface** as it maps one generic procedure name we specified to multiple specific procedures. This is very similar to what other object oriented languages call **overloading**.

There is another way to use interface blocks without specifying a generic procedure name to map the listed procedures to, referred to as **explicit interfaces**. Explicit interface blocks can be used to define a procedure without actually listing the implementation of it. These are useful when using procedures declared in different compilation units which will be linked into the final program later. This is a bit like a forward declaration or a function prototype in C/C++. If your procedures are declared inside a module, as we have been doing, these explicit interfaces are created for you.

{% include links.md %}

