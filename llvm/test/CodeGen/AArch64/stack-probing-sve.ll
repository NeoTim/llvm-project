; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64 < %s -verify-machineinstrs | FileCheck %s
; RUN: llc -mtriple=aarch64 < %s -verify-machineinstrs -global-isel -global-isel-abort=2 | FileCheck %s

; Test prolog sequences for stack probing when SVE objects are involved.

; The space for SVE objects needs probing in the general case, because
; the stack adjustment may happen to be too big (i.e. greater than the
; probe size) to allocate with a single `addvl`.
; When we do know that the stack adjustment cannot exceed the probe size
; we can avoid emitting a probe loop and emit a simple `addvl; str`
; sequence instead.

define void @sve_1_vector(ptr %out) #0 {
; CHECK-LABEL: sve_1_vector:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 8 * VG
; CHECK-NEXT:    addvl sp, sp, #1
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 4 x float>, align 16
  ret void
}

; As above, but with 4 SVE vectors of stack space.
define void @sve_4_vector(ptr %out) #0 {
; CHECK-LABEL: sve_4_vector:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-4
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x20, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 32 * VG
; CHECK-NEXT:    addvl sp, sp, #4
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec1 = alloca <vscale x 4 x float>, align 16
  %vec2 = alloca <vscale x 4 x float>, align 16
  %vec3 = alloca <vscale x 4 x float>, align 16
  %vec4 = alloca <vscale x 4 x float>, align 16
  ret void
}

; As above, but with 16 SVE vectors of stack space.
; The stack adjustment is less than or equal to 16 x 256 = 4096, so
; we can allocate the locals at once.
define void @sve_16_vector(ptr %out) #0 {
; CHECK-LABEL: sve_16_vector:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-16
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x01, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 128 * VG
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    addvl sp, sp, #16
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec1 = alloca <vscale x 4 x float>, align 16
  %vec2 = alloca <vscale x 4 x float>, align 16
  %vec3 = alloca <vscale x 4 x float>, align 16
  %vec4 = alloca <vscale x 4 x float>, align 16
  %vec5 = alloca <vscale x 4 x float>, align 16
  %vec6 = alloca <vscale x 4 x float>, align 16
  %vec7 = alloca <vscale x 4 x float>, align 16
  %vec8 = alloca <vscale x 4 x float>, align 16
  %vec9 = alloca <vscale x 4 x float>, align 16
  %vec10 = alloca <vscale x 4 x float>, align 16
  %vec11 = alloca <vscale x 4 x float>, align 16
  %vec12 = alloca <vscale x 4 x float>, align 16
  %vec13 = alloca <vscale x 4 x float>, align 16
  %vec14 = alloca <vscale x 4 x float>, align 16
  %vec15 = alloca <vscale x 4 x float>, align 16
  %vec16 = alloca <vscale x 4 x float>, align 16
  ret void
}

