program test
use udene_config, only: ki, debug_lo_diagrams, debug_nlo_diagrams
use udene_matrix, only: initgolem, exitgolem
use udene_kinematics, only: inspect_kinematics, init_event
implicit none

! unit of the log file
integer, parameter :: logf = 27
integer, parameter :: golemlogf = 19

integer, dimension(2) :: channels
integer :: ic, ch

double precision, parameter :: eps = 1.0d-4

logical :: success

real(ki), dimension(4, 4) :: vecs
real(ki) :: scale2

double precision, dimension(0:3) :: golem_amp, ref_amp, diff

channels(1) = logf
channels(2) = 6

open(file="test.log", unit=logf)
success = .true.

if (debug_lo_diagrams .or. debug_nlo_diagrams) then
   open(file="golem.log", unit=golemlogf)
end if

call setup_parameters()
call initgolem()

call load_reference_kinematics(vecs, scale2)

call init_event(vecs)
call inspect_kinematics(logf)

call compute_golem_result(vecs, scale2, golem_amp)
call compute_reference_result(vecs, scale2, ref_amp)

diff = abs(rel_diff(golem_amp, ref_amp))

if (diff(0) .gt. eps) then
   write(unit=logf,fmt="(A3,1x,A40)") "==>", &
   & "Comparison of LO failed!"
   write(unit=logf,fmt="(A10,1x,E10.4)") "DIFFERENCE:", diff(0)
   success = .false.
end if

if (diff(1) .gt. eps) then
   write(unit=logf,fmt="(A3,1x,A40)") "==>", &
   & "Comparison of NLO/finite part failed!"
   write(unit=logf,fmt="(A10,1x,E10.4)") "DIFFERENCE:", diff(1)
   success = .false.
end if

if (diff(2) .gt. eps) then
   write(unit=logf,fmt="(A3,1x,A40)") "==>", &
   & "Comparison of NLO/single pole failed!"
   write(unit=logf,fmt="(A10,1x,E10.4)") "DIFFERENCE:", diff(2)
   success = .false.
end if

if (diff(3) .gt. eps) then
   write(unit=logf,fmt="(A3,1x,A30)") "==>", &
   & "Comparison of NLO/double pole failed!"
   write(unit=logf,fmt="(A10,1x,E10.4)") "DIFFERENCE:", diff(3)
   success = .false.
end if

if (success) then
   write(unit=logf,fmt="(A15)") "@@@ SUCCESS @@@"
else
   write(unit=logf,fmt="(A15)") "@@@ FAILURE @@@"
end if

close(unit=logf)

if (debug_lo_diagrams .or. debug_nlo_diagrams) then
   close(unit=golemlogf)
end if

call exitgolem()

contains

pure subroutine load_reference_kinematics(vecs, scale2)
   use udene_kinematics, only: adjust_kinematics
   implicit none
   real(ki), dimension(4, 4), intent(out) :: vecs
   real(ki), intent(out) :: scale2

   ! This kinematics was (more or less) specified in arXiv:1103.0621v1
   vecs(1,:) = (/100.0_ki, 0.0_ki, 0.0_ki,  100.0_ki/)
   vecs(2,:) = (/100.0_ki, 0.0_ki, 0.0_ki, -100.0_ki/)
   vecs(3,:) = (/100.0_ki, &
           75.54156653563304630982179114533834406514246608_ki, &
           30.24060342355887791344527191746042272831613275_ki, &
          -58.12897410002661096589234063883503782696653533_ki/)
   vecs(4,1) = 100.0_ki
   vecs(4,2:4) = -vecs(3,2:4)

   ! The given reference renormalisation scale is 80 GeV
   scale2 = 91.1876_ki ** 2
   !scale2 = 200.0_ki ** 2

end  subroutine load_reference_kinematics

subroutine     setup_parameters()
   use udene_config, only: renormalisation, convert_to_cdr
   !, use_sorted_sum, &
   !& samurai_test, samurai_verbosity, samurai_scalar
   use udene_model, only: mW, wW, sw, cw
   implicit none

   renormalisation = 0

   ! settings for samurai:
   ! verbosity: we keep it zero here unless you want some extra files.
   ! samurai_verbosity = 0
   ! samurai_scalar: 1=qcdloop, 2=OneLOop
   ! samurai_scalar = 2
   ! samurai_test: 1=(N=N test), 2=(local N=N test), 3=(power test)
   ! samurai_test = 1

   convert_to_cdr = .true.

   mW = 78.556162070987781_ki
   wW = 2.0850000000000000_ki
   sw = 0.49122870551584347_ki
   cw = sqrt(1.0_ki - sw*sw)
