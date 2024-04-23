---
title: "Derived Types"
teaching: 10
exercises: 5
questions:
- "What is a derived type?"
- "How do you use derived types?"
- "Can access to individual components of a derive type be controlled?"
objectives:
- "Create a derived type."
- "Access members of a derived type."
keypoints:
- "A derived type allows you to package together a number of basic types that can then be thought of collectively as one new derived type."
- "Access modifiers can be applied within derived types as well as within modules to restrict access to members of that derived type."
---

While modules allow you to package variables together in such a way that you can directly refer to those variables, derived types allow you to package together variables in such a way as to form a new compound variable. With this new compound variable you can refer to it as a group rather than only by the individual components. This can greatly simplify passing a group of related variables to a procedure as only one variable of a given derived type would need to be passed.

To create a new derived type you use the following format.
~~~
type <type name>
  <member variable declarations>
end type
~~~
{: .fortran}

You can then declare new variables of this derived type as shown.
~~~
type(<type name>):: my_variable
~~~
{: .fortran}
Individual elements or members of a derived type variable, or **object**, can be accessed using the `%` operator.
~~~
my_variable%member1
~~~
{: .fortran}
The member variable, `member1`, would have been declared as part of the derived type.

A full example of creating a new derived type, `t_vector`, which holds an array of `real` values is shown below.

<div class="gitfile" markdown="1">
~~~
module m_vector
  implicit none
  
  type t_vector
    integer:: num_elements
    real,dimension(:),allocatable:: elements
  end type
  
end module

program main
  use m_vector
  implicit none
  type(t_vector) numbers
  
  numbers%num_elements=5
  allocate(numbers%elements(numbers%num_elements))
  numbers%elements(1)=2
  print*, "numbers%num_elements=",numbers%num_elements
  print*, "numbers%elements(1)=",numbers%elements(1)
  
end program
~~~
{: .fortran}
[derived_types.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/derived_types.f90)
</div>

~~~
$ wget https://raw.githubusercontent.com/acenet-arc/fortran_oop_as_a_second_language/gh-pages/code/derived_types.f90
$ gfortran ./derived_types.f90 -o derived_types
$ ./derived_types
~~~
{: .bash}

~~~
 numbers%num_elements=           5
 numbers%elements(1)=   2.00000000
~~~
{: .output}

In the rest of this workshop we will build on this `t_vector` derived type adding functionality as we go. We will create a set of procedures and operators which will allow us to do common operations one might want to perform on a vector abstracting away the details, such as memory management, allowing us to write code at a higher level.

### Creating new objects
Creating new vectors is a pretty common thing that we want to do. Lets add some functions to create vectors to reduce the amount of repeated code. Lets create one to make empty vectors, `create_empty_vector` and one to create a vector of a given size allocating the required memory to hold all the elements of the vector, `create_sized_vector`.

Lets add those functions now.

~~~
$ cp derived_types.f90 derived_types_init.f90
$ nano derived_types_init.f90
~~~
{: .bash}

<div class="gitfile" markdown="1">
<div class="language-plaintext fortran highlighter-rouge">
<div class="highlight">
<pre class="highlight">
module m_vector
  implicit none
  
  type t_vector
    integer:: num_elements
    real,dimension(:),allocatable:: elements
  end type
  
  contains
  
<div class="codehighlight">  type(t_vector) function create_empty_vector()
    implicit none
    create_empty_vector%num_elements=0
  end function</div>
  
<div class="codehighlight">  type(t_vector) function create_sized_vector(vec_size)
    implicit none
    integer,intent(in):: vec_size
    create_sized_vector%num_elements=vec_size
    allocate(create_sized_vector%elements(vec_size))
  end function</div>
  
end module

program main
  use m_vector
  implicit none
  type(t_vector) <div class="codehighlight">numbers_none,numbers_some</div>
  
<div class="codehighlight">  numbers_none=create_empty_vector()
  print*, "numbers_none%num_elements=",numbers_none%num_elements</div>
  
<div class="codehighlight">  numbers_some=create_sized_vector(4)
  numbers_some%elements(1)=2
  print*, "numbers_some%num_elements=",numbers_some%num_elements
  print*, "numbers_some%elements(1)=",numbers_some%elements(1)</div>
  
end program
</pre></div></div>
[derived_types_init.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/derived_types_init.f90)
</div>

Since the function is declared as a `t_vector` type, members of the returned `t_vector` object can be accessed using the `%` operator from an object with the same name as the function from inside the function. This is similar to how functions normally work, however in this case the function return type is a derived type.

Lets compile and run.
~~~
$ gfortran ./derived_types_init.f90 -o derived_types_init
$ ./derived_types_init
~~~
{: .bash}

~~~
 numbers_none%num_elements=           0
 numbers_some%num_elements=           4
 numbers_some%elements(1)=   2.00000000
~~~
{: .output}

Now we can use these functions to initialize and allocate memory for our vectors.

> ## Deallocating
> It is a good idea to match allocations to deallocations. We will add this functionality later in the [Destructors episode](../destructors) once we learn a bit more about derived types.
{: .callout}

> ## Access modifiers and derived types
> Access modifiers can be applied to derived types in a similar way to modules. Here is an example.
> 
> ~~~
> module m_vector
>   implicit none
>   
>   type t_vector
>     integer,private:: num_elements
>     real,dimension(:),allocatable:: elements
>   end type
>   ...
> end module
> ~~~
> {: .fortran}
> In this case the member variable `num_elements` could no longer be accessed from outside the module, while the `elements` member variable can be.
{: .callout}

> ## What is a derived type?
> Is a derived type:
> <ol type="a">
> <li markdown="1">a variable which can have multiple variable members
> </li>
> <li markdown="1">an object which can have multiple member variables
> </li>
> <li markdown="1">a datatype which can have multiple member variables
> </li>
> <li markdown="1">a datatype which can contain only a single value like `integer`,`real`,etc.
> </li>
> </ol>
> > ## Solution
> > <ol type="a">
> > <li markdown="1">**NO**: while a derived type can have multiple members, a derived type defines a new datatype where as a variable or object are the instantiation of that derived type or datatype.
> > </li>
> > <li markdown="1">**NO**: while an object has a derived type, the object is not the derived type its self.
> > </li>
> > <li markdown="1">**Yes**: a derived type is a kind of datatype that can have multiple members.
> > </li>
> > <li markdown="1">**No**: derived types can have multiple members, it is possible that they only have one member but they are not restricted to holding a single value.
> > </li>
> > </ol>
> {: .solution}
{: .challenge}

{% include links.md %}

