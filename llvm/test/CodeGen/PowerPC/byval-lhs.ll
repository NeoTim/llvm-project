; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -ppc-asm-full-reg-names -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:   %s -o - -verify-machineinstrs | FileCheck %s --check-prefix=LE
; RUN: llc -ppc-asm-full-reg-names -mtriple=powerpc64-ibm-aix-xcoff \
; RUN:   %s -o - -verify-machineinstrs | FileCheck %s --check-prefix=AIX

%struct.type8 = type { i32, i32 }
%struct.type16 = type { i32, i32, i32, i32 }

declare ptr @f0(ptr noundef byval(%struct.type8) align 8)
declare ptr @f1(ptr noundef byval(%struct.type16) align 8)

define void @bar1(i64 %a) nounwind {
; LE-LABEL: bar1:
; LE:       # %bb.0:
; LE-NEXT:    mflr r0
; LE-NEXT:    stdu r1, -48(r1)
; LE-NEXT:    std r0, 64(r1)
; LE-NEXT:    std r3, 40(r1)
; LE-NEXT:    bl f0
; LE-NEXT:    nop
; LE-NEXT:    addi r1, r1, 48
; LE-NEXT:    ld r0, 16(r1)
; LE-NEXT:    mtlr r0
; LE-NEXT:    blr
;
; AIX-LABEL: bar1:
; AIX:       # %bb.0:
; AIX-NEXT:    mflr r0
; AIX-NEXT:    stdu r1, -128(r1)
; AIX-NEXT:    std r0, 144(r1)
; AIX-NEXT:    std r3, 120(r1)
; AIX-NEXT:    bl .f0[PR]
; AIX-NEXT:    nop
; AIX-NEXT:    addi r1, r1, 128
; AIX-NEXT:    ld r0, 16(r1)
; AIX-NEXT:    mtlr r0
; AIX-NEXT:    blr
  %s = alloca %struct.type8, align 8
  store i64 %a, ptr %s, align 8
  %call = tail call ptr @f0(ptr noundef nonnull byval(%struct.type8) align 8 %s)
  ret void
}

define void @bar2(i64 %a) nounwind {
; LE-LABEL: bar2:
; LE:       # %bb.0:
; LE-NEXT:    mflr r0
; LE-NEXT:    stdu r1, -48(r1)
; LE-NEXT:    mr r4, r3
; LE-NEXT:    std r0, 64(r1)
; LE-NEXT:    std r3, 32(r1)
; LE-NEXT:    std r3, 40(r1)
; LE-NEXT:    bl f1
; LE-NEXT:    nop
; LE-NEXT:    addi r1, r1, 48
; LE-NEXT:    ld r0, 16(r1)
; LE-NEXT:    mtlr r0
; LE-NEXT:    blr
;
; AIX-LABEL: bar2:
; AIX:       # %bb.0:
; AIX-NEXT:    mflr r0
; AIX-NEXT:    stdu r1, -128(r1)
; AIX-NEXT:    mr r4, r3
; AIX-NEXT:    std r0, 144(r1)
; AIX-NEXT:    std r3, 112(r1)
; AIX-NEXT:    std r3, 120(r1)
; AIX-NEXT:    bl .f1[PR]
; AIX-NEXT:    nop
; AIX-NEXT:    addi r1, r1, 128
; AIX-NEXT:    ld r0, 16(r1)
; AIX-NEXT:    mtlr r0
; AIX-NEXT:    blr
  %s = alloca %struct.type16, align 8
  %index1 = getelementptr inbounds i64, ptr %s, i32 0
  store i64 %a, ptr %index1, align 8
  %index2 = getelementptr inbounds i64, ptr %s, i32 1
  store i64 %a, ptr %index2, align 8
  %call = tail call ptr @f1(ptr noundef nonnull byval(%struct.type16) align 8 %s)
  ret void
}