; As above, but with 17 SVE vectors of stack space. Now we need
; a probing loops since stack adjustment may be greater than
; the probe size (17 x 256 = 4354 bytes)
; TODO: Allocating `k*16+r` SVE vectors can be unrolled into
; emiting the `k + r` sequences of `addvl sp, sp, #-N; str xzr, [sp]`
define void @sve_17_vector(ptr %out) #0 {
; CHECK-LABEL: sve_17_vector:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl x9, sp, #-17
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x88, 0x01, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 136 * VG
; CHECK-NEXT:  .LBB3_1: // %entry
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sub sp, sp, #1, lsl #12 // =4096
; CHECK-NEXT:    cmp sp, x9
; CHECK-NEXT:    b.le .LBB3_3
; CHECK-NEXT:  // %bb.2: // %entry
; CHECK-NEXT:    // in Loop: Header=BB3_1 Depth=1
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    b .LBB3_1
; CHECK-NEXT:  .LBB3_3: // %entry
; CHECK-NEXT:    mov sp, x9
; CHECK-NEXT:    ldr xzr, [sp]
; CHECK-NEXT:    .cfi_def_cfa_register wsp
; CHECK-NEXT:    addvl sp, sp, #17
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec1 = alloca <vscale x 4 x float>, align 16
  %vec2 = alloca <vscale x 4 x float>, align 16
  %vec3 = alloca <vscale x 4 x float>, align 16
  %vec4 = alloca <vscale x 4 x float>, align 16
  %vec5 = alloca <vscale x 4 x float>, align 16
  %vec6 = alloca <vscale x 4 x float>, align 16
  %vec7 = alloca <vscale x 4 x float>, align 16
  %vec8 = alloca <vscale x 4 x float>, align 16
  %vec9 = alloca <vscale x 4 x float>, align 16
  %vec10 = alloca <vscale x 4 x float>, align 16
  %vec11 = alloca <vscale x 4 x float>, align 16
  %vec12 = alloca <vscale x 4 x float>, align 16
  %vec13 = alloca <vscale x 4 x float>, align 16
  %vec14 = alloca <vscale x 4 x float>, align 16
  %vec15 = alloca <vscale x 4 x float>, align 16
  %vec16 = alloca <vscale x 4 x float>, align 16
  %vec17 = alloca <vscale x 4 x float>, align 16
  ret void
}

; Space for callee-saved SVE register is allocated similarly to allocating
; space for SVE locals. When we know the stack adjustment cannot exceed the
; probe size we can skip the explict probe, since saving SVE registers serves
; as an implicit probe.
define void @sve_1v_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_1v_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 8 * VG
; CHECK-NEXT:    str z8, [sp] // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_escape 0x10, 0x48, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x78, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d8 @ cfa - 16 - 8 * VG
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr z8, [sp] // 16-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #1
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    .cfi_restore z8
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{z8}" ()
  ret void
}

