%=$[$ ' vim:syntax=golem
$]module olp_model
   ! Model parameters for the model: [$ model $]
   use olp_config, only: ki[$
@if extension samurai $], &
   & samurai_scalar, samurai_verbosity, samurai_test, &
   & samurai_group_numerators, samurai_istop[$
@end @if $], &
   & renormalisation, reduction_interoperation, deltaOS, &
   & nlo_prefactors, convert_to_cdr[$
@select modeltype @case sm smdiag sm_complex smdiag_complex smehc $][$
@if ewchoose $], ewchoice[$
@end @if$][$@end @select$]
   implicit none

   private :: ki[$
@if extension samurai $]
   private :: samurai_scalar, samurai_verbosity, samurai_test
   private :: samurai_group_numerators, samurai_istop[$
@end @if $]
   private :: renormalisation, reduction_interoperation, deltaOS
   private :: nlo_prefactors

   real(ki), parameter :: sqrt2 = &
      &1.414213562373095048801688724209698078&
      &5696718753769480731766797379_ki
   real(ki), parameter :: sqrt3 = &
      &1.732050807568877293527446341505872366&
      &9428052538103806280558069795_ki
   [$
      @for parameters $]
   [$    @select type
         @case R $]real(ki) :: [$$_$] = [$
               real convert=float format=%24.15f_ki $][$
         @case C $]complex(ki) :: [$$_$] = ([$
               real convert=float format=%24.15f_ki $], [$
               imag convert=float format=%24.15f_ki $])[$
         @case RP $]real(ki), parameter :: [$$_$] = [$
               real convert=float format=%24.15f_ki $][$
         @case CP $]complex(ki), parameter :: [$$_
                          $] = ([$
               real convert=float format=%24.15f_ki $], [$
               imag convert=float format=%24.15f_ki $])[$
         @end @select type $][$
      @end @for parameters $][$
      @for functions $]
   [$    @select type
         @case R $]real(ki) :: [$$_$][$
         @case C $]complex(ki) :: [$$_$][$
         @end @select type $][$
      @end @for functions $]

   integer, parameter, private :: line_length = [$buffer_length$][$
   ' what is our longest extra name ?
   ' 0   0    1    1    2    2
   ' 1---5----0----5----0----5
   ' samurai_group_numerators
   ' reduction_interoperation
   ' samurai_verbatim
   ' renormalisation
   ' samurai_scalar
   ' samurai_test
   '
   ' ==> the longest is 24
   $]
   integer, parameter, private :: name_length = max([$name_length$],24)
   character(len=name_length), dimension([$ count R C $]) :: names = (/&[$
   @for parameters R C  $]
      & "[$ $_ $][$ alignment $]"[$
         @if is_last $]/)[$ @else $], &[$ @end @if $][$
   @end @for parse_names $]
   character(len=1), dimension([$ len_comment_chars $]) :: cc = (/[$
   @for comment_chars $]'[$$_$]'[$ @if is_last $]/)[$ @else $], [$
   @end @if $][$
   @end @for$]

[$ @if ewchoose $]
   ! for automatic choosing the right EW scheme in set_parameters
   integer, private :: choosen_ew_parameters ! bit-set of EW parameters
   character(len=5), private, dimension(6) :: ew_parameters = &
          &(/'mW   ',&
          &  'mZ   ',&
          &  'alpha',&
          &  'GF   ',&
          &  'sw   ',&
          &  'e    '/)
   integer, private :: choosen_ew_parameters_count = 0 ! bitset of EW parameters
   integer, private :: orig_ewchoice = -1 ! saves the original ewchoice[$
@end @if$]

   private :: digit, parsereal, names, cc

contains


