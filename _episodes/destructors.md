---
title: "Destructors"
teaching: 10
exercises: 0
questions:
- "What is a destructor?"
objectives:
- "Create a destructor for our two derived types to deallocate memory."
keypoints:
- "A destructor is used to perform clean up when an object goes out of scope."
- "To create a destructor use the **final** keyword when declaring at type bound procedure instead of the procedure keyword."
---
One aspect I have been ignoring until now is that the memory we allocate for our vectors is never explicitly freed by our program. So far our program has been simple enough that this is not a serious issue. We have only created a few objects that allocate memory within our main program. When the program execution has completed, that memory is returned to the operating system. However, if we had a long running loop inside our program that created new objects with allocated memory and we never deallocated that memory we would have a problem as our program would steadily increase its memory usage. This is referred to as a memory leak as was mentioned in the first half of this workshop. We can manually deallocate memory as we did with allocating memory before we created a function to create new `t_vector` and `t_vector_3` objects, however there is a way to create a new special type bound procedure that is automatically called when the object goes out of scope to deallocate this memory for us. To do this we use the **final** keyword within the type definition.

~~~
type <type-name>
  ...
  contains
  final:: <type-finalization-subroutine>
end type
~~~
{: .fortran}

Then as we did for the `display` subroutine, we can create a `<type-finalization-subroutine>` to do anything that needs to be done when an object of this type goes out of scope, including deallocating memory.

Lets add destructors to deallocate our memory for our two derived types.

~~~
$ cp type_bound_procedures_select_type.f90 destructor.f90
$ nano destructor.f90
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
    
    contains
    
    procedure:: display
    <div class="codehighlight">final:: destructor_vector</div>
    
  end type
  
  interface t_vector
    ...
  end interface
  
  type,extends(t_vector):: t_vector_3
    
    <div class="codehighlight">contains</div>
    
    <div class="codehighlight">final:: destructor_vector_3</div>
    
  end type
  
  interface t_vector_3
    procedure:: create_size_3_vector
  end interface
  
  contains
  
<div class="codehighlight">  subroutine destructor_vector(self)
    implicit none
    type(t_vector):: self
    
    if (allocated(self%elements)) then
      deallocate(self%elements)
    endif
  end subroutine</div>
  
<div class="codehighlight">  subroutine destructor_vector_3(self)
    implicit none
    type(t_vector_3):: self
    
    if (allocated(self%elements)) then
      deallocate(self%elements)
    endif
  end subroutine</div>
  
  subroutine display(vec)
    ...
  end subroutine
  
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
[destructor.f90](https://github.com/acenet-arc/fortran_oop_as_a_second_language/blob/gh-pages/code/destructor.f90)
</div>

~~~
$ gfortran destructor.f90 -o destructor
$ ./destructor
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
{% include links.md %}