define void @sve_4v_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_4v_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-4
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x20, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 32 * VG
; CHECK-NEXT:    str z11, [sp] // 16-byte Folded Spill
; CHECK-NEXT:    str z10, [sp, #1, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z9, [sp, #2, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z8, [sp, #3, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_escape 0x10, 0x48, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x78, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d8 @ cfa - 16 - 8 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x49, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x70, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d9 @ cfa - 16 - 16 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4a, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x68, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d10 @ cfa - 16 - 24 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4b, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x60, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d11 @ cfa - 16 - 32 * VG
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr z11, [sp] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z10, [sp, #1, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z9, [sp, #2, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z8, [sp, #3, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #4
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    .cfi_restore z8
; CHECK-NEXT:    .cfi_restore z9
; CHECK-NEXT:    .cfi_restore z10
; CHECK-NEXT:    .cfi_restore z11
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{z8},~{z9},~{z10},~{z11}" ()
  ret void
}

define void @sve_16v_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_16v_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-16
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x01, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 128 * VG
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    str z23, [sp] // 16-byte Folded Spill
; CHECK-NEXT:    str z22, [sp, #1, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z21, [sp, #2, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z20, [sp, #3, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z19, [sp, #4, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z18, [sp, #5, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z17, [sp, #6, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z16, [sp, #7, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z15, [sp, #8, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z14, [sp, #9, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z13, [sp, #10, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z12, [sp, #11, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z11, [sp, #12, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z10, [sp, #13, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z9, [sp, #14, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z8, [sp, #15, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_escape 0x10, 0x48, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x78, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d8 @ cfa - 16 - 8 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x49, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x70, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d9 @ cfa - 16 - 16 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4a, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x68, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d10 @ cfa - 16 - 24 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4b, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x60, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d11 @ cfa - 16 - 32 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4c, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x58, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d12 @ cfa - 16 - 40 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4d, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x50, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d13 @ cfa - 16 - 48 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4e, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x48, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d14 @ cfa - 16 - 56 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4f, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x40, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d15 @ cfa - 16 - 64 * VG
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr z23, [sp] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z22, [sp, #1, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z21, [sp, #2, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z20, [sp, #3, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z19, [sp, #4, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z18, [sp, #5, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z17, [sp, #6, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z16, [sp, #7, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z15, [sp, #8, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z14, [sp, #9, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z13, [sp, #10, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z12, [sp, #11, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z11, [sp, #12, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z10, [sp, #13, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z9, [sp, #14, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z8, [sp, #15, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #16
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    .cfi_restore z8
; CHECK-NEXT:    .cfi_restore z9
; CHECK-NEXT:    .cfi_restore z10
; CHECK-NEXT:    .cfi_restore z11
; CHECK-NEXT:    .cfi_restore z12
; CHECK-NEXT:    .cfi_restore z13
; CHECK-NEXT:    .cfi_restore z14
; CHECK-NEXT:    .cfi_restore z15
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{z8},~{z9},~{z10},~{z11},~{z12},~{z13},~{z14},~{z15},~{z16},~{z17},~{z18},~{z19},~{z20},~{z21},~{z22},~{z23}" ()
  ret void
}

define void @sve_1p_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_1p_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 8 * VG
; CHECK-NEXT:    str p8, [sp, #7, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr p8, [sp, #7, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #1
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{p8}" ()
  ret void
}

define void @sve_4p_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_4p_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 8 * VG
; CHECK-NEXT:    str p11, [sp, #4, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    str p10, [sp, #5, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    str p9, [sp, #6, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    str p8, [sp, #7, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr p11, [sp, #4, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    ldr p10, [sp, #5, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    ldr p9, [sp, #6, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    ldr p8, [sp, #7, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #1
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{p8},~{p9},~{p10},~{p11}" ()
  ret void
}

define void @sve_16v_1p_csr(<vscale x 4 x float> %a) #0 {
; CHECK-LABEL: sve_16v_1p_csr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl x9, sp, #-17
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x88, 0x01, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 136 * VG
; CHECK-NEXT:  .LBB9_1: // %entry
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sub sp, sp, #1, lsl #12 // =4096
; CHECK-NEXT:    cmp sp, x9
; CHECK-NEXT:    b.le .LBB9_3
; CHECK-NEXT:  // %bb.2: // %entry
; CHECK-NEXT:    // in Loop: Header=BB9_1 Depth=1
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    b .LBB9_1
; CHECK-NEXT:  .LBB9_3: // %entry
; CHECK-NEXT:    mov sp, x9
; CHECK-NEXT:    ldr xzr, [sp]
; CHECK-NEXT:    .cfi_def_cfa_register wsp
; CHECK-NEXT:    str p8, [sp, #7, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    str z23, [sp, #1, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z22, [sp, #2, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z21, [sp, #3, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z20, [sp, #4, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z19, [sp, #5, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z18, [sp, #6, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z17, [sp, #7, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z16, [sp, #8, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z15, [sp, #9, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z14, [sp, #10, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z13, [sp, #11, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z12, [sp, #12, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z11, [sp, #13, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z10, [sp, #14, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z9, [sp, #15, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z8, [sp, #16, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_escape 0x10, 0x48, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x78, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d8 @ cfa - 16 - 8 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x49, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x70, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d9 @ cfa - 16 - 16 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4a, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x68, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d10 @ cfa - 16 - 24 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4b, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x60, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d11 @ cfa - 16 - 32 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4c, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x58, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d12 @ cfa - 16 - 40 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4d, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x50, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d13 @ cfa - 16 - 48 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4e, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x48, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d14 @ cfa - 16 - 56 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4f, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x40, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d15 @ cfa - 16 - 64 * VG
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    ldr z23, [sp, #1, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z22, [sp, #2, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z21, [sp, #3, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z20, [sp, #4, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z19, [sp, #5, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z18, [sp, #6, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z17, [sp, #7, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z16, [sp, #8, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z15, [sp, #9, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z14, [sp, #10, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z13, [sp, #11, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z12, [sp, #12, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z11, [sp, #13, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z10, [sp, #14, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z9, [sp, #15, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z8, [sp, #16, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr p8, [sp, #7, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #17
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    .cfi_restore z8
; CHECK-NEXT:    .cfi_restore z9
; CHECK-NEXT:    .cfi_restore z10
; CHECK-NEXT:    .cfi_restore z11
; CHECK-NEXT:    .cfi_restore z12
; CHECK-NEXT:    .cfi_restore z13
; CHECK-NEXT:    .cfi_restore z14
; CHECK-NEXT:    .cfi_restore z15
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{p8},~{z8},~{z9},~{z10},~{z11},~{z12},~{z13},~{z14},~{z15},~{z16},~{z17},~{z18},~{z19},~{z20},~{z21},~{z22},~{z23}" ()
  ret void
}

; A SVE vector and a 16-byte fixed size object.
define void @sve_1_vector_16_arr(ptr %out) #0 {
; CHECK-LABEL: sve_1_vector_16_arr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    sub sp, sp, #16
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    addvl sp, sp, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x20, 0x22, 0x11, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 32 + 8 * VG
; CHECK-NEXT:    addvl sp, sp, #1
; CHECK-NEXT:    .cfi_def_cfa wsp, 32
; CHECK-NEXT:    add sp, sp, #16
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 4 x float>, align 16
  %arr = alloca i8, i64 16, align 1
  ret void
}

; A large SVE stack object and a large stack slot, both of which need probing.
; TODO: This could be optimised by combining the fixed-size offset into the
; loop.
define void @sve_1_vector_4096_arr(ptr %out) #0 {
; CHECK-LABEL: sve_1_vector_4096_arr:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    sub x9, sp, #3, lsl #12 // =12288
; CHECK-NEXT:    .cfi_def_cfa w9, 12304
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0f, 0x79, 0x00, 0x11, 0x90, 0xe0, 0x00, 0x22, 0x11, 0x80, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 12304 + 256 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0f, 0x79, 0x00, 0x11, 0x90, 0xe0, 0x00, 0x22, 0x11, 0x80, 0x04, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 12304 + 512 * VG
; CHECK-NEXT:  .LBB11_1: // %entry
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sub sp, sp, #1, lsl #12 // =4096
; CHECK-NEXT:    cmp sp, x9
; CHECK-NEXT:    b.le .LBB11_3
; CHECK-NEXT:  // %bb.2: // %entry
; CHECK-NEXT:    // in Loop: Header=BB11_1 Depth=1
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    b .LBB11_1
; CHECK-NEXT:  .LBB11_3: // %entry
; CHECK-NEXT:    mov sp, x9
; CHECK-NEXT:    ldr xzr, [sp]
; CHECK-NEXT:    .cfi_def_cfa_register wsp
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0f, 0x8f, 0x00, 0x11, 0x90, 0xe0, 0x00, 0x22, 0x11, 0x88, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 12304 + 264 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0e, 0x8f, 0x00, 0x11, 0x90, 0xe0, 0x00, 0x22, 0x11, 0x10, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 12304 + 16 * VG
; CHECK-NEXT:    addvl sp, sp, #2
; CHECK-NEXT:    .cfi_def_cfa wsp, 12304
; CHECK-NEXT:    add sp, sp, #3, lsl #12 // =12288
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 256 x float>, align 16
  %arr = alloca i8, i64 12288, align 1
  ret void
}

; Not tested: SVE stack objects with alignment >16 bytes, which isn't currently
; supported even without stack-probing.

; An SVE vector, and a 16-byte fixed size object, which
; has a large alignment requirement.
define void @sve_1_vector_16_arr_align_8192(ptr %out) #0 {
; CHECK-LABEL: sve_1_vector_16_arr_align_8192:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    stp x29, x30, [sp, #-16]! // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    mov x29, sp
; CHECK-NEXT:    .cfi_def_cfa w29, 16
; CHECK-NEXT:    .cfi_offset w30, -8
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    sub x9, sp, #1, lsl #12 // =4096
; CHECK-NEXT:    sub x9, x9, #4080
; CHECK-NEXT:    addvl x9, x9, #-1
; CHECK-NEXT:    and x9, x9, #0xffffffffffffe000
; CHECK-NEXT:  .LBB12_1: // %entry
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sub sp, sp, #1, lsl #12 // =4096
; CHECK-NEXT:    cmp sp, x9
; CHECK-NEXT:    b.le .LBB12_3
; CHECK-NEXT:  // %bb.2: // %entry
; CHECK-NEXT:    // in Loop: Header=BB12_1 Depth=1
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    b .LBB12_1
; CHECK-NEXT:  .LBB12_3: // %entry
; CHECK-NEXT:    mov sp, x9
; CHECK-NEXT:    ldr xzr, [sp]
; CHECK-NEXT:    mov sp, x29
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldp x29, x30, [sp], #16 // 16-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w30
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 4 x float>, align 16
  %arr = alloca i8, i64 16, align 8192
  ret void
}

; With 64k guard pages, we can allocate bigger SVE space without a probing loop.
define void @sve_1024_64k_guard(ptr %out) #0 "stack-probe-size"="65536" {
; CHECK-LABEL: sve_1024_64k_guard:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 256 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x04, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 512 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x06, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 768 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1024 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0a, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1280 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0c, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1536 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0e, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1792 * VG
; CHECK-NEXT:    addvl sp, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x10, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 2048 * VG
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x88, 0x0e, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1800 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x90, 0x0c, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1552 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x98, 0x0a, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1304 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xa0, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1056 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xa8, 0x06, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 808 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xb0, 0x04, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 560 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xb8, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 312 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xc0, 0x00, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 64 * VG
; CHECK-NEXT:    addvl sp, sp, #8
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 1024 x float>, align 16
  ret void
}

