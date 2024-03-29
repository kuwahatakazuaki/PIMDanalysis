subroutine read_input
use input_parameter
implicit none
integer :: i, j, k
character(len=128) :: line
!character :: Cdummy

print '(" *****START reading parameters*****")'
block
  integer :: leng
  if ( command_argument_count() == 0) then
    print '(a)',   "   There is no argument"
    print '(a,/)', '   Reading from "input.dat"'
    allocate(character(9) :: input_file)
    write(input_file,'(a)') "input.dat"
  else
    call get_command_argument(1, length=leng)
      allocate(character(leng) :: input_file)
      call get_command_argument(1, input_file)
    print '(a,a,/)', "   Reading from ", '"'//input_file//'"'
  end if
end block

open(20,file=input_file,status='old',err=900)

! ========================
! === Reading job type ===
! ========================
  block
  character(len=100) :: FNtemp1 = "bin1.bin", FNtemp2 = "bin2.bin"
    rewind(20)
    do
      read(20,'(a)',end=101) line
        if (index(trim(line),"# job type") == 1 )  exit
    end do
    do  ! Reading job type (1:1D, 2:2D, 3:Angle)
      read(20,'(a)',end=100) line
      if     (index(trim(line), "-Nfile")       == 1) then; read(20,*) Nfile
      elseif (index(trim(line), "-Job type")    == 1) then; read(20,*) jobtype
      elseif (index(trim(line), "-graph_step")  == 1) then; read(20,*) graph_step
      elseif (index(trim(line), "-save_beads")  == 1) then; read(20,*) save_beads
      else if (index(trim(line),"-folding")     == 1) then; read(20,*) Lfolding
      elseif (index(trim(line), "-name_binary") == 1) then
        if (jobtype == 29 .or. jobtype == 28 ) then
          read(20,'(a)') FNtemp1
          read(20,'(a)') FNtemp2
        else
          read(20,*) FNtemp1
        end if
      elseif (index(trim(line), "# end job type") == 1)  then; exit
      end if
    end do
  ! +++ Default options +++
    FNameBinary1 = trim(FNtemp1)
    FNameBinary2 = trim(FNtemp2)
  ! +++ End Default options +++
  end block
! ============================
! === End Reading job type ===
! ============================

  allocate(DirResult(Nfile))
  allocate(FileName(Nfile))
  allocate(Nstep(Nfile))
  allocate(Nstart(Nfile))
  allocate(atom_num(5,Nfile))

  Natom = -1
  Nbeads = -1
  Nstep(:) = -1
  atom_num(:,1) = 0

! ================================
! --- Reading input parameters ---
! ================================
  rewind(20)
  do j = 1, Nfile
    do
      read(20,'(a)',end=102) line
        if (line(1:12) == "# input file" ) exit
    end do
    do
      read(20,'(a)',end=100) line
      if     (index(trim(line),"-FileName")  == 1) then; read(20,'(a)') FileName(j)
      elseif (index(trim(line),"-DirResult") == 1) then; read(20,'(a)') DirResult(j)
      elseif (index(trim(line),"-Binary" )   == 1) then; read(20,*,err=111) FIbinary
      elseif (index(trim(line),"-Natom" )    == 1) then; read(20,*) Natom
      elseif (index(trim(line),"-Nbeads")    == 1) then; read(20,*) Nbeads
      elseif (index(trim(line),"-Nstart")    == 1) then; read(20,*) Nstart(j)
      elseif (index(trim(line),"-Nstep" )    == 1) then; read(20,*) Nstep(j)
      elseif (index(trim(line),"-atom1" )    == 1) then; read(20,*) atom_num(1,j)
      elseif (index(trim(line),"-atom2" )    == 1) then; read(20,*) atom_num(2,j)
      elseif (index(trim(line),"-atom3" )    == 1) then; read(20,*) atom_num(3,j)
      elseif (index(trim(line),"-atom4" )    == 1) then; read(20,*) atom_num(4,j)
      elseif (index(trim(line),"-atom5" )    == 1) then; read(20,*) atom_num(5,j)
      elseif (index(trim(line),"# end file") == 1) then; exit
      end if
    end do
  end do


  ! if (atom(:) = 0); then atom(j) = atom(1) (j>=2)
  do j = 2, Nfile
    do k = 1, 5
      if (atom_num(k,j) == 0) atom_num(k,j) = atom_num(k,1)
    end do
  end do
! ====================================
! --- End Reading input parameters ---
! ====================================


! ===================================
! --- Reading histogram parameters ---
! ===================================
  rewind(20)
  do
    read(20,'(a)',end=110) line
    if (trim(line) == "# histgram parameters" ) then
      print *, 'Please change the "# histgram" to "# histogram"'
      print *, 'Type the "%s/histgram/histogram/gc" in vim"'
      !stop "Error"
    end if
  end do