end subroutine setup_parameters

subroutine     compute_golem_result(vecs, scale2, amp)
   use udene_matrix, only: samplitude
   use udene_model, only: mW, wW, VUD
   implicit none
   ! The amplitude should be a homogeneous function
   ! in the energy dimension and scale like
   !     A(Q*E) = A(E)
   ! We use this fact as
   !  - an additional test for the amplitude
   !  - to enhance precision
   !real(ki), parameter :: Q = 180.0_ki
   real(ki), parameter :: Q = 1.0E+00

   real(ki), dimension(4, 4), intent(in) :: vecs
   real(ki), intent(in) :: scale2
   double precision, dimension(0:3), intent(out) :: amp

   real(ki), dimension(4, 4) :: xvecs
   real(ki) :: xscale2
   integer :: prec

   ! rescaling of all dimensionful quantities that enter the calculation
   xvecs = vecs / Q
   xscale2 = scale2 / Q ** 2
   mW = mW / Q
   wW = wW / Q

   call samplitude(xvecs, xscale2, amp, prec)
   amp(:) = amp(:) / abs(vud)**2
   mW = mW * Q
   wW = wW * Q

   do ic = 1, 2
      ch = channels(ic)
      write(ch,*) "GOSAM     AMP(0):       ", amp(0)
      write(ch,*) "GOSAM     AMP(1)/AMP(0):", amp(1)/amp(0)
      write(ch,*) "GOSAM     AMP(2)/AMP(0):", amp(2)/amp(0)
      write(ch,*) "GOSAM     AMP(3)/AMP(0):", amp(3)/amp(0)
   end do
end subroutine compute_golem_result

subroutine     compute_reference_result(vecs, scale2, amp)
   use udene_kinematics, only: dotproduct
   use udene_matrix, only: ir_subtraction
   use udene_model, only: mW, wW, sw, vud, NC
   implicit none

   real(ki), dimension(4, 4), intent(in) :: vecs
   real(ki), intent(in) :: scale2
   double precision, dimension(0:3), intent(out) :: amp

   double precision :: s, t, l, pi, CF
   double precision, dimension(2:3) :: irp

   pi = 4.0d0 * atan(1.0d0)
   CF = 0.5d0 * (NC*NC-1.0d0) / NC

   call ir_subtraction(vecs, scale2, irp)

   s =  2.0d0 * dotproduct(vecs(1,:), vecs(2,:))
   t = -2.0d0 * dotproduct(vecs(1,:), vecs(3,:))
   l = log(scale2/s)

   
   amp(0) = 1.0_ki / 4.0_ki / sw**4 / NC * &
          & t**2 / ((s-mW**2)**2 + (mW*wW)**2)

   amp(1) = CF*(-l**2-3.0d0*l+pi**2-8.0d0) * amp(0)
   amp(2) = CF * (-3.0d0 - 2.0d0*l) * amp(0)
   amp(3) = -2.0d0 * CF * amp(0)

   do ic = 1, 2
      ch = channels(ic)
      write(ch,*) "REFERENCE AMP(0):       ", amp(0)
      write(ch,*) "REFERENCE AMP(1)/AMP(0):", amp(1)/amp(0)
      write(ch,*) "REFERENCE AMP(2)/AMP(0):", amp(2)/amp(0)
      write(ch,*) "REFERENCE AMP(3)/AMP(0):", amp(3)/amp(0)
   end do
end subroutine compute_reference_result

pure elemental function rel_diff(a, b)
   implicit none

   double precision, intent(in) :: a, b
   double precision :: rel_diff

   if (a.eq.0.0d0 .and. b.eq.0.0d0) then
      rel_diff = 0.0d0
   else
      rel_diff = 2.0d0 * (a-b) / (abs(a)+abs(b))
   end if
end  function rel_diff

end program test