define void @sve_1028_64k_guard(ptr %out) #0 "stack-probe-size"="65536" {
; CHECK-LABEL: sve_1028_64k_guard:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl x9, sp, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 256 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x04, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 512 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x06, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 768 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 1024 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0a, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 1280 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0c, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 1536 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x0e, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 1792 * VG
; CHECK-NEXT:    addvl x9, x9, #-32
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x80, 0x10, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 2048 * VG
; CHECK-NEXT:    addvl x9, x9, #-1
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x79, 0x00, 0x11, 0x10, 0x22, 0x11, 0x88, 0x10, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $x9 + 16 + 2056 * VG
; CHECK-NEXT:  .LBB14_1: // %entry
; CHECK-NEXT:    // =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    sub sp, sp, #16, lsl #12 // =65536
; CHECK-NEXT:    cmp sp, x9
; CHECK-NEXT:    b.le .LBB14_3
; CHECK-NEXT:  // %bb.2: // %entry
; CHECK-NEXT:    // in Loop: Header=BB14_1 Depth=1
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    b .LBB14_1
; CHECK-NEXT:  .LBB14_3: // %entry
; CHECK-NEXT:    mov sp, x9
; CHECK-NEXT:    ldr xzr, [sp]
; CHECK-NEXT:    .cfi_def_cfa_register wsp
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x90, 0x0e, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1808 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x98, 0x0c, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1560 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xa0, 0x0a, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1312 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xa8, 0x08, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 1064 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xb0, 0x06, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 816 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xb8, 0x04, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 568 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xc0, 0x02, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 320 * VG
; CHECK-NEXT:    addvl sp, sp, #31
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xc8, 0x00, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 72 * VG
; CHECK-NEXT:    addvl sp, sp, #9
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec = alloca <vscale x 1024 x float>, align 16
  %vec1 = alloca <vscale x 4 x float>, align 16
  ret void
}

