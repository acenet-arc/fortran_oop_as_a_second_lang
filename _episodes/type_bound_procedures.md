---
title: "Type Bound Procedures"
teaching: 10
exercises: 5
questions:
- "What is a type bound procedure?"
- "Can an extended type be passed to a type bound procedure?"
objectives:
- "How do you create a type bound procedure."
keypoints:
- "A type bound procedure allows you to associate a procedure with a type."
- "Extended types can use these type bound procedures by using the **class** keyword rather than the type keyword."
- "**select type** allows different code paths to execute based on the object's type similar to select case."
---
We have been printing out parts of our vectors to see how the changes have been making affect them. It would be really nice to have an easy way to see a vector without having to explicitly print out the components of that vector we wish to seen every time.

We can do this by creating a new subroutine `display`. We could do this in the usual way shown below.

~~~
subroutine display(vec)
  ...
end subroutine

program main
  ...
  type(t_vector):: vec
  ...
  call display(vec)
  
  ...
end program
~~~
{: .fortran}
However, in object oriented languages it is common to think of procedures as part of the object or type and have the procedure be called from the object. So instead of calling a procedure and explicitly passing in the object like `call display(vec)` as above the different syntax using the `%` operator `call vec%display()` is more in line with the object oriented way of thinking.

The `%` style of calling a subroutine works exactly the same as the usual way, except that the first argument in the subroutine is automatically replaced by the object to the left of the `%` operator. This type of procedure is called a **type bound procedure**. In other languages this might be called a **member function** as it is a member of the type, like the component variables are members.

To create a type bound procedure you must specify that the type *contains* that procedure. Lets add the `display` type bound procedure now.

~~~
$ cp interface_blocks.f90 type_bound_procedures.f90
$ nano type_bound_procedures.f90
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
    
    <span class="codehighlight">contains</span>
    
    <span class="codehighlight">procedure:: display</span>
    
  end type
  
  interface t_vector
    ...
  end interface
  
  type,extends(t_vector):: t_vector_3
  end type
  
  interface t_vector_3
    procedure:: create_size_3_vector
  end interface
  
  contains
  
<span class="codehighlight">  subroutine display(vec)
    implicit none
    class(t_vector),intent(in):: vec
    integer:: i
    
    print*, "t_vector:"
    print*, " num_elements=",vec%num_elements
    print*, " elements="
    do i=1,vec%num_elements
      print*, "  ",vec%elements(i)
    end do
  end subroutine</span>
  
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
  
  numbers_none=t_vector()
  <span class="codehighlight">call numbers_none%display()</span>
  
  numbers_some=t_vector(4)
  numbers_some%elements(1)=2
  <span class="codehighlight">call numbers_some%display()</span>
  
  location=t_vector_3()
  location%elements(1)=1.0
  <span class="codehighlight">call location%display()</span>
  
end program
</pre></div></div>
{: .fortran}
[type_bound_procedures.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/type_bound_procedures.f90)
</div>

Notice that in the `display` subroutine we declare the `vec` object as `class(t_vector):: vec`, rather than the usual `type(t_vector):: vec`. This is to indicate that `vec` could be either a `t_vector` or any derived type which extends this derived type, this would include our `t_vector_3` derived type. Allowing any derived types which extended the original **base** type to be passed into the subroutine using the same argument. This argument can then be treated the same regardless of what type it is since it was derived from a common base type.

This is a pretty neat trick for a statically typed language like Fortran. We can pass in different derived types to the procedure in the same argument. This means that the `display` subroutine will actually work for both our `t_vector` and our `t_vector_3` derived types as `t_vector_3` must contain all the same member variables as `t_vector` and possibly more. The ability to operate on different types in a similar way is often referred to as **polymorphism** in object oriented programming languages.

Lets see how this new `display` subroutine works.
~~~
$ gfortran type_bound_procedures.f90 -o type_bound_procedures
$ ./type_bound_procedures
~~~
{: .bash}
~~~
 t_vector:
  num_elements=           0
  elements=
 t_vector:
  num_elements=           4
  elements=
      2.00000000
      0.00000000
      0.00000000
      0.00000000
 t_vector:
  num_elements=           3
  elements=
      1.00000000
      0.00000000
      0.00000000
~~~
{: .output}
As you can see, it worked just fine on both our `t_vector` objects `numbers_none` and `numbers_some` and our `t_vector_3` object `location`.

