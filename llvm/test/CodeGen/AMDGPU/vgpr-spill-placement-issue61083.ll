; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O0 -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -o - %s | FileCheck %s

@V1 = protected local_unnamed_addr addrspace(1) global i32 0, align 4
@V2 = protected local_unnamed_addr addrspace(1) global i32 0, align 4
@Q = internal addrspace(3) global i8 poison, align 16

; Test spill placement of VGPR reload in %bb.194 relative to the SGPR
; reload used for the exec mask. The buffer_load_dword should be after
; the s_or_b64 exec.
define amdgpu_kernel void @__omp_offloading_16_dd2df_main_l9()  {
; CHECK-LABEL: __omp_offloading_16_dd2df_main_l9:
; CHECK:       ; %bb.0: ; %bb
; CHECK-NEXT:    s_add_u32 s0, s0, s13
; CHECK-NEXT:    s_addc_u32 s1, s1, 0
; CHECK-NEXT:    ; implicit-def: $vgpr1 : SGPR spill to VGPR lane
; CHECK-NEXT:    v_mov_b32_e32 v2, v0
; CHECK-NEXT:    s_or_saveexec_b64 s[8:9], -1
; CHECK-NEXT:    buffer_load_dword v0, off, s[0:3], 0 ; 4-byte Folded Reload
; CHECK-NEXT:    s_mov_b64 exec, s[8:9]
; CHECK-NEXT:    v_mov_b32_e32 v1, 0
; CHECK-NEXT:    global_load_ushort v3, v1, s[4:5] offset:4
; CHECK-NEXT:    s_waitcnt vmcnt(0)
; CHECK-NEXT:    buffer_store_dword v3, off, s[0:3], 0 offset:4 ; 4-byte Folded Spill
; CHECK-NEXT:    ; implicit-def: $sgpr4
; CHECK-NEXT:    s_mov_b32 s4, 0
; CHECK-NEXT:    v_cmp_eq_u32_e64 s[6:7], v2, s4
; CHECK-NEXT:    s_mov_b32 s4, 0
; CHECK-NEXT:    v_mov_b32_e32 v2, s4
; CHECK-NEXT:    ds_write_b8 v1, v2
; CHECK-NEXT:    s_mov_b64 s[4:5], exec
; CHECK-NEXT:    v_writelane_b32 v0, s4, 0
; CHECK-NEXT:    v_writelane_b32 v0, s5, 1
; CHECK-NEXT:    s_or_saveexec_b64 s[8:9], -1
; CHECK-NEXT:    buffer_store_dword v0, off, s[0:3], 0 ; 4-byte Folded Spill
; CHECK-NEXT:    s_mov_b64 exec, s[8:9]
; CHECK-NEXT:    s_and_b64 s[4:5], s[4:5], s[6:7]
; CHECK-NEXT:    s_mov_b64 exec, s[4:5]
; CHECK-NEXT:    s_cbranch_execz .LBB0_2
; CHECK-NEXT:  ; %bb.1: ; %bb193
; CHECK-NEXT:  .LBB0_2: ; %bb194
; CHECK-NEXT:    s_or_saveexec_b64 s[8:9], -1
; CHECK-NEXT:    buffer_load_dword v1, off, s[0:3], 0 ; 4-byte Folded Reload
; CHECK-NEXT:    s_mov_b64 exec, s[8:9]
; CHECK-NEXT:    s_waitcnt vmcnt(0)
; CHECK-NEXT:    v_readlane_b32 s4, v1, 0
; CHECK-NEXT:    v_readlane_b32 s5, v1, 1
; CHECK-NEXT:    s_or_b64 exec, exec, s[4:5]
; CHECK-NEXT:    buffer_load_dword v0, off, s[0:3], 0 offset:4 ; 4-byte Folded Reload
; CHECK-NEXT:    s_mov_b32 s4, 0
; CHECK-NEXT:    s_waitcnt vmcnt(0)
; CHECK-NEXT:    v_cmp_ne_u16_e64 s[4:5], v0, s4
; CHECK-NEXT:    s_and_b64 vcc, exec, s[4:5]
; CHECK-NEXT:    s_cbranch_vccnz .LBB0_4
; CHECK-NEXT:  ; %bb.3: ; %bb201
; CHECK-NEXT:    buffer_load_dword v1, off, s[0:3], 0 offset:4 ; 4-byte Folded Reload
; CHECK-NEXT:    s_getpc_b64 s[4:5]
; CHECK-NEXT:    s_add_u32 s4, s4, V2@rel32@lo+4
; CHECK-NEXT:    s_addc_u32 s5, s5, V2@rel32@hi+12
; CHECK-NEXT:    v_mov_b32_e32 v0, 0
; CHECK-NEXT:    s_waitcnt vmcnt(0)
; CHECK-NEXT:    global_store_short v0, v1, s[4:5]
; CHECK-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; CHECK-NEXT:    s_barrier
; CHECK-NEXT:    s_trap 2
; CHECK-NEXT:    ; divergent unreachable
; CHECK-NEXT:  .LBB0_4: ; %UnifiedReturnBlock
; CHECK-NEXT:    s_or_saveexec_b64 s[8:9], -1
; CHECK-NEXT:    buffer_load_dword v0, off, s[0:3], 0 ; 4-byte Folded Reload
; CHECK-NEXT:    s_mov_b64 exec, s[8:9]
; CHECK-NEXT:    ; kill: killed $vgpr0
; CHECK-NEXT:    s_endpgm
bb:
  %i10 = tail call i32 @llvm.amdgcn.workitem.id.x()
  %i13 = tail call align 4 dereferenceable(64) ptr addrspace(4) @llvm.amdgcn.dispatch.ptr()
  %i14 = getelementptr i8, ptr addrspace(4) %i13, i64 4
  %i15 = load i16, ptr addrspace(4) %i14, align 4
  %i22 = icmp eq i32 %i10, 0
  store i8 0, ptr addrspace(3) @Q
  br i1 %i22, label %bb193, label %bb194

bb193:                                            ; preds = %bb190
  br label %bb194

bb194:                                            ; preds = %bb193, %bb190
  %i196 = icmp eq i16 %i15, 0
  br i1 %i196, label %bb201, label %bb202

bb201:                                            ; preds = %bb194
  store i16 %i15, ptr addrspace(1) @V2
  call void @llvm.amdgcn.s.barrier()
  tail call void @llvm.trap()
  unreachable

bb202:                                            ; preds = %bb194, %bb170, %bb93
  ret void
}

declare hidden void @__keep_alive()
declare i32 @llvm.amdgcn.workitem.id.x()
declare align 4 ptr addrspace(4) @llvm.amdgcn.dispatch.ptr()
declare void @llvm.assume(i1 noundef)
declare void @llvm.amdgcn.s.barrier()
declare void @llvm.trap()

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"amdgpu_code_object_version", i32 500}