; With 5 SVE vectors of stack space the unprobed area
; at the top of the stack can exceed 1024 bytes (5 x 256 == 1280),
; hence we need to issue a probe.
define void @sve_5_vector(ptr %out) #0 {
; CHECK-LABEL: sve_5_vector:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-5
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x28, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 40 * VG
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    addvl sp, sp, #5
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  %vec1 = alloca <vscale x 4 x float>, align 16
  %vec2 = alloca <vscale x 4 x float>, align 16
  %vec3 = alloca <vscale x 4 x float>, align 16
  %vec4 = alloca <vscale x 4 x float>, align 16
  %vec5 = alloca <vscale x 4 x float>, align 16
  ret void
}

; Test with a 14 scalable bytes (so up to 14 * 16 = 224) of unprobed
; are bellow the save location of `p9`.
define void @sve_unprobed_area(<vscale x 4 x float> %a, i32 %n) #0 {
; CHECK-LABEL: sve_unprobed_area:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    str x29, [sp, #-16]! // 8-byte Folded Spill
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset w29, -16
; CHECK-NEXT:    addvl sp, sp, #-4
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x20, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 32 * VG
; CHECK-NEXT:    str xzr, [sp]
; CHECK-NEXT:    str p9, [sp, #7, mul vl] // 2-byte Folded Spill
; CHECK-NEXT:    str z10, [sp, #1, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z9, [sp, #2, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    str z8, [sp, #3, mul vl] // 16-byte Folded Spill
; CHECK-NEXT:    .cfi_escape 0x10, 0x48, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x78, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d8 @ cfa - 16 - 8 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x49, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x70, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d9 @ cfa - 16 - 16 * VG
; CHECK-NEXT:    .cfi_escape 0x10, 0x4a, 0x0a, 0x11, 0x70, 0x22, 0x11, 0x68, 0x92, 0x2e, 0x00, 0x1e, 0x22 // $d10 @ cfa - 16 - 24 * VG
; CHECK-NEXT:    addvl sp, sp, #-4
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0d, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0xc0, 0x00, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 64 * VG
; CHECK-NEXT:    //APP
; CHECK-NEXT:    //NO_APP
; CHECK-NEXT:    addvl sp, sp, #4
; CHECK-NEXT:    .cfi_escape 0x0f, 0x0c, 0x8f, 0x00, 0x11, 0x10, 0x22, 0x11, 0x20, 0x92, 0x2e, 0x00, 0x1e, 0x22 // sp + 16 + 32 * VG
; CHECK-NEXT:    ldr z10, [sp, #1, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z9, [sp, #2, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr z8, [sp, #3, mul vl] // 16-byte Folded Reload
; CHECK-NEXT:    ldr p9, [sp, #7, mul vl] // 2-byte Folded Reload
; CHECK-NEXT:    addvl sp, sp, #4
; CHECK-NEXT:    .cfi_def_cfa wsp, 16
; CHECK-NEXT:    .cfi_restore z8
; CHECK-NEXT:    .cfi_restore z9
; CHECK-NEXT:    .cfi_restore z10
; CHECK-NEXT:    ldr x29, [sp], #16 // 8-byte Folded Reload
; CHECK-NEXT:    .cfi_def_cfa_offset 0
; CHECK-NEXT:    .cfi_restore w29
; CHECK-NEXT:    ret
entry:
  call void asm sideeffect "", "~{z8},~{z9},~{z10},~{p9}" ()

  %v0 = alloca <vscale x 4 x float>, align 16
  %v1 = alloca <vscale x 4 x float>, align 16
  %v2 = alloca <vscale x 4 x float>, align 16
  %v3 = alloca <vscale x 4 x float>, align 16

  ret void
}

attributes #0 = { uwtable(async) "probe-stack"="inline-asm" "frame-pointer"="none" "target-features"="+sve" }