module mod_other_quantities
  use input_parameter
  use calc_parameter, only: data_beads, data_step
  use calc_histogram1D
  use utility, only: reblock_step
  implicit none
  real(8), allocatable :: charge(:,:,:), dipole(:,:,:), hfcc(:,:,:)
  integer, private :: Uinp, ierr
  integer :: atom1, atom2

contains

  subroutine  other_quantities
    atom1 = atom_num(1,1)
    atom2 = atom_num(2,1)

    select case(jobtype)
      case(61:62)
        call charge_analysis
      case(63)
        call dipole_analysis
      case(64)
        call hfcc_analysis
    end select
  end subroutine other_quantities


! +++++++++++++++++++++++
! +++ charge_analysis +++
! +++++++++++++++++++++++
  subroutine charge_analysis
    integer :: Istep, i, j, k
!    real(8) :: average(Natom)
    print *, other_path
    allocate(charge(Natom,Nbeads,TNstep))

    open(newunit=Uinp, file=other_path, status='old', iostat=ierr)
      if ( ierr > 0 ) then
        print *, 'Check the path : ', other_path
        stop 'ERROR!!: There is no "charge.dat"'
      end if

      read(Uinp,'()')
      do i = 1, Nstart(1)-1
        read(Uinp,'()')
        do j = 1, Nbeads
          read(Uinp,'()')
        end do
      end do

      Istep = 0
      do k = Nstart(1), Nstep(1)
        Istep = Istep + 1
        read(Uinp,'()')
        do j = 1, Nbeads
          read(Uinp,*) charge(:,j,Istep)
        end do
      end do
    close(Uinp)

    if ( jobtype == 62 ) then
    block
      integer :: Ounit
      character(len=128) :: name_out
      if ( save_beads .eqv. .True. ) then
        open(newunit=Ounit, file=FNameBinary1, form='unformatted', access='stream', status='replace')
          do Istep = 1, TNstep
            do j = 1, Nbeads
              write(Ounit) charge(atom1,j,Istep)
            end do
          end do
        close(Ounit)
      end if
      write(*,*) "***** atomic charge of ", atom1, "is saved *****"
      write(*,*) "***** in ", FNameBinary1, " *****"
      data_beads = charge(atom1,:,:)
      name_out = "hist_charge.out"
      call calc_1Dhist(out_hist_ex=name_out)


      open(newunit=Ounit,file="step_charge.out",status='replace')
        do k = 1, TNstep
          if (mod(k,graph_step) == 0 ) write(Ounit,'(I7,F10.5)') k, sum(charge(atom1,:,k))/dble(Nbeads)
        end do
      close(Ounit)
    end block
    end if

    do i = 1, Natom
      print '(I3,F12.7)', i, sum(charge(i,:,:)) / dble(TNstep*Nbeads)
    end do
  end subroutine charge_analysis
! +++++++++++++++++++++++++++
! +++ end charge_analysis +++
! +++++++++++++++++++++++++++

! +++++++++++++++++++++++
! +++ dipole_analysis +++
! +++++++++++++++++++++++
  subroutine dipole_analysis
    integer :: i,j,k,Istep
    real(8) :: abs_dipole
    allocate(dipole(3,Nbeads,TNstep))

    open(newunit=Uinp, file=other_path,status='old',iostat=ierr)
      if ( ierr > 0 ) then
        print *, 'Check the path : ', other_path
        stop 'ERROR!!: There is no "dipole.dat"'
      end if

      do k = 1, Nstart(1)-1
        read(Uinp, '()')
        do j = 1, Nbeads
          read(Uinp,*) dipole(:,j,k)
        end do
      end do

      Istep = 0
      do k = Nstart(1), Nstep(1)
        Istep = Istep + 1
        read(Uinp, '()')
        do j = 1, Nbeads
          read(Uinp,*) dipole(:,j,Istep)
        end do
      end do
    close(Uinp)

    abs_dipole = 0.0d0
    do Istep = 1, TNstep
      do j = 1, Nbeads
        ! abs_dipole = abs_dipole + dsqrt( dot_product(dipole(:,j,Istep),dipole(:,j,Istep)) )
        data_beads(j,Istep) = dsqrt( dot_product(dipole(:,j,Istep),dipole(:,j,Istep)) )
      end do
    end do
    ! abs_dipole = abs_dipole/dble(TNstep*Nbeads)
    abs_dipole = sum(data_beads)/dble(TNstep*Nbeads)
    print '(a)', "The absolute dipole moment"
    print *, abs_dipole, " D "