110 continue

  rewind(20)
  do
    read(20,'(a)',end=103) line
      if (trim(line) == "# histogram parameters" .or. trim(line) == "# histgram parameters") exit
  end do
  hist_min(:) = 0.0d0
  hist_max(:) = 0.0d0
  do
    read(20,'(a)',end=120) line
    if     (index(trim(line) ,"-Nhist")       == 1) then; read(20,*) Nhist
    elseif (index(trim(line) ,"-Xrange_min" ) == 1) then; read(20,*) hist_min(1)
    elseif (index(trim(line) ,"-Xrange_max" ) == 1) then; read(20,*) hist_max(1)
    elseif (index(trim(line) ,"-Yrange_min" ) == 1) then; read(20,*) hist_min(2)
    elseif (index(trim(line) ,"-Yrange_max" ) == 1) then; read(20,*) hist_max(2)
    elseif (index(trim(line) ,"-hist_margin") == 1) then; read(20,*) hist_margin
    elseif (index(trim(line) ,"-Output_name") == 1) then; read(20,*) out_hist
    elseif (index(trim(line) ,"# end"       ) == 1) then; exit
    end if
  end do
! ===============================
! --- End histogram parameters ---
! ===============================

! ==========================
! --- Reading multi bond ---
! ==========================
  rewind(20)
  do
    read(20,'(a)',end=104) line
      if (index(trim(line) ,'# multi bond') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if (trim(line) == "-Nbond" ) then; read(20,*) Nbond
      allocate(atom_multi(2,Nbond))
      read(20,'()')
      do i = 1, Nbond
        read(20,*) atom_multi(:,i)
      end do
    else if (index(trim(line),"-folding") == 1) then; read(20,*) Lfolding
    else if (index(trim(line),"# end"   ) == 1) then; exit
    end if
  end do
104 continue
! ==============================
! --- End Reading multi bond ---
! ==============================


! ===========================
! --- Reading dummy atom ---
! ===========================
  rewind(20)
  do
    read(20,'(a)',end=105) line
      if (index(trim(line),'# dummy atom') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-definition of dummy") > 0 ) then; read(20,*) definition_dummy
    elseif (index(trim(line) ,"-atom_temp1" ) > 0)          then; read(20,*) atom_dummy(1)
    elseif (index(trim(line) ,"-atom_temp2" ) > 0)          then; read(20,*) atom_dummy(2)
    elseif (index(trim(line) ,"# end"       ) > 0)          then; exit
    end if
  end do
105 continue
! --- End Reading dummy atom ---

! ==========================
! --- Reading other type ---
! ==========================
  rewind(20)
  do
    read(20,'(a)',end=106) line
      if (index(trim(line),'# other type') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-type") == 1 ) then; read(20,*) other_type
    elseif (index(trim(line) ,"-path") == 1)  then
      read(20,'(a)') line
      other_path = trim(line)
    elseif (index(trim(line) ,"# end") > 0)  then; exit
    end if
  end do
106 continue
! ==============================
! --- End Reading other type ---
! ==============================

! ========================
! === Reading Rotation ===
! ========================
  rewind(20)
  do
    read(20,'(a)',end=109) line
      if (index(trim(line),'# Rotation') == 1) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-Nhyd")  == 1 ) then
      read(20,*) Nhyd
      allocate(hyd(Nhyd), r_ref(3,Natom), weight(Natom), label(Natom))
    elseif (index(trim(line) ,"-Hatom")  == 1)  then
      do i = 1, Nhyd
        read(20,*) hyd(i)
      end do
    elseif (index(trim(line) ,"-Atom_density") == 1) then; read(20,*) atom_density
    elseif (index(trim(line) ,"-Ndiv") == 1)         then; read(20,*) Ndiv
    elseif (index(trim(line) ,"-coord") == 1)  then
      do i = 1, Natom
        read(20,*) label(i), weight(i), r_ref(:,i)
      end do
    elseif (index(trim(line) ,"-end coord") == 1)  then
      exit
    end if
  end do
109 continue
! ====================
! === End Rotation ===
! ====================

! =================================
! === Reading umbrella sampling ===
! =================================
  rewind(20)
  do
    read(20,'(a)',end=107) line
      if (index(trim(line),'# umbrella sampling') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-type")  > 0 ) then; read(20,*) umbrella_type
    elseif (index(trim(line) ,"-temperature") > 0)  then; read(20,*) temperature
    elseif (index(trim(line) ,"-atom1") > 0)  then; read(20,*) umbrella_atom1
    elseif (index(trim(line) ,"-atom2") > 0)  then; read(20,*) umbrella_atom2
    elseif (index(trim(line) ,"-atom3") > 0)  then; read(20,*) umbrella_atom3
    elseif (index(trim(line) ,"-force") > 0)  then; read(20,*) umbrella_force
    elseif (index(trim(line) ,"# end")  > 0)  then; exit
    end if
  end do
107 continue
! =============================
! === End umbrella sampling ===
! =============================

! ========================
! === Reading periodic ===
! ========================
  rewind(20)
  do
    read(20,'(a)',end=108) line
      if (index(trim(line),'# periodic') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-Lbox") > 0)      then
      do j = 1, 3
        read(20,*) Lbox(j)
      end do
    elseif (index(trim(line) ,"-Ielement1") > 0) then; read(20,*) Ielement1
    elseif (index(trim(line) ,"-Felement1") > 0) then; read(20,*) Felement1
    elseif (index(trim(line) ,"-Ielement2") > 0) then; read(20,*) Ielement2
    elseif (index(trim(line) ,"-Felement2") > 0) then; read(20,*) Felement2
    elseif (index(trim(line) ,"-OHO distribution") > 0) then
      read(20,'(a)') line
        read(20,*) Noho
        allocate(label_oho(3,Noho))
      read(20,'(a)') line
        do j = 1, Noho
          read(20,*) label_oho(:,j)
        end do
    elseif (index(trim(line) ,"# end periodic")  > 0)  then; exit
    end if
  end do
108 continue
! ====================
! === End periodic ===
! ====================

! ======================
! === Reading PbHPO4 ===
! ======================
  rewind(20)
  do
    read(20,'(a)',end=131) line
      if (index(trim(line),'# PbHPO4') > 0) exit
  end do
  do
    read(20,'(a)',end=100) line
    if     (index(trim(line) ,"-Lattice") > 0)      then
      do j = 1, 3
        read(20,*) lattice(j,:)
      end do
    elseif (index(trim(line) ,"-Nunit") > 0)  then; read(20,*) Nunit
    elseif (index(trim(line) ,"# end")  > 0)  then; exit
    end if
  end do
131 continue
! ==================
! === End PbHPO4 ===
! ==================

! --- Erro Check !! ---
  if     ( Natom < 0) then; print *, "ERROR!!: Write Natom!!";  stop
  elseif (Nbeads < 0) then; print *, "ERROR!!: Write Nbeads!!"; stop
  endif
  do j = 1, Nfile
    if     (Nstart(j) < 0) then; print *, "ERROR!!: Write Nstart!!"; stop
    elseif ( Nstep(j) < 0) then; print *, "ERROR!!: Write Nstep!!";  stop
    end if
    do k = 1, 5
      if (atom_num(k,j) < 0) then
        print *, "ERROR!!: Write atom of ",k; stop
      end if
    end do
  end do
! --- End Erro Check !! ---

! --- Print input parameters ---
  print '(" ***Input parameters as follows***")'
  print '("   jobtype = ",I0)', jobtype
  print '("   Natom   = ",I0)', Natom
  print '("   Nbeads  = ",I0)', Nbeads
  print '("   Nfile   = ",I0,/)', Nfile
  do j = 1, Nfile
    print '(a,i0,a)', " ***Input from the file # ", j, "***"
    print '(a,a)',  "   FileName = ", trim(FileName(j))
    print '(a,L)',  "   Binary   = ", FIbinary
    print '(a,I0)', "   Nstart   = ", Nstart(j)
    print '(a,I0)', "   Nstep    = ", Nstep(j)
    do k = 1, 5
      print '("   atom",I0,"  = ", I0)', k, atom_num(k,j)
    end do
    print *, ""
  end do
  TNstep = 0
  do j = 1, Nfile
    TNstep = TNstep + Nstep(j) - Nstart(j) + 1
  end do
  print '(a, i0)', "   The total number of step = ", TNstep
! --- End Print input parameters ---

close(20)
print '(a,/)', " *****END reading parameters*****"

return
!  100 print *, 'ERROR!!: Miss much of "# End ~~"'; stop
  100 print *, 'ERROR!!: There is no "# End ~~"'; stop
  101 print *, 'ERROR!!: There is no "# job type", check -name_binary'; stop
  102 print *, 'ERROR!!: There is no "# input file"'; stop
  103 print *, 'ERROR!!: There is no "# histogram parameters"'; stop
!  104 print *, 'ERROR!!: There is no "# multi bond"'; stop
!  105 print *, 'ERROR!!: There is no "# dummy atom"'; stop
!  106 print *, 'ERROR!!: There is no "# other type"'; stop
!  107 print *, 'ERROR!!: There is no "# umbrella sampling"'; stop
  111 print *, 'ERROR!!: "-Binary" must be T or F'; stop
  120 print *, 'ERROR!!: There is no "# end histogram parameters"'; stop
  900 print *, 'ERROR!!: There is no "input.dat"'; stop
end subroutine read_input