However, it is still printing out that the object is a `t_vector` even when it is a `t_vector_3`. It would be nice if we could have it print out `t_vector_3` when it is a `t_vector_3` object and print out `t_vector` when it is a `t_vector` object. It turns out there is a way to do this using the **`select type`** construct. It works very much like the `select case` construct except that it works with object types instead of values of a variable.

~~~
$ cp type_bound_procedures.f90 type_bound_procedures_select_type.f90
$ nano type_bound_procedures_select_type.f90
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
  
  interface t_vector
    ...
  end interface
  
  type,extends(t_vector):: t_vector_3
  end type
  
  interface t_vector_3
    procedure:: create_size_3_vector
  end interface
  
  contains
  
  subroutine display(vec)
    implicit none
    class(t_vector),intent(in):: vec
    integer:: i
    
<div class="codehighlight">    select type (vec)
      class is (t_vector)
        print*, "t_vector:"
        print*, " num_elements=",vec%num_elements
      class is (t_vector_3)
        print*, "t_vector_3:"
    end select</div>
    print*, " elements="
    do i=1,vec%num_elements
      print*, "  ",vec%elements(i)
    end do
  end subroutine
  
  type(t_vector) function create_empty_vector()
    implicit none
    create_empty_vector%num_elements=0
  end function
  
  type(t_vector) function create_sized_vector(vec_size)
    implicit none
    integer,intent(in):: vec_size
    create_sized_vector%num_elements=vec_size
    allocate(create_sized_vector%elements(vec_size))
  end function
  
  type(t_vector_3) function create_size_3_vector()
    implicit none
    create_size_3_vector%num_elements=3
    allocate(create_size_3_vector%elements(3))
  end function
  
end module

program main
  use m_vector
  implicit none
  type(t_vector) numbers_none,numbers_some
  type(t_vector_3) location
  
  numbers_none=t_vector()
  call numbers_none%display()
  
  numbers_some=t_vector(4)
  numbers_some%elements(1)=2
  call numbers_some%display()
  
  location=t_vector_3()
  location%elements(1)=1.0
  call location%display()
  
end program
</pre></div></div>
{: .fortran}
[type_bound_procedures_select_type.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/type_bound_procedures_select_type.f90)
</div>

~~~
$ gfortran type_bound_procedures_select_type.f90 -o type_bound_procedures_select_type
$ ./type_bound_procedures_select_type
~~~
{: .bash}
~~~
 t_vector:
   num_elements=           0
   elements=
 t_vector:
   num_elements=           4
   elements=
     2.00000000    
     0.00000000    
     0.00000000    
     0.00000000    
 t_vector_3:
   elements=
     1.00000000    
     0.00000000    
     0.00000000    
~~~
{: .output}

As you can see, it is now correctly outputting `t_vector_3` when the object is of that type.

> ## What is passed to a type bound procedure?
> Given the following program
> ~~~
> module m_A
>   implicit none
> 
>   type t_B
>     integer:: foo
>     contains
>     procedure:: display
>   end type
> 
>   contains
> 
>   subroutine display(b)
>     implicit none
>     class(t_B),intent(in):: b
>     print*, b%foo
>   end subroutine
> 
> end module
> 
> program main
>   use m_A
>   implicit none
>   type(t_B) a
>   type(t_B) b
> 
>   a%foo=1
>   b%foo=2
>   call b%display()
>   call a%display()
> 
> end program
> ~~~
> {: .fortran}
> What is the output when compiled and run?
> <ol type="a">
> <li markdown="1">
> ~~~
> 1
> 1
> ~~~
> {: .output}
> </li>
> <li markdown="1">
> ~~~
> 2
> 2
> ~~~
> {: .output}
> </li>
> <li markdown="1">
> ~~~
> 1
> 2
> ~~~
> {: .output}
> </li>
> <li markdown="1">
> ~~~
> 2
> 1
> ~~~
> {: .output}
> </li>
> </ol>
> > ## Solution
> > <ol type="a">
> > <li markdown="1">**NO**: the objects `a` and `b` each have separate storage for their own values of `foo`
> > </li>
> > <li markdown="1">**NO**: same reason as a.
> > </li>
> > <li markdown="1">**NO**: not quite, note the order the functions are called.
> > </li>
> > <li markdown="1">**YES**: when `call b%display()` is executed `b%foo` in the `display` subroutine takes on the value of 2 and is printed out. When `call a%display` is executed `b%foo` in the `display` subroutine takes on the value of ` and is printed out.
> > </li>
> > </ol>
> {: .solution}
{: .challenge}

{% include links.md %}