block
  integer :: Ounit
  if ( save_beads .eqv. .True. ) then
    open(newunit=Ounit,file=FNameBinary1, form='unformatted', access='stream', status='replace')
      do Istep = 1, TNstep
        do i = 1, Nbeads
          write(Ounit) data_beads(i,Istep)
        end do
      end do
    close(Ounit)
  end if
end block

    return
  end subroutine dipole_analysis
! +++++++++++++++++++++++++++
! +++ end dipole_analysis +++
! +++++++++++++++++++++++++++

! +++++++++++++++++++++
! +++ hfcc_analysis +++
! +++++++++++++++++++++
  subroutine hfcc_analysis
    integer :: i,j,k,Istep
    allocate(hfcc(Natom,Nbeads,TNstep))


    print '(" *** START HFCC analysis ***")'
    open(newunit=Uinp, file=other_path, status='old', iostat=ierr)
      if ( ierr > 0 ) then
        print *, 'Check the path : ', other_path
        stop 'ERROR!!: There is no "hfcc.dat"'
      end if

      read(Uinp,'()')   ! Skip Header
      do i = 1, Nstart(1)-1
        read(Uinp,'()',end=900)
        do j = 1, Nbeads
          read(Uinp,'()')
        end do
      end do

      Istep = 0
      do k = Nstart(1), Nstep(1)
        Istep = Istep + 1
        read(Uinp,'()',end=900)
        do j = 1, Nbeads
          read(Uinp,*) hfcc(:,j,Istep)
        end do
      end do
    close(Uinp)

    block
      integer :: Ounit
      character(len=128) :: name_out
      if ( save_beads .eqv. .True. ) then
        open(newunit=Ounit, file=FNameBinary1, form='unformatted', access='stream', status='replace')
          do Istep = 1, TNstep
            do j = 1, Nbeads
              write(Ounit) hfcc(atom1,j,Istep)
            end do
          end do
        close(Ounit)
      end if
      write(*,'(" ***** HFCC of ",I3, " is saved *****")')  atom1
      write(*,*) "***** Binary data is saved in  ", FNameBinary1, " *****"
      data_beads = hfcc(atom1,:,:)
      name_out = "hist_hfcc.out"
      do k = 1, TNstep
        data_step(k) = sum(data_beads(:,k))/dble(Nbeads)
      end do

      call calc_1Dhist(out_hist_ex=name_out)

      open(newunit=Ounit,file="step_hfcc.out",status='replace')
        do k = 1, TNstep
          if (mod(k,graph_step) == 0 ) write(Ounit,'(I7,F10.5)') k, data_step(k) !sum(hfcc(atom1,:,k))/dble(Nbeads)
        end do
      close(Ounit)
    end block

    write(*,*) "*** All the HFCCs are as follows ***"
    write(*,*) "Num. HFCC"
    do i = 1, Natom
      print '(I4,F12.7)', i, sum(hfcc(i,:,:)) / dble(TNstep*Nbeads)
    end do

    call reblock_step()

    return
900 call err_line_exceed(k*(Nbeads+1) + j, k)
  end subroutine hfcc_analysis
! +++++++++++++++++++++++++
! +++ end hfcc_analysis +++
! +++++++++++++++++++++++++

subroutine err_line_exceed(Iline, Istep)
  integer, intent(in) :: Iline, Istep
  print *, 'The line is ', Iline
  print *, 'The step is ', Istep
  stop 'ERROR!!: Reading line exceed the coor lines'
end subroutine err_line_exceed

end module mod_other_quantities
! you can change text to line




