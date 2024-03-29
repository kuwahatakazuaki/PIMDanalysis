! Analysing PIMD data
! last modified 2022/10/05
! program structure
! all of the data are stored in the 'data_beads', and this is analyzed according to the 'jobtype' option

program analysis
use input_parameter
use calc_parameter
use calc_centoroid
use calc_histogram1D
use calc_histogram2D
use mod_other_quantities
use mod_special_case
use mod_periodic
implicit none

! +++ Reading the input file +++
call read_input

! r(:,i,j,k) = r(xyz,atom,beads,step)
allocate(r(3,Natom,Nbeads,TNstep))
allocate(atom(Natom))
allocate(data_step(TNstep), source=0.0d0)
allocate(data_beads(Nbeads,TNstep), source=0.0d0)

! +++ Reading coordinate +++
select case(jobtype)
  case(60:69)
    print *, "Skip reading coor.xyz"
  case default
    call read_coor
end select

! Choose "job type"
!   1 : 1D histogram of bond         (atom1-atom2)
!   2 : Angle histogram              (atom1-atom2-atom3)
!   3 : Dihedral angle              (atom1-atom2-atom3-atom4)
!   9 : 1D histogram from External
!  11 : Multi bond calc all
!  12 : Multi bond sort
!  13 : Multi bond diff              (atom1-atom2  -  atom3-atom4)
!  14 : Multi bond diff              (atom1-atom2  +  atom3-atom4)
!  21 : 2D histogram_bond            (atom1-atom2 and atom3-atom4)
!  22 : 2D histogram_angle           (atom1-atom2 and atom3-atom4-atom5)
!  28 : 2D histogram from External   (Arbitrary number line)
!  29 : 2D histogram from External   (Normal)
!  31 : 1D histogram for Centroid
!  32 : 2D histogram for Centroid
!  33 : Angle histogram for Centroid
!  41 : Dummy atom (X) for bond      (atom1-atomX)
!  42 : Dummy atom (X) for angle     (atom1-atom2-atomX)
!  43 : Dummy atom (X) for dihedral  (atom1-atom2-atomX-atom4)
!  51 : Beads expansion      (all atoms)
!  52 : Beads expansion      (export binary of atom1)
!  53 : Beads expansion      (atom1 projected to atom2-atom3)
!  61 : charge_analysis      (all atoms)
!  62 : charge_analysis      (atom1)
!  63 : dipole_analysis
!  64 : hfcc_analysis        (atom1)
!  71 : projection           (atom1-atom2  T  atom3-atom4)
!  75 : Rotation (movie)
!  76 : Rotation (cube file)
!  77 : Rotation (cube file from external)
!  81 : radial distribution  (element1)
!  82 : radial distribution  (element1 to element2)
!  83 : OHO distribution
!  91 : Out of plane         (atom2-atom1-atom3 -> atom1-atom4)
! 191 : PbHPO4  (O-O distribution)
! 192 : PbHPO4  (dleta OH distribution)
!!!! 101 : binary mask       (bin1 if (bin2) )
!!!! 102 : binary add        (bin1 + bin2)
!!!! 103 : binary diff       (bin1 - bin2)

select case(jobtype)
  case(1)
    call calc_bond
  case(2)
    call calc_angle
  case(3)
    call calc_dihedral
  case(9)
    call external_1Dhist
  case(11:14)
    call multi_bond
  case(21:22)
    call calc_2Dhist
  case(28)
    call external_2Dhits_arbitrary
  case(29)
    call external_2Dhits
  case(31:39)
    call calc_cent
  case(41:49)
    call dummy_atom
  case(51:54)
    call beads_expansion
  case(61:64)
    call other_quantities
  case(71)
    call projection
  case(75:77)
    call rotation
  case(81:85)
    call periodic
  case(91)
    call special_case
  case(191:195)
    call pbhpo4
  case default
    stop 'ERROR!!! wrong "Job type" option'
end select

!deallocate(r)
!deallocate(atom)
!deallocate(data_step)
!deallocate(data_beads)
print '(a,/)', " Normal termination"
stop
end program analysis
