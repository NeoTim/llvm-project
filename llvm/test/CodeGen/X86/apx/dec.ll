; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ndd -verify-machineinstrs | FileCheck %s

define i8 @dec8r(i8 noundef %a) {
; CHECK-LABEL: dec8r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decb %dil, %al
; CHECK-NEXT:    retq
entry:
  %dec = sub i8 %a, 1
  ret i8 %dec
}

define i16 @dec16r(i16 noundef %a) {
; CHECK-LABEL: dec16r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decl %edi, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
entry:
  %dec = sub i16 %a, 1
  ret i16 %dec
}

define i32 @dec32r(i32 noundef %a) {
; CHECK-LABEL: dec32r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decl %edi, %eax
; CHECK-NEXT:    retq
entry:
  %dec = sub i32 %a, 1
  ret i32 %dec
}

define i64 @dec64r(i64 noundef %a) {
; CHECK-LABEL: dec64r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %dec = sub i64 %a, 1
  ret i64 %dec
}

define i8 @dec8m(ptr %ptr) {
; CHECK-LABEL: dec8m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decb (%rdi), %al
; CHECK-NEXT:    retq
entry:
  %a = load i8, ptr %ptr
  %dec = sub i8 %a, 1
  ret i8 %dec
}

define i16 @dec16m(ptr %ptr) {
; CHECK-LABEL: dec16m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzwl (%rdi), %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
entry:
  %a = load i16, ptr %ptr
  %dec = sub i16 %a, 1
  ret i16 %dec
}

define i32 @dec32m(ptr %ptr) {
; CHECK-LABEL: dec32m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decl (%rdi), %eax
; CHECK-NEXT:    retq
entry:
  %a = load i32, ptr %ptr
  %dec = sub i32 %a, 1
  ret i32 %dec
}

define i64 @dec64m(ptr %ptr) {
; CHECK-LABEL: dec64m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decq (%rdi), %rax
; CHECK-NEXT:    retq
entry:
  %a = load i64, ptr %ptr
  %dec = sub i64 %a, 1
  ret i64 %dec
}

define void @dec8m_legacy(ptr %ptr) {
; CHECK-LABEL: dec8m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decb (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i8, ptr %ptr
  %dec = sub i8 %a, 1
  store i8 %dec, ptr %ptr
  ret void
}

define void @dec16m_legacy(ptr %ptr) {
; CHECK-LABEL: dec16m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decw (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i16, ptr %ptr
  %dec = sub i16 %a, 1
  store i16 %dec, ptr %ptr
  ret void
}

define void @dec32m_legacy(ptr %ptr) {
; CHECK-LABEL: dec32m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decl (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i32, ptr %ptr
  %dec = sub i32 %a, 1
  store i32 %dec, ptr %ptr
  ret void
}

define void @dec64m_legacy(ptr %ptr) {
; CHECK-LABEL: dec64m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    decq (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i64, ptr %ptr
  %dec = sub i64 %a, 1
  store i64 %dec, ptr %ptr
  ret void
}