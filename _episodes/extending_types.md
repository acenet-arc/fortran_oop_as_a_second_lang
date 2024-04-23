---
title: "Extended Types"
teaching: 10
exercises: 5
questions:
- "How do you extend a type?"
- "Why can it be useful to extend a type?"
objectives:
- "Create an extended a type."
keypoints:
- "Type extension allows you to build upon an existing derived type to create a new derived type while adding new functionality or modifying existing functionality."
- "Allows reuse of common code between derived types."
---

It is pretty common to use vectors to represent positions in 3D space. Lets create a new derived type which always has only three components. However, it would be really nice if we could reuse our more general vector type to represent one of these specific 3 component vectors. You can do this by using type extension. Type extension allows you to add new members (or not) to an existing type to create a new derived type.

To create a new extended derived type use the following format.
~~~
type,extends(<parent type name>):: <child type name>
  <member variable declarations>
end type
~~~
{: .fortran}
Here `<parent type name>` is the name of a derived type to be extended, and `<child type name>` is the name of the new derived type created by extending the parent derived type.

Our new 3 component vector however, doesn't need any new member variables. However, by having a distinct derived data type for our 3 component vector it will allow us to use specific procedures that work with it as apposed to the those for the more general vector and at the same time reuse common functionality between the two vector types.

Lets create a new `t_vector_3` derived type and a `create_size_3_vector` function to create new objects.

~~~
$ cp derived_types_init.f90 type_extension.f90
$ nano type_extension.f90
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
  
<div class="codehighlight">  type,extends(t_vector):: t_vector_3
  end type</div>
  
  contains
  
  type(t_vector) function create_empty_vector()
    ...
  end function
  
  type(t_vector) function create_sized_vector(vec_size)
    ...
  end function
  
<div class="codehighlight">  type(t_vector_3) function create_size_3_vector()
    implicit none
    create_size_3_vector%num_elements=3
    allocate(create_size_3_vector%elements(3))
  end function</div>
  
end module

program main
  use m_vector
  implicit none
  type(t_vector) numbers_none,numbers_some
<div class="codehighlight">  type(t_vector_3) location</div>
  
  numbers_none=create_empty_vector()
  print*, "numbers_none%num_elements=",numbers_none%num_elements
  
  numbers_some=create_sized_vector(4)
  numbers_some%elements(1)=2
  print*, "numbers_some%num_elements=",numbers_some%num_elements
  print*, "numbers_some%elements(1)=",numbers_some%elements(1)
  
<div class="codehighlight">  location=create_size_3_vector()
  location%elements(1)=1.0
  print*, "location%elements(1)=",location%elements(1)</div>
  
end program
</pre>
</div>
</div>

{: .fortran}
[type_extension.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/type_extension.f90)
</div>

~~~
$ gfortran type_extension.f90 -o type_extension
$ ./type_extension
~~~
{: .bash}

~~~
 numbers_none%num_elements=           0
 numbers_some%num_elements=           4
 numbers_some%elements(1)=   2.00000000    
 location%elements(1)=   1.00000000    
~~~
{: .output}

> ## Which type is being extended?
> In the following code snippet which type is being extended?
> ~~~
> ...
> type, extends(B):: A
> end type
> ...
> type(C) function D()
>   implicit none
>   D%thing=1.0
>  end function
> ...
> ~~~
> {: .fortran}
> <ol type="a">
> <li markdown="1">`A`
> </li>
> <li markdown="1">`B`
> </li>
> <li markdown="1">`C`
> </li>
> <li markdown="1">`D`
> </li>
> </ol>
> > ## Solution
> > <ol type="a">
> > <li markdown="1">**No**: close, but `A` is the new derived type which extends the existing `B` derived type.
> > </li>
> > <li markdown="1">**Yes**: the existing derived type `B` is being extended to create a new derived type `A`.
> > </li>
> > <li markdown="1">**No**: `C` is a derived type, but from this code snippet it is impossible to tell if it has been extended to a new derived type somewhere else in the code.
> > </li>
> > <li markdown="1">**No**: `D` is actually a function name, not a derived type at all.
> > </li>
> > </ol>
> {: .solution}
{: .challenge}

{% include links.md %}