!---#[ print_parameter:
   ! Print current parameters / setup to stdout or output_unit
   subroutine   print_parameter(verbose,output_unit)
      implicit none
      logical, intent(in), optional :: verbose
      integer, intent(in), optional :: output_unit
      logical :: is_verbose
      integer :: unit

      real(ki), parameter :: pi = 3.14159265358979323846264&
     &3383279502884197169399375105820974944592307816406286209_ki
      is_verbose = .false.
      if(present(verbose)) then
          is_verbose = verbose
      end if

      unit = 6 ! stdout
      if(present(output_unit)) then
          unit = output_unit
      end if


   write(unit,'(A1,1x,A26)') "#", "--------- SETUP ---------"
   write(unit,'(A1,1x,A18,I2)') "#", "renormalisation = ", renormalisation
   if(convert_to_cdr) then
      write(unit,'(A1,1x,A9,A3)') "#", "scheme = ", "CDR"
   else
      write(unit,'(A1,1x,A9,A4)') "#", "scheme = ", "DRED"
   end if
   if(reduction_interoperation.eq.0) then
      write(unit,'(A1,1x,A15,A7)') "#", "reduction with ", "SAMURAI"
   else if(reduction_interoperation.eq.1) then
      write(unit,'(A1,1x,A15,A7)') "#", "reduction with ", "GOLEM95"
   else if(reduction_interoperation.eq.2) then
      write(unit,'(A1,1x,A15,A15)') "#", "reduction with ", "SAMURAI+GOLEM95"
   else if(reduction_interoperation.eq.31) then
      write(unit,'(A1,1x,A15,A5)') "#", "reduction with ", "NINJA"
   end if[$
@if ewchoose $]
    write(unit,'(A1,1x,A11,I2)') "#", "ewchoice = ", ewchoice[$
@end @if$][$
@select modeltype @case sm smdiag smehc sm_complex smdiag_complex smehc $]
   write(unit,'(A1,1x,A27)') "#", "--- PARAMETERS Overview ---"
   write(unit,'(A1,1x,A22)') "#", "Boson masses & widths:"
   write(unit,'(A1,1x,A5,G23.16)') "#", "mZ = ", mZ
   write(unit,'(A1,1x,A5,G23.16)') "#", "mW = ", mW
   write(unit,'(A1,1x,A5,G23.16)') "#", "mH = ", mH
   write(unit,'(A1,1x,A5,G23.16)') "#", "wZ = ", wZ
   write(unit,'(A1,1x,A5,G23.16)') "#", "wW = ", wW
   write(unit,'(A1,1x,A5,G23.16)') "#", "wH = ", wH
   write(unit,'(A1,1x,A20)') "#", "Active light quarks:"
   write(unit,'(A1,1x,A7,G23.16)') "#", "Nf    =", Nf
   write(unit,'(A1,1x,A7,G23.16)') "#", "Nfgen =", Nfgen
   write(unit,'(A1,1x,A23)') "#", "Fermion masses & width:"
   write(unit,'(A1,1x,A7,G23.16)') "#", "mU   = ", mU
   write(unit,'(A1,1x,A7,G23.16)') "#", "mD   = ", mD
   write(unit,'(A1,1x,A7,G23.16)') "#", "mS   = ", mS
   write(unit,'(A1,1x,A7,G23.16)') "#", "mC   = ", mC
   write(unit,'(A1,1x,A7,G23.16)') "#", "mB   = ", mB
   write(unit,'(A1,1x,A7,G23.16)') "#", "mBMS = ", mBMS
   write(unit,'(A1,1x,A7,G23.16)') "#", "wB   = ", wB
   write(unit,'(A1,1x,A7,G23.16)') "#", "mT   = ", mT
   write(unit,'(A1,1x,A7,G23.16)') "#", "wT   = ", wT
   write(unit,'(A1,1x,A7,G23.16)') "#", "me   = ", me
   write(unit,'(A1,1x,A7,G23.16)') "#", "mmu  = ", mmu
   write(unit,'(A1,1x,A7,G23.16)') "#", "mtau = ", mtau
   write(unit,'(A1,1x,A7,G23.16)') "#", "wtau = ", wtau
   write(unit,'(A1,1x,A14)') "#", "Couplings etc.:"
   write(unit,'(A1,1x,A9,G23.16)') "#", "alphaS = ", gs*gs/4._ki/pi
   write(unit,'(A1,1x,A9,G23.16)') "#", "gs     = ", gs
   write(unit,'(A1,1x,A9,G23.16)') "#", "alpha  = ", alpha
   write(unit,'(A1,1x,A9,G23.16)') "#", "e      = ", e
   write(unit,'(A1,1x,A9,G23.16)') "#", "GF     = ", GF[$
@select modeltype @case sm_complex smdiag_complex $]
   write(unit,'(A1,1x,A9,"(",G23.16,G23.16,")")') "#", "sw     = ", sw
   write(unit,'(A1,1x,A9,"(",G23.16,G23.16,")")') "#", "sw2    = ", sw*sw[$
@else $]
   write(unit,'(A1,1x,A9,G23.16)') "#", "sw     = ", sw
   write(unit,'(A1,1x,A9,G23.16)') "#", "sw2    = ", sw*sw
[$ @end @select$]
   if(is_verbose) then[$
@end @select $]
   write(unit,'(A1,1x,A21)') "#", "--- ALL PARAMETERS ---"[$
@for parameters $][$
   @select type @case R $]
   write(unit,'(A1,1x,A7,G23.16)') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @case C $]
   write(unit,'(A1,1x,A7,"(",G23.16,G23.16,")")') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @case RP $]
   write(unit,'(A1,1x,A7,G23.16,"const.")') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @case CP $]
   write(unit,'(A1,1x,A7,"(",G23.16,G23.16,")","const.")') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @end @select type $][$
@end @for parameters $]
   if(is_verbose) then
[$
@for functions $][$
   @select type @case R $]
   write(unit,'(A1,1x,A7,G23.16,"calc.")') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @case C $]
   write(unit,'(A1,1x,A7,"(",G23.16,G23.16,")"," calc.")') "#", "[$$_ convert=str format=%-5s$]= ", [$$_$][$
   @end @select type $][$
@end @for functions $]
   end if[$
@select modeltype @case sm smdiag smehc sm_complex smdiag_complex smehc $]
   end if[$
@end @select$]
   write(unit,'(A1,1x,A25)') "#", "-------------------------"
   end subroutine
