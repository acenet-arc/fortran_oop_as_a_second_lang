module m_vector
  implicit none

  type t_vector
    integer:: num_elements
    real,dimension(:),allocatable:: elements

    contains

    procedure:: display
    final:: destructor_vector

  end type

  interface t_vector
    procedure:: create_empty_vector
    procedure:: create_sized_vector
  end interface

  interface operator(+)
    procedure:: add_vectors
  end interface

  type,extends(t_vector):: t_vector_3

    contains

    final:: destructor_vector_3

  end type

  interface t_vector_3
    procedure:: create_size_3_vector
  end interface

  contains

  type(t_vector) function add_vectors(left,right)
    implicit none
    type(t_vector),intent(in):: left, right
    integer:: i,total_size,result_i

    total_size=left%num_elements+right%num_elements
    add_vectors=create_sized_vector(total_size)

    !copy over left vector elements
    do i=1, left%num_elements
      add_vectors%elements(i)=left%elements(i)
    end do

    !copy over right vector elements
    result_i=left%num_elements+1
    do i=1,right%num_elements
      add_vectors%elements(result_i)=right%elements(i)
      result_i=result_i+1
    enddo

  end function

  subroutine destructor_vector(self)
    implicit none
    type(t_vector):: self

    if (allocated(self%elements)) then
      deallocate(self%elements)
    endif
  end subroutine

  subroutine destructor_vector_3(self)
    implicit none
    type(t_vector_3):: self

    if (allocated(self%elements)) then
      deallocate(self%elements)
    endif
  end subroutine

  subroutine display(vec)
    implicit none
    class(t_vector),intent(in):: vec
    integer:: i

    select type (vec)
      class is (t_vector)
        print*, "t_vector:"
        print*, " num_elements=",vec%num_elements
      class is (t_vector_3)
        print*, "t_vector_3:"
    end select
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
  type(t_vector) numbers_some,numbers_less,numbers_all

  numbers_some=t_vector(4)
  numbers_some%elements(1)=1
  numbers_some%elements(2)=2
  numbers_some%elements(3)=3
  numbers_some%elements(4)=4
  print*, ""
  print*, "numbers_some"
  call numbers_some%display()

  numbers_less=t_vector(2)
  numbers_less%elements(1)=5
  numbers_less%elements(2)=6
  print*, ""
  print*, "numbers_less"
  call numbers_less%display()

  numbers_all=numbers_some+numbers_less
  print*, ""
  print*, "numbers_all"
  call numbers_all%display()

end program
