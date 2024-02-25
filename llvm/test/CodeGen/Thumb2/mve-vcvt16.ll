; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve,+fullfp16 -verify-machineinstrs %s -o - | FileCheck %s --check-prefixes=CHECK,CHECK-MVE
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s --check-prefixes=CHECK,CHECK-MVEFP

define arm_aapcs_vfpcc <4 x float> @fpext_4(<4 x half> %src1) {
; CHECK-LABEL: fpext_4:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvtt.f32.f16 s3, s1
; CHECK-NEXT:    vcvtb.f32.f16 s2, s1
; CHECK-NEXT:    vcvtt.f32.f16 s1, s0
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    bx lr
entry:
  %out = fpext <4 x half> %src1 to <4 x float>
  ret <4 x float> %out
}

define arm_aapcs_vfpcc <8 x float> @fpext_8(<8 x half> %src1) {
; CHECK-LABEL: fpext_8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvtt.f32.f16 s11, s1
; CHECK-NEXT:    vcvtb.f32.f16 s10, s1
; CHECK-NEXT:    vcvtt.f32.f16 s9, s0
; CHECK-NEXT:    vcvtb.f32.f16 s8, s0
; CHECK-NEXT:    vcvtt.f32.f16 s7, s3
; CHECK-NEXT:    vcvtb.f32.f16 s6, s3
; CHECK-NEXT:    vcvtt.f32.f16 s5, s2
; CHECK-NEXT:    vcvtb.f32.f16 s4, s2
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = fpext <8 x half> %src1 to <8 x float>
  ret <8 x float> %out
}


define arm_aapcs_vfpcc <4 x half> @fptrunc_4(<4 x float> %src1) {
; CHECK-LABEL: fptrunc_4:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vcvtt.f16.f32 s0, s1
; CHECK-NEXT:    vcvtb.f16.f32 s1, s2
; CHECK-NEXT:    vcvtt.f16.f32 s1, s3
; CHECK-NEXT:    bx lr
entry:
  %out = fptrunc <4 x float> %src1 to <4 x half>
  ret <4 x half> %out
}

define arm_aapcs_vfpcc <8 x half> @fptrunc_8(<8 x float> %src1) {
; CHECK-LABEL: fptrunc_8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vcvtt.f16.f32 s0, s1
; CHECK-NEXT:    vcvtb.f16.f32 s1, s2
; CHECK-NEXT:    vcvtb.f16.f32 s2, s4
; CHECK-NEXT:    vcvtt.f16.f32 s1, s3
; CHECK-NEXT:    vcvtb.f16.f32 s3, s6
; CHECK-NEXT:    vcvtt.f16.f32 s2, s5
; CHECK-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-NEXT:    bx lr
entry:
  %out = fptrunc <8 x float> %src1 to <8 x half>
  ret <8 x half> %out
}