!---#] print_parameter:

   function     digit(ch, lnr) result(d)
      implicit none
      character(len=1), intent(in) :: ch
      integer, intent(in) :: lnr
      integer :: d
      d = -1
      select case(ch)[$
         @for repeat 10 $]
         case('[$$_$]')
            d = [$$_$][$
         @end @for $]
         case default
            write(*,'(A21,1x,I5)') 'invalid digit in line', lnr
         end select
   end function digit

   function     parsereal(str, ierr, lnr) result(num)
      implicit none
      character(len=*), intent(in) :: str
      integer, intent(out) :: ierr
      integer, intent(in) :: lnr
      integer, dimension(0:3,0:4), parameter :: DFA = &
      & reshape( (/1,  1,  2, -1,   & ! state = 0
      &            1, -1,  2,  3,   & ! state = 1
      &            2, -1, -1,  3,   & ! state = 2
      &            4,  4, -1, -1,   & ! state = 3
      &            4, -1, -1, -1/), (/4, 5/))
      real(ki) :: num
      integer :: i, expo, ofs, state, cclass, d, s1, s2
      num = 0.0_ki
      expo = 0
      state = 0
      ofs = 0
      s1 = 1
      s2 = 1
      d = -1
      cclass = -1
      do i=1,len(str)
         select case(str(i:i))
         case('_', '''', ' ')
            cycle
         case('+', '-')
            cclass = 1
         case('.')
            cclass = 2
         case('E', 'e')
            cclass = 3
         case default
            cclass = 0
            d = digit(str(i:i), lnr)
            if (d .eq. -1) then
               ierr = 1
               return
            end if
         end select
         if (cclass .eq. 0) then
            select case(state)
            case(0, 1)
               num = 10.0_ki * num + d
            case(2)
               num = 10.0_ki * num + d
               ofs = ofs - 1
            case(4)
               expo = 10 * expo + d
            end select
         elseif ((cclass .eq. 1) .and. (str(i:i) .eq. '-')) then
            if (state .eq. 0) then
               s1 = -1
            else
               s2 = -1
            endif
         end if
         ! Advance in the DFA
         state = DFA(cclass, state)
         if (state < 0) then
            write(*,'(A21,1x,A1,1x,A7,I5)') 'invalid position for', &
            & str(i:i), 'in line', lnr
            ierr = 1
            return
         end if
      end do
      num = s1 * num * 10.0_ki**(ofs + s2 * expo)
      ierr = 0
   end function parsereal

   subroutine     parseline(line,stat,line_number)
      implicit none
      character(len=*), intent(in) :: line
      integer, intent(out) :: stat
      integer, intent(in), optional :: line_number

      character(len=line_length) :: rvalue, ivalue, value
      character(len=name_length) :: name
      real(ki) :: re, im
      integer :: idx, icomma, idx1, idx2, lnr, nidx, ierr, pdg

      if(present(line_number)) then
         lnr = line_number
      else
         lnr = 0
      end if

      idx = scan(line, '=', .false.)
      if (idx .eq. 0) then
         if(present(line_number)) then
            write(*,'(A13,1x,I5)') 'error at line', line_number
         else
            write(*,'(A18)') 'error in parseline'
         end if
         stat = 1
         return
      end if
      name = adjustl(line(1:idx-1))
      value = adjustl(line(idx+1:len(line)))
      idx = scan(value, ',', .false.)

      if (name .eq. "renormalisation") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         renormalisation = int(re)
      elseif (name .eq. "nlo_prefactors") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         nlo_prefactors = int(re)
      elseif (name .eq. "deltaOS") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         deltaOS = int(re)
      elseif (name .eq. "reduction_interoperation") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         reduction_interoperation = int(re)[$
@if extension samurai $]
      elseif (name .eq. "samurai_scalar") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         samurai_scalar = int(re)
      elseif (name .eq. "samurai_verbosity") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         samurai_verbosity = int(re)
      elseif (name .eq. "samurai_test") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         samurai_test = int(re)
      elseif (name .eq. "samurai_istop") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         samurai_istop = int(re)
      elseif (name .eq. "samurai_group_numerators") then
         re = parsereal(value, ierr, lnr)
         if (ierr .ne. 0) then
            stat = 1
            return
         end if
         samurai_group_numerators = (int(re).ne.0)[$
@end @if $]
      elseif (any(names .eq. name)) then
         do nidx=1,size(names)
            if (names(nidx) .eq. name) exit
         end do
         if (idx .gt. 0) then
            rvalue = value(1:idx-1)
            ivalue = value(idx+1:len(value))
            re = parsereal(rvalue, ierr, lnr)
            if (ierr .ne. 0) then
               stat = 1
               return
            end if
            im = parsereal(ivalue, ierr, lnr)
            if (ierr .ne. 0) then
               stat = 1
               return
            end if
         else
            re = parsereal(value, ierr, lnr)
            if (ierr .ne. 0) then
               stat = 1
               return
            end if
            im = 0.0_ki
         end if
         select case (nidx)[$
         @for parameters R C $]
         case([$index$])
            [$ $_ $] = [$
         @select type
         @case C$]cmplx(re, im, ki)[$
         @else $]re[$
         @end @select $][$
         @end @for $]
         end select[$
@if has_slha_locations $][$
   @for slha_blocks lower dimension=1 $]
      elseif (name(1:[$ eval 1 + .len. $_ $]).eq."[$ $_ $](") then
         idx = scan(name, ')', .false.)
         if (idx.eq.0) then
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         endif
         read(name([$ eval 2 + .len. $_ $]:idx-1),*, iostat=ierr) pdg
         if (ierr.ne.0) then
            write(*,*) "Not an integer:", name([$
                    eval 2 + .len. $_ $]:idx-1)
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         end if
         select case(pdg)[$
      @for slha_entries $]
            case([$index$])
               [$ $_ $] = parsereal(value, ierr, lnr)[$
      @end @for $]
            case default
               write(*,'(A20,1x,I10)') "Cannot set [$ $_ $] for code:", pdg
               stat = 1
               return
         end select[$
   @end @for $][$
   @for slha_blocks lower dimension=2 $]
      elseif (name(1:[$ eval 1 + .len. $_ $]).eq."[$ $_ $](") then
         idx = scan(name, ')', .false.)
         if (idx.eq.0) then
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         endif
         icomma = scan(name(1:idx), ',', .false.)
         if (icomma.eq.0) then
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         endif
         read(name([$ eval 2 + .len. $_ $]:icomma-1),*, iostat=ierr) idx1
         if (ierr.ne.0) then
            write(*,*) "Not an integer:", name([$
                    eval 2 + .len. $_ $]:icomma-1)
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         end if
         read(name(icomma+1:idx-1),*, iostat=ierr) idx2
         if (ierr.ne.0) then
            write(*,*) "Not an integer:", name(icomma+1:idx-1)
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         end if[$
      @for slha_entries index=index1 $]
         [$
         @if is_first $][$ @else $]else[$
         @end @if$]if(idx1.eq.[$index1$]) then[$
         @for slha_entries index=index2 $]
            [$
            @if is_first $][$ @else $]else[$
            @end @if $]if(idx2.eq.[$index2$]) then
               [$ $_ $] = parsereal(value, ierr, lnr)[$
            @if is_last $]
            end if[$
            @end @if $][$
         @end @for $][$
         @if is_last $]
         end if[$
         @end @if $][$
      @end @for $][$
   @end @for $][$
@end @if $]
      elseif (name(1:2).eq."m(" .or. name(1:2).eq."w(") then
         idx = scan(name, ')', .false.)
         if (idx.eq.0) then
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         endif
         read(name(3:idx-1),*, iostat=ierr) pdg
         if (ierr.ne.0) then
            write(*,*) "pdg is not an integer:", name(3:idx-1)
            if(present(line_number)) then
               write(*,'(A13,1x,I5)') 'error at line', line_number
            else
               write(*,'(A18)') 'error in parseline'
            end if
            stat = 1
            return
         end if
         if (name(1:1).eq."m") then
            ! set mass according to PDG code
            select case(pdg)[$
@if has_slha_locations $][$
   @for slha_blocks lower $][$
      @select $_ @case masses $][$
         @for slha_entries $]
            case([$index$])
               [$ $_ $] = parsereal(value, ierr, lnr)[$
         @end @for $][$
      @end @select $][$
   @end @for $][$
@end @if $]
            case default
               write(*,'(A20,1x,I10)') "Cannot set mass for PDG code:", pdg
               stat = 1
               return
            end select
         else
            ! set width according to PDG code
            select case(pdg)[$
@if has_slha_locations $][$
   @for slha_blocks lower $][$
      @select $_ @case decay $][$
         @for slha_entries $]
            case([$index$])
               [$ $_ $] = parsereal(value, ierr, lnr)[$
         @end @for $][$
      @end @select $][$
   @end @for $][$
@end @if $]
            case default
               write(*,'(A20,1x,I10)') "Cannot set width for PDG code:", pdg
               stat = 1
               return
            end select
         endif
      else
         write(*,'(A20,1x,A20)') 'Unrecognized option:', name
         stat = 1
         return
      end if
      stat = 0
   end subroutine parseline

   subroutine     parse(aunit)
      implicit none
      integer, intent(in) :: aunit
      character(len=line_length) :: line
      integer :: ios, lnr
      lnr = 0
      loop1: do
         read(unit=aunit,fmt='(A[$buffer_length$])',iostat=ios) line
         if(ios .ne. 0) exit
         lnr = lnr + 1
         line = adjustl(line)
         if (line .eq. '') cycle loop1
         if (any(cc .eq. line(1:1))) cycle loop1

         call parseline(line,ios,lnr)
         if(ios .ne. 0) then
            write(*,'(A44,I2,A1)') &
            & 'Error while reading parameter file in parse(', aunit, ')'
         end if
      end do loop1
   end subroutine parse[$
@if has_slha_locations $]
!---#[ SLHA READER:
   subroutine     read_slha(ch, ierr)
      implicit none
      integer, intent(in) :: ch
      integer, intent(out), optional :: ierr

      integer :: lnr, i, l, ofs, ios
      character(len=255) :: line

      integer :: block

      ofs = iachar('A') - iachar('a')

      lnr = 0
      loop1: do
         read(unit=ch,fmt='(A[$buffer_length$])',iostat=ios) line
         if(ios .ne. 0) exit
         lnr = lnr + 1

         i = scan(line, '#', .false.)
         if (i .eq. 0) then
            l = len_trim(line)
         else
            l = i - 1
         end if

         if (l .eq. 0) cycle loop1

         ucase: do i = 1, l
            if (line(i:i) >= 'a' .and. line(i:i) <= 'z') then
               line(i:i) = achar(iachar(line(i:i))+ofs)
            end if
         end do ucase

         if (line(1:1) .eq. 'B') then
            if (line(1:5) .eq. 'BLOCK') then
               line = adjustl(line(6:l))
               do i=1,l
                 if (line(i:i) <= ' ') exit
               end do
               l = i[$
         @for slha_blocks upper $]
               [$
            @if is_first $][$ @else $]else[$
            @end @if
               $]if ("[$ $_ $]" .eq. line(1:l)) then
                  block = [$ index $][$
            @if is_last $]
               else
                  block = -1
               end if[$
            @end @if $][$
         @end @for $]
            else
               write(*,'(A37,I5)') "Illegal statement in SLHA file, line ", lnr
               if (present(ierr)) ierr = 1
               return
            end if[$
         @for slha_blocks lower $][$
            @select $_ @case decay $]
         elseif (line(1:1) .eq. 'D') then
            if (line(1:5) .eq. 'DECAY') then
               line = adjustl(line(6:l))
               call read_slha_line_decay(line, i)
               block = 2
            else
               write(*,'(A37,I5)') "Illegal statement in SLHA file, line ", lnr
               if (present(ierr)) ierr = 1
               return
            end if[$
            @end @select $][$
         @end @for $]
         else
            ! read a parameter line
            select case(block)[$
         @for slha_blocks lower $]
            case([$ index $])
               call read_slha_block_[$ $_ $](line(1:l), i)
               if (i .ne. 0) then
                  if (present(ierr)) ierr = 1
                  write(*,'(A44,I5)') &
                  & "Unrecognized line format in SLHA file, line ", lnr
                  return
               end if[$
         @end @for $]
            case default
               cycle loop1
            end select
         end if
      end do loop1
      if (present(ierr)) ierr = 0
   end subroutine read_slha[$
   @for slha_blocks lower dimension=1 $][$
      @select $_ @case decay $]
   subroutine read_slha_block_[$ $_ $](line, ierr)
   !  This subroutine reads the 'branching ratios' of
   !  the slha file: these are just thrown away
      implicit none
      character(len=*), intent(in) :: line
      integer, intent(out), optional :: ierr
      integer :: idx1,idx2,ioerr,nda
      real(ki) :: value
      read(line,*,iostat=ioerr) value, nda, idx1, idx2
      if (ioerr .ne. 0) then
         if (present(ierr)) ierr = 1
         return
      end if
      if (present(ierr)) ierr = 0
   end subroutine read_slha_block_[$ $_ $]
   subroutine read_slha_line_[$ $_ $](line, ierr)
      implicit none
      character(len=*), intent(in) :: line
      integer, intent(out), optional :: ierr[$
      @for slha_entries index=idx1$][$
         @if is_first $]
      integer :: idx1,ioerr
      real(ki) :: value

      read(line,*,iostat=ioerr) idx1, value
      if (ioerr .ne. 0) then
         if (present(ierr)) ierr = 1
         return
      end if
      select case(idx1)[$
         @end @if is_first $]
      case([$ idx1 $])
         [$ $_ $] = value[$
         @if is_last $]
      end select[$
         @end @if is_last $][$
      @end @for$]
      if (present(ierr)) ierr = 0
   end subroutine read_slha_line_[$ $_ $][$
   @else $]
   subroutine read_slha_block_[$ $_ $](line, ierr)
      implicit none
      character(len=*), intent(in) :: line
      integer, intent(out), optional :: ierr[$
      @for slha_entries index=idx1$][$
         @if is_first $]
      integer :: idx1,ioerr
      real(ki) :: value

      read(line,*,iostat=ioerr) idx1, value
      if (ioerr .ne. 0) then
         if (present(ierr)) ierr = 1
         return
      end if
      select case(idx1)[$
         @end @if is_first $]
      case([$ idx1 $])
         [$ $_ $] = value[$
         @if is_last $]
      end select[$
         @end @if is_last $][$
      @end @for$]
      if (present(ierr)) ierr = 0
   end subroutine read_slha_block_[$ $_ $][$
   @end @select $][$
   @end @for $][$
   @for slha_blocks lower dimension=2 $]
   subroutine read_slha_block_[$ $_ $](line, ierr)
      implicit none
      character(len=*), intent(in) :: line
      integer, intent(out), optional :: ierr[$
      @for slha_entries index=idx1$][$
         @if is_first $]
      integer :: idx1, idx2, ioerr
      real(ki) :: value

      read(line,*,iostat=ioerr) idx1, idx2, value
      if (ioerr .ne. 0) then
         if (present(ierr)) ierr = 1
         return
      end if

      select case(idx1)[$
         @end @if is_first $]
      case([$ idx1 $])
         select case(idx2)[$
         @for slha_entries index=idx2 $]
         case([$ idx2 $])
            [$ $_ $] = value[$
         @end @for $]
         end select[$
         @if is_last $]
      end select[$
         @end @if is_last $][$
      @end @for$]
      if (present(ierr)) ierr = 0
   end subroutine read_slha_block_[$ $_ $][$
   @end @for $]
!---#] SLHA READER:[$
@end @if has_slha_locations $]
!---#[ subroutine set_parameter
   recursive subroutine set_parameter(name, re, im, ierr)
      implicit none
      real(ki), parameter :: pi = 3.14159265358979323846264&
     &3383279502884197169399375105820974944592307816406286209_ki
      character(len=*), intent(in) :: name
      real(ki), intent(in) :: re, im
      integer, intent(out) :: ierr

      integer :: err, pdg, nidx, idx
      complex(ki) :: tmp

      logical :: must_be_real
      must_be_real = .false.
      ierr = 1 ! OK
[$
@select modeltype @case sm smdiag smehc sm_complex smdiag_complex smehc $][$
@if gs_not_one $]
      if (name.eq."aS" .or. name.eq."alphaS" .or. name.eq."alphas") then
         gs = 2.0_ki*sqrt(pi)*sqrt(re)
         must_be_real = .true.
      else[$@else$]
      [$
@end @if$][$@if alpha_not_one$]if (name.eq."alphaEW" .or. name.eq."alpha") then
         alpha = re
         must_be_real = .true.[$@end @if$][$
@select modeltype @case sm sm_complex smehc$][$
@if eval ( gs_not_one .or. alpha_not_one ) $]
      else[$@else$]
      [$@end @if$]if (name.eq."VV12") then
         call set_parameter("VUD",re,im,ierr)
         return
      elseif (name.eq."VV23") then
         call set_parameter("VUS",re,im,ierr)
         return
      elseif (name.eq."VV25") then
         call set_parameter("VUB",re,im,ierr)
         return
      elseif (name.eq."VV14") then
         call set_parameter("VCB",re,im,ierr)
         return
      elseif (name.eq."VV34") then
         call set_parameter("VCS",re,im,ierr)
         return
     elseif (name.eq."VV35") then
         call set_parameter("VCS",re,im,ierr)
         return
     elseif (name.eq."VV16") then
         call set_parameter("VTD",re,im,ierr)
         return
     elseif (name.eq."VV36") then
         call set_parameter("VTS",re,im,ierr)
         return
     elseif (name.eq."VV56") then
         call set_parameter("VTB",re,im,ierr)
         return[$
@end @select $]
      elseif (name.eq."Gf") then
         call set_parameter("GF",re,im,ierr)
         return
      elseif (name.eq."sw2") then
         tmp=sqrt(cmplx(re,im,ki))
         call set_parameter("sw",real(tmp,ki),aimag(tmp),ierr)
         return
     else[$
@end @select $]if (name(1:5).eq."mass(" .and. len_trim(name)>=7) then
         idx = scan(name,")",.false.)
         if (idx.eq.0) then
            idx=len_trim(name)+1
         end if
         read(name(6:idx-1),*, iostat=err) pdg
         if (err.ne.0) then
            ierr=0 !FAIL
            return
         end if
         must_be_real = .true.
         select case(pdg)[$
@if has_slha_locations $][$
   @for slha_blocks lower $][$
      @select $_ @case masses $][$
         @for slha_entries $]
            case([$index$])
               [$ $_ $] = re[$
         @end @for $][$
      @end @select $][$
   @end @for $][$
@end @if $]
            case default
               write(*,'(A20,1x,I10)') "Cannot set mass for PDG code:", pdg
               ierr = 0
               return
            end select
     elseif (len_trim(name)>=8 .and. name(1:6).eq."width(") then
         idx = scan(name,")",.false.)
         if (idx.eq.0) then
            idx=len_trim(name)+1
         end if
         read(name(7:idx-1),*, iostat=err) pdg
         if (err.ne.0) then
            ierr=0 !FAIL
            return
         end if
         must_be_real = .true.
         select case(pdg)[$
@if has_slha_locations $][$
   @for slha_blocks lower $][$
      @select $_ @case decay $][$
         @for slha_entries $]
            case([$index$])
               [$ $_ $] = re[$
         @end @for $][$
      @end @select $][$
   @end @for $][$
@end @if $]
            case default
               write(*,'(A20,1x,I10)') "Cannot set width for PDG code:", pdg
               ierr = 0 !FAIL
               return
            end select
      elseif (name .eq. "renormalisation") then
          if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
             renormalisation = int(re)
          else
             ierr=0 !FAIL
          end if
      elseif (name .eq. "nlo_prefactors") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            nlo_prefactors = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "deltaOS") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            deltaOS = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "reduction_interoperation") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            reduction_interoperation = int(re)
         else
            ierr=0 !FAIL
         end if[$
@if extension samurai $]
      elseif (name .eq. "samurai_scalar") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            samurai_scalar = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "samurai_verbosity") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            samurai_verbosity = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "samurai_test") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            samurai_test = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "samurai_istop") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            samurai_istop = int(re)
         else
            ierr=0 !FAIL
         end if
      elseif (name .eq. "samurai_group_numerators") then
         if ( real(int(re),ki) == re .and. im == 0.0_ki ) then
            samurai_group_numerators = (int(re).ne.0)
         else
            ierr=0 !FAIL
         end if[$
@end @if $]
     elseif (any(names .eq. name)) then
         do nidx=1,size(names)
            if (names(nidx) .eq. name) exit
         end do
         select case (nidx)[$
         @for parameters R C $]
         case([$index$])
            [$ $_ $] = [$
         @select type
         @case C$]cmplx(re, im, ki)[$
         @else $]re[$
         @end @select $][$@select type @case R$]
            must_be_real=.true.[$@end @select$][$
         @end @for $]
         end select
     else
         if (name(1:3) /= "mdl") then
            call set_parameter("mdl" // name(4:),re,im,ierr)
            return
         end if
         ierr = 0 !FAIL / UNKNOWN
     end if
     if (must_be_real .and. im /= 0.0_ki .and. ierr.eq.1) then
        ierr = 0 ! FAIL
     end if

[$ @if ewchoose $]
     if(any(ew_parameters .eq. name) .or. (name.eq."mass(23)") .or. &
        (name.eq."mass(24)"))  then
         do nidx=1,size(ew_parameters)
            if (ew_parameters(nidx) .eq. name) exit
         end do
         if(name.eq."mass(23)") then
            nidx=2
         elseif(name.eq."mass(24)") then
            nidx=1
         end if
         if (.not. btest(choosen_ew_parameters,nidx)) then
            choosen_ew_parameters_count = choosen_ew_parameters_count + 1
            choosen_ew_parameters = ibset(choosen_ew_parameters, nidx)
[$ ' python program to calculate numbers below:
 '   p=['mW','mZ','alpha','GF','sw','e']
 '   print sum([2**(p.index(i.strip())+1) for i in "GF,mW,mZ".split(",")])
 '   from itertools import combinations
 '   ([sum([2**(p.index(i.strip())+1) for i in j]) for j in combinations("GF,mW,mZ".split(","),2)]) $]
            if (choosen_ew_parameters_count == 1) then
               orig_ewchoice = ewchoice
               if(ewchoice > 0) then
                 select case(choosen_ew_parameters)
                      case(2) ! mW
                        if (ewchoice /= 1 .and. ewchoice /= 2 .and. &
                            &   ewchoice /= 6) then
                          ewchoice = 1
                        end if
                      case(4) ! mZ
                        if (ewchoice /= 1 .and. ewchoice /= 2 .and. &
                            &   ewchoice /= 6) then
                          ewchoice = 1
                        end if
                      case(8) ! alpha
                        if (ewchoice /= 2 .and. ewchoice /= 3 .and. &
                            &   ewchoice /= 4 .and. ewchoice /= 5) then
                          ewchoice = 2
                        end if
                      case(16) ! GF
                        if (ewchoice /= 1 .and. ewchoice /= 4 .and. &
                            &   ewchoice /= 8) then
                          ewchoice = 1
                        end if
                     case(32) ! sw
                        if (ewchoice /= 3 .and. ewchoice /= 4 .and. &
                             &   ewchoice /= 7 .and. ewchoice /= 8) then
                          ewchoice = 1
                        end if[$
@if e_not_one$]
                      case(64) ! e
                        if (ewchoice < 6) then
                           ewchoice = 6
                        end if[$
@end @if$]
                    end select
                end if
            elseif (choosen_ew_parameters_count == 2) then
                if (choosen_ew_parameters == 18 .or. choosen_ew_parameters == 20 &
                   & .or. choosen_ew_parameters == 6) then
                   ewchoice = 1
                elseif (choosen_ew_parameters == 10 .or. choosen_ew_parameters == 12) then
                   ewchoice = 2
                elseif (choosen_ew_parameters == 40 .or. choosen_ew_parameters == 36) then
                   ewchoice = 3
                elseif (choosen_ew_parameters == 24 .or. choosen_ew_parameters == 48) then
                   ewchoice = 4
                elseif (choosen_ew_parameters == 20) then
                   ewchoice = 5[$
@if e_not_one$]
                 elseif (choosen_ew_parameters == 66 .or. choosen_ew_parameters == 68) then
                   ewchoice = 6
                 elseif (choosen_ew_parameters == 96) then
                   ewchoice = 7
                 elseif (choosen_ew_parameters == 80) then
                   ewchoice = 8[$
@end @if$]
                 else
                 ewchoice = orig_ewchoice
                 write(*,'(A,1x,I2)') 'Unknown/Invalid EW scheme. Falling back to No.',&
                                     ewchoice
                 ierr = 0
                end if
            elseif (choosen_ew_parameters_count >= 4) then
                 write(*,'(A,A,A)') 'EW parameter "', name, '" is already determined.'
                 write(*,'(A)') 'New values are ignored.'
                 write(*,'(A17,1x,I3)') 'Current EW choice:', ewchoice
                 ierr = -1 ! IGNORE
            elseif(choosen_ew_parameters_count == 3) then
               select case(choosen_ew_parameters)
                case(22) ! GF,mW,mZ -> e,sw
                        ewchoice = 1
                case(14) ! alpha, mW, mZ  -> e,sw
                        ewchoice = 2
                case(44) ! alpha, sw, mZ -> e, mW
                        ewchoice = 3
                case(56) ! alpha, sw, GF ->  e, mW
                        ewchoice = 4
                case(28) ! alpha, GF, mZ ->  e, mW, sw
                        ewchoice = 5[$
@if e_not_one$]
                case(70) ! e, mW, mZ -> sw
                        ewchoice = 6
                case(100) ! e, sw, mZ -> mW
                        ewchoice = 7
                case(112) ! e, sw, GF -> mW, mZ
                        ewchoice = 8[$
@end @if$]
                case default
                 ewchoice = orig_ewchoice
                 write(*,'(A,1x,I2)') 'Unknown/Invalid EW scheme. Falling back to No.',&
                                     ewchoice
                 ierr = 0
               end select
            end if
         end if
     end if
[$
@end @if$]
     call init_functions()
      ! TODO init_color
   end subroutine
!---#] subroutine set_parameter
!---#[ subroutine init_functions:
   subroutine     init_functions()
      implicit none
      complex(ki), parameter :: i_ = (0.0_ki, 1.0_ki)
      real(ki), parameter :: pi = 3.14159265358979323846264&
     &3383279502884197169399375105820974944592307816406286209_ki[$
@for floats $]
     real(ki), parameter :: [$ $_ $] = [$ value convert=float format=%24.15f_ki $][$
@end @for $][$
@select modeltype @case sm smdiag sm_complex smdiag_complex smehc $][$
@if ewchoose $]
      call ewschemechoice(ewchoice)[$
@end @if $][$
@end @select $][$
@for functions_resolved_fortran $]
     [$ $_ $] = [$ expression $][$
@end @for$]
end subroutine init_functions
!---#] subroutine init_functions:
!---#[ utility functions for model initialization:
   pure function ifpos(x0, x1, x2)
      implicit none
      real(ki), intent(in) :: x0, x1, x2
      real(ki) :: ifpos

      if (x0 > 0.0_ki) then
         ifpos = x1
      else
         ifpos = x2
      endif
   end  function ifpos

   pure function sort4(m1, m2, m3, m4, n)
      implicit none
      real(ki), intent(in) :: m1, m2, m3, m4
      integer, intent(in) :: n
      real(ki) :: sort4

      real(ki), dimension(4) :: m
      logical :: f
      integer :: i
      real(ki) :: tmp

      m(1) = m1
      m(2) = m2
      m(3) = m3
      m(4) = m4

      ! Bubble Sort
      do
         f = .false.

         do i=1,3
            if (abs(m(i)) .gt. abs(m(i+1))) then
               tmp = m(i)
               m(i) = m(i+1)
               m(i+1) = tmp
               f = .true.
            end if
         end do

         if (.not. f) exit
      end do

      sort4 = m(n)
   end  function sort4
!---#] utility functions for model initialization:
[$
@select modeltype @case sm smdiag smehc $]
!---#[ EW scheme choice:[$
@if ewchoose $][$ @if
e_not_one $]
  subroutine ewschemechoice(ichoice)
  implicit none
  integer, intent(in) :: ichoice
  real(ki), parameter :: pi = 3.14159265358979323846264&
 &3383279502884197169399375105820974944592307816406286209_ki
  select case (ichoice)
        case (1)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
      ! GF, mW, sw --> e
        e = mW*sw*sqrt(8.0_ki*GF/sqrt(2.0_ki))
        case (2)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
        case (3)
        e = sqrt(4.0_ki*pi*alpha)
      ! sw, mZ --> mW
        mW = mZ*sqrt(1.0_ki-sw*sw)
        case (4)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! GF, sw, alpha --> mW
        mW = sqrt(alpha*pi/sqrt(2.0_ki)/GF) / sw
      ! mW, sw --> mZ
        mZ = mW / sqrt(1.0_ki-sw*sw)
        case(5)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! GF, mZ, alpha --> mW
        mW = sqrt(mZ*mZ/2.0_ki+sqrt(mZ*mZ*mZ*mZ/4.0_ki-pi*alpha*mZ*mZ/&
     & sqrt(2.0_ki)/GF))
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
        case(6)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
        case(7)
      ! mZ, sw --> mW
        mW = mZ*sqrt(1-sw*sw)
        case(8)
      ! e, sw, GF --> mW
        mW = e/2.0_ki/sw/sqrt(sqrt(2.0_ki)*GF)
      ! mW, sw --> mZ
        mZ = mW / sqrt(1.0_ki-sw*sw)
  end select
  end subroutine[$
@else $]
  subroutine ewschemechoice(ichoice)
  implicit none
  integer, intent(in) :: ichoice
  real(ki), parameter :: pi = 3.14159265358979323846264&
 &3383279502884197169399375105820974944592307816406286209_ki
  ! e is algebraically set to one, do not calculate it here
  select case (ichoice)
        case (1)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
        case (2)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
        case (3)
      ! sw, mZ --> mW
        mW = mZ*sqrt(1.0_ki-sw*sw)
        case (4)
      ! GF, sw, alpha --> mW
        mW = sqrt(alpha*pi/sqrt(2.0_ki)/GF) / sw
      ! mW, sw --> mZ
        mZ = mW / sqrt(1.0_ki-sw*sw)
        case(5)
      ! GF, mZ, alpha --> mW
      mW = sqrt(mZ*mZ/2.0_ki+sqrt(mZ*mZ*mZ*mZ/4.0_ki-pi*alpha*mZ*mZ/&
     & sqrt(2.0_ki)/GF))
      ! mW, mZ --> sw
      sw = sqrt(1.0_ki-mW*mW/mZ/mZ)
  end select
  end subroutine[$
@end @if$][$
@end @if$]
!---#] EW scheme choice:
[$@end @select$]
[$@select modeltype @case sm_complex smdiag_complex $]
!---#[ EW scheme choice:[$
@if ewchoose $][$ @if
e_not_one $]
  subroutine ewschemechoice(ichoice)
  implicit none
  integer, intent(in) :: ichoice
  real(ki), parameter :: pi = 3.14159265358979323846264&
 &3383279502884197169399375105820974944592307816406286209_ki
  complex(ki), parameter :: i_ = (0.0_ki, 1.0_ki)
  select case (ichoice)
        case (1)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
      ! GF, mW, sw --> e
        e = sqrt(mW*mW-i_*mW*wW)*sw*sqrt(8.0_ki*GF/sqrt(2.0_ki))
        case (2)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
        case (3)
        e = sqrt(4.0_ki*pi*alpha)
      ! sw, mZ --> mW
        mW = sqrt(mZ*mZ-i_*mZ*wZ)*sqrt(1.0_ki-sw*sw)
        case (4)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! GF, sw, alpha --> mW
        mW = sqrt(alpha*pi/sqrt(2.0_ki)/GF) / sw
      ! mW, sw --> mZ
        mZ = sqrt(mW*mW-i_*mW*wW) / sqrt(1.0_ki-sw*sw)
        case (5)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
        case (6)
      ! mZ, sw --> mW
        mW = sqrt(mZ*mZ-i_*mZ*wZ)*sqrt(1.0_ki-sw*sw)
        case(7)
      ! e, sw, GF --> mW
        mW = e/2.0_ki/sw/sqrt(sqrt(2.0_ki)*GF)
      ! mW, sw --> mZ
        mZ = sqrt(mW*mW-i_*mW*wW) / sqrt(1.0_ki-sw*sw)
        case(8)
      ! alpha --> e
        e = sqrt(4.0_ki*pi*alpha)
      ! GF, mZ, alpha --> mW
      mW = sqrt((mZ*mZ-i_*mZ*wZ)/2.0_ki+sqrt((mZ*mZ-i_*mZ*wZ)**2/4.0_ki-pi*alpha*(mZ*mZ-i_*mZ*wZ)/&
     & sqrt(2.0_ki)/GF))
      ! mW, mZ --> sw
      sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
!        case default
  end select
  end subroutine[$
@else $]
  subroutine ewschemechoice(ichoice)
  implicit none
  integer, intent(in) :: ichoice
  real(ki), parameter :: pi = 3.14159265358979323846264&
 &3383279502884197169399375105820974944592307816406286209_ki
  complex(ki), parameter :: i_ = (0.0_ki, 1.0_ki)
  ! e is algebraically set to one, do not calculate it here
  select case (ichoice)
        case (1)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
        case (2)
      ! mW, mZ --> sw
        sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
        case (3)
      ! sw, mZ --> mW
        mW = sqrt(mZ*mZ-i_*mZ*wZ)*sqrt(1.0_ki-sw*sw)
        case (4)
      ! GF, sw, alpha --> mW
        mW = sqrt(alpha*pi/sqrt(2.0_ki)/GF) / sw
      ! mW, sw --> mZ
        mZ = sqrt(mW*mW-i_*mW*wW) / sqrt(1.0_ki-sw*sw)
        case(5)
      ! GF, mZ, alpha --> mW
      mW = sqrt((mZ*mZ-i_*mZ*wZ)/2.0_ki+sqrt((mZ*mZ-i_*mZ*wZ)**2/4.0_ki-pi*alpha*(mZ*mZ-i_*mZ*wZ)/&
     & sqrt(2.0_ki)/GF))
      ! mW, mZ --> sw
      sw = sqrt(1.0_ki-(mW*mW-i_*mW*wW)/(mZ*mZ-i_*mZ*wZ))
  end select
  end subroutine[$
@end @if$][$
@end @if$]
!---#] EW scheme choice:
[$@end @select$]

end module olp_model
