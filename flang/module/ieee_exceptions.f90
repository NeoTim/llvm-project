!===-- module/ieee_exceptions.f90 ------------------------------------------===!
!
! Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
! See https://llvm.org/LICENSE.txt for license information.
! SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
!
!===------------------------------------------------------------------------===!

module ieee_exceptions
  use __fortran_ieee_exceptions

  implicit none

  ! Because this MODULE simply re-exports an internal MODULE file,
  ! we do not use PRIVATE in here.
end module ieee_exceptions