define arm_aapcs_vfpcc <8 x half> @shuffle_trunc1(<4 x float> %src1, <4 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc1:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc1:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q1
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <4 x float> %src1, <4 x float> %src2, <8 x i32> <i32 0, i32 4, i32 1, i32 5, i32 2, i32 6, i32 3, i32 7>
  %out = fptrunc <8 x float> %strided.vec to <8 x half>
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <8 x half> @shuffle_trunc2(<4 x float> %src1, <4 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc2:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmov q2, q0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s11
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc2:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q1, q0
; CHECK-MVEFP-NEXT:    vmov q0, q1
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <4 x float> %src1, <4 x float> %src2, <8 x i32> <i32 4, i32 0, i32 5, i32 1, i32 6, i32 2, i32 7, i32 3>
  %out = fptrunc <8 x float> %strided.vec to <8 x half>
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <16 x half> @shuffle_trunc3(<8 x float> %src1, <8 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc3:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s4, s4
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s5, s5
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s6, s6
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s7, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s11
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s4, s12
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s5, s13
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s6, s14
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s7, s15
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc3:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q2
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q1, q3
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <8 x float> %src1, <8 x float> %src2, <16 x i32> <i32 0, i32 8, i32 1, i32 9, i32 2, i32 10, i32 3, i32 11, i32 4, i32 12, i32 5, i32 13, i32 6, i32 14, i32 7, i32 15>
  %out = fptrunc <16 x float> %strided.vec to <16 x half>
  ret <16 x half> %out
}

define arm_aapcs_vfpcc <16 x half> @shuffle_trunc4(<8 x float> %src1, <8 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc4:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    .vsave {d8, d9}
; CHECK-MVE-NEXT:    vpush {d8, d9}
; CHECK-MVE-NEXT:    vmov q4, q0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s11
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s8, s12
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s9, s13
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s10, s14
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s11, s15
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s8, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s9, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s10, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s11, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s16
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s17
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s18
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s19
; CHECK-MVE-NEXT:    vmov q1, q2
; CHECK-MVE-NEXT:    vpop {d8, d9}
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc4:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q2, q2
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q3, q3
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q2, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q3, q1
; CHECK-MVEFP-NEXT:    vmov q0, q2
; CHECK-MVEFP-NEXT:    vmov q1, q3
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <8 x float> %src1, <8 x float> %src2, <16 x i32> <i32 8, i32 0, i32 9, i32 1, i32 10, i32 2, i32 11, i32 3, i32 12, i32 4, i32 13, i32 5, i32 14, i32 6, i32 15, i32 7>
  %out = fptrunc <16 x float> %strided.vec to <16 x half>
  ret <16 x half> %out
}

define arm_aapcs_vfpcc <8 x half> @shuffle_trunc5(<4 x float> %src1, <4 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc5:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc5:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q1
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out1 = fptrunc <4 x float> %src1 to <4 x half>
  %out2 = fptrunc <4 x float> %src2 to <4 x half>
  %s = shufflevector <4 x half> %out1, <4 x half> %out2, <8 x i32> <i32 0, i32 4, i32 1, i32 5, i32 2, i32 6, i32 3, i32 7>
  ret <8 x half> %s
}

define arm_aapcs_vfpcc <8 x half> @shuffle_trunc6(<4 x float> %src1, <4 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc6:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmov q2, q0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s11
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc6:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q1, q0
; CHECK-MVEFP-NEXT:    vmov q0, q1
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out1 = fptrunc <4 x float> %src1 to <4 x half>
  %out2 = fptrunc <4 x float> %src2 to <4 x half>
  %s = shufflevector <4 x half> %out1, <4 x half> %out2, <8 x i32> <i32 4, i32 0, i32 5, i32 1, i32 6, i32 2, i32 7, i32 3>
  ret <8 x half> %s
}

define arm_aapcs_vfpcc <16 x half> @shuffle_trunc7(<8 x float> %src1, <8 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc7:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s4, s4
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s5, s5
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s6, s6
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s7, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s11
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s4, s12
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s5, s13
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s6, s14
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s7, s15
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc7:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q2
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q1, q3
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out1 = fptrunc <8 x float> %src1 to <8 x half>
  %out2 = fptrunc <8 x float> %src2 to <8 x half>
  %s = shufflevector <8 x half> %out1, <8 x half> %out2, <16 x i32> <i32 0, i32 8, i32 1, i32 9, i32 2, i32 10, i32 3, i32 11, i32 4, i32 12, i32 5, i32 13, i32 6, i32 14, i32 7, i32 15>
  ret <16 x half> %s
}

define arm_aapcs_vfpcc <16 x half> @shuffle_trunc8(<8 x float> %src1, <8 x float> %src2) {
; CHECK-MVE-LABEL: shuffle_trunc8:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    .vsave {d8, d9}
; CHECK-MVE-NEXT:    vpush {d8, d9}
; CHECK-MVE-NEXT:    vmov q4, q0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s11
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s8, s12
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s9, s13
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s10, s14
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s11, s15
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s8, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s9, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s10, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s11, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s16
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s17
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s18
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s19
; CHECK-MVE-NEXT:    vmov q1, q2
; CHECK-MVE-NEXT:    vpop {d8, d9}
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: shuffle_trunc8:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q2, q2
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q3, q3
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q2, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q3, q1
; CHECK-MVEFP-NEXT:    vmov q0, q2
; CHECK-MVEFP-NEXT:    vmov q1, q3
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out1 = fptrunc <8 x float> %src1 to <8 x half>
  %out2 = fptrunc <8 x float> %src2 to <8 x half>
  %s = shufflevector <8 x half> %out1, <8 x half> %out2, <16 x i32> <i32 8, i32 0, i32 9, i32 1, i32 10, i32 2, i32 11, i32 3, i32 12, i32 4, i32 13, i32 5, i32 14, i32 6, i32 15, i32 7>
  ret <16 x half> %s
}




define arm_aapcs_vfpcc <4 x float> @load_ext_4(ptr %src) {
; CHECK-MVE-LABEL: load_ext_4:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    ldrd r0, r1, [r0]
; CHECK-MVE-NEXT:    vmov.32 q0[0], r0
; CHECK-MVE-NEXT:    vmov.32 q0[1], r1
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s3, s1
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s2, s1
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s1, s0
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: load_ext_4:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vldrh.u32 q0, [r0]
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %wide.load = load <4 x half>, ptr %src, align 4
  %e = fpext <4 x half> %wide.load to <4 x float>
  ret <4 x float> %e
}

define arm_aapcs_vfpcc <8 x float> @load_ext_8(ptr %src) {
; CHECK-MVE-LABEL: load_ext_8:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vldrw.u32 q2, [r0]
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s3, s9
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s2, s9
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s1, s8
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s7, s11
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s6, s11
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s5, s10
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s4, s10
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: load_ext_8:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vldrh.u32 q0, [r0]
; CHECK-MVEFP-NEXT:    vldrh.u32 q1, [r0, #8]
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q0, q0
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q1, q1
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %wide.load = load <8 x half>, ptr %src, align 4
  %e = fpext <8 x half> %wide.load to <8 x float>
  ret <8 x float> %e
}

define arm_aapcs_vfpcc <16 x float> @load_ext_16(ptr %src) {
; CHECK-MVE-LABEL: load_ext_16:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    .vsave {d8, d9}
; CHECK-MVE-NEXT:    vpush {d8, d9}
; CHECK-MVE-NEXT:    vldrw.u32 q2, [r0], #16
; CHECK-MVE-NEXT:    vldrw.u32 q4, [r0]
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s3, s9
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s2, s9
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s1, s8
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s7, s11
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s6, s11
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s5, s10
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s4, s10
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s11, s17
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s10, s17
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s9, s16
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s8, s16
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s15, s19
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s14, s19
; CHECK-MVE-NEXT:    vcvtt.f32.f16 s13, s18
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s12, s18
; CHECK-MVE-NEXT:    vpop {d8, d9}
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: load_ext_16:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vldrh.u32 q0, [r0]
; CHECK-MVEFP-NEXT:    vldrh.u32 q1, [r0, #8]
; CHECK-MVEFP-NEXT:    vldrh.u32 q2, [r0, #16]
; CHECK-MVEFP-NEXT:    vldrh.u32 q3, [r0, #24]
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q0, q0
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q1, q1
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q2, q2
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q3, q3
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %wide.load = load <16 x half>, ptr %src, align 4
  %e = fpext <16 x half> %wide.load to <16 x float>
  ret <16 x float> %e
}

define arm_aapcs_vfpcc <4 x float> @load_shuffleext_8(ptr %src) {
; CHECK-MVE-LABEL: load_shuffleext_8:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vldrw.u32 q0, [r0]
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s3, s3
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: load_shuffleext_8:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vldrw.u32 q0, [r0]
; CHECK-MVEFP-NEXT:    vcvtb.f32.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %wide.load = load <8 x half>, ptr %src, align 4
  %sh = shufflevector <8 x half> %wide.load, <8 x half> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %e = fpext <4 x half> %sh to <4 x float>
  ret <4 x float> %e
}

define arm_aapcs_vfpcc <8 x float> @load_shuffleext_16(ptr %src) {
; CHECK-LABEL: load_shuffleext_16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vld20.16 {q2, q3}, [r0]
; CHECK-NEXT:    vld21.16 {q2, q3}, [r0]
; CHECK-NEXT:    vcvtt.f32.f16 s3, s9
; CHECK-NEXT:    vcvtb.f32.f16 s2, s9
; CHECK-NEXT:    vcvtt.f32.f16 s1, s8
; CHECK-NEXT:    vcvtb.f32.f16 s0, s8
; CHECK-NEXT:    vcvtt.f32.f16 s7, s11
; CHECK-NEXT:    vcvtb.f32.f16 s6, s11
; CHECK-NEXT:    vcvtt.f32.f16 s5, s10
; CHECK-NEXT:    vcvtb.f32.f16 s4, s10
; CHECK-NEXT:    bx lr
entry:
  %wide.load = load <16 x half>, ptr %src, align 4
  %sh = shufflevector <16 x half> %wide.load, <16 x half> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %e = fpext <8 x half> %sh to <8 x float>
  ret <8 x float> %e
}




define arm_aapcs_vfpcc void @store_trunc_4(ptr %src, <4 x float> %val) {
; CHECK-MVE-LABEL: store_trunc_4:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s2
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s3
; CHECK-MVE-NEXT:    vmov r1, r2, d0
; CHECK-MVE-NEXT:    strd r1, r2, [r0]
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: store_trunc_4:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vstrh.32 q0, [r0]
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %e = fptrunc <4 x float> %val to <4 x half>
  store <4 x half> %e, ptr %src, align 4
  ret void
}

define arm_aapcs_vfpcc void @store_trunc_8(ptr %src, <8 x float> %val) {
; CHECK-MVE-LABEL: store_trunc_8:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s3
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: store_trunc_8:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vstrh.32 q1, [r0, #8]
; CHECK-MVEFP-NEXT:    vstrh.32 q0, [r0]
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %e = fptrunc <8 x float> %val to <8 x half>
  store <8 x half> %e, ptr %src, align 4
  ret void
}

define arm_aapcs_vfpcc void @store_trunc_16(ptr %src, <16 x float> %val) {
; CHECK-MVE-LABEL: store_trunc_16:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s3
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vstrb.8 q0, [r0], #16
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s10
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s12
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s14
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s11
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s13
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s15
; CHECK-MVE-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: store_trunc_16:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q3, q3
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q2, q2
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vstrh.32 q3, [r0, #24]
; CHECK-MVEFP-NEXT:    vstrh.32 q2, [r0, #16]
; CHECK-MVEFP-NEXT:    vstrh.32 q1, [r0, #8]
; CHECK-MVEFP-NEXT:    vstrh.32 q0, [r0]
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %e = fptrunc <16 x float> %val to <16 x half>
  store <16 x half> %e, ptr %src, align 4
  ret void
}

define arm_aapcs_vfpcc void @store_shuffletrunc_8(ptr %src, <4 x float> %val1, <4 x float> %val2) {
; CHECK-MVE-LABEL: store_shuffletrunc_8:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: store_shuffletrunc_8:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q1
; CHECK-MVEFP-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <4 x float> %val1, <4 x float> %val2, <8 x i32> <i32 0, i32 4, i32 1, i32 5, i32 2, i32 6, i32 3, i32 7>
  %out = fptrunc <8 x float> %strided.vec to <8 x half>
  store <8 x half> %out, ptr %src, align 4
  ret void
}

define arm_aapcs_vfpcc void @store_shuffletrunc_16(ptr %src, <8 x float> %val1, <8 x float> %val2) {
; CHECK-MVE-LABEL: store_shuffletrunc_16:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s1
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s2
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s3
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s8
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s9
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s10
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s11
; CHECK-MVE-NEXT:    vstrb.8 q0, [r0], #16
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s0, s4
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s1, s5
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s2, s6
; CHECK-MVE-NEXT:    vcvtb.f16.f32 s3, s7
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s0, s12
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s1, s13
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s2, s14
; CHECK-MVE-NEXT:    vcvtt.f16.f32 s3, s15
; CHECK-MVE-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: store_shuffletrunc_16:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q1, q1
; CHECK-MVEFP-NEXT:    vcvtb.f16.f32 q0, q0
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q1, q3
; CHECK-MVEFP-NEXT:    vcvtt.f16.f32 q0, q2
; CHECK-MVEFP-NEXT:    vstrw.32 q1, [r0, #16]
; CHECK-MVEFP-NEXT:    vstrw.32 q0, [r0]
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %strided.vec = shufflevector <8 x float> %val1, <8 x float> %val2, <16 x i32> <i32 0, i32 8, i32 1, i32 9, i32 2, i32 10, i32 3, i32 11, i32 4, i32 12, i32 5, i32 13, i32 6, i32 14, i32 7, i32 15>
  %out = fptrunc <16 x float> %strided.vec to <16 x half>
  store <16 x half> %out, ptr %src, align 4
  ret void
}