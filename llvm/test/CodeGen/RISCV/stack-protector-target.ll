; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py

;; Test target-specific stack cookie location.
;
; RUN: llc -mtriple=riscv64-fuchsia < %s | FileCheck --check-prefix=FUCHSIA-RISCV64 %s

define void @func() sspreq nounwind {
; FUCHSIA-RISCV64-LABEL: func:
; FUCHSIA-RISCV64:       # %bb.0:
; FUCHSIA-RISCV64-NEXT:    addi sp, sp, -32
; FUCHSIA-RISCV64-NEXT:    sd ra, 24(sp) # 8-byte Folded Spill
; FUCHSIA-RISCV64-NEXT:    ld a0, -16(tp)
; FUCHSIA-RISCV64-NEXT:    sd a0, 16(sp)
; FUCHSIA-RISCV64-NEXT:    addi a0, sp, 12
; FUCHSIA-RISCV64-NEXT:    call capture
; FUCHSIA-RISCV64-NEXT:    ld a0, -16(tp)
; FUCHSIA-RISCV64-NEXT:    ld a1, 16(sp)
; FUCHSIA-RISCV64-NEXT:    bne a0, a1, .LBB0_2
; FUCHSIA-RISCV64-NEXT:  # %bb.1: # %SP_return
; FUCHSIA-RISCV64-NEXT:    ld ra, 24(sp) # 8-byte Folded Reload
; FUCHSIA-RISCV64-NEXT:    addi sp, sp, 32
; FUCHSIA-RISCV64-NEXT:    ret
; FUCHSIA-RISCV64-NEXT:  .LBB0_2: # %CallStackCheckFailBlk
; FUCHSIA-RISCV64-NEXT:    call __stack_chk_fail
  %1 = alloca i32, align 4
  call void @capture(ptr %1)
  ret void
}

declare void @capture(ptr)