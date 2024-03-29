; RUN: opt -S -passes=gvn-hoist < %s | FileCheck %s

; Checking gvn-hoist in case of infinite loops and irreducible control flow.

; Check that bitcast is not hoisted beacuse down safety is not guaranteed.
; CHECK-LABEL: @bazv1
; CHECK: if.then.i:
; CHECK: bitcast
; CHECK-NEXT: load
; CHECK: if.then4.i:
; CHECK: bitcast
; CHECK-NEXT: load

%class.bar = type { ptr, ptr }
%class.base = type { ptr }

; Function Attrs: noreturn nounwind uwtable
define void @bazv1() local_unnamed_addr {
entry:
  %agg.tmp = alloca %class.bar, align 8
  %x.sroa.2.0..sroa_idx2 = getelementptr inbounds %class.bar, ptr %agg.tmp, i64 0, i32 1
  store ptr null, ptr %x.sroa.2.0..sroa_idx2, align 8
  call void @_Z3foo3bar(ptr nonnull %agg.tmp)
  %0 = load ptr, ptr %x.sroa.2.0..sroa_idx2, align 8
  %1 = bitcast ptr %agg.tmp to ptr
  %cmp.i = icmp eq ptr %0, %1
  br i1 %cmp.i, label %if.then.i, label %if.else.i

if.then.i:                                        ; preds = %entry
  %2 = bitcast ptr %0 to ptr
  %vtable.i = load ptr, ptr %2, align 8
  %vfn.i = getelementptr inbounds ptr, ptr %vtable.i, i64 2
  %3 = load ptr, ptr %vfn.i, align 8
  call void %3(ptr %0)
  br label %while.cond.preheader

if.else.i:                                        ; preds = %entry
  %tobool.i = icmp eq ptr %0, null
  br i1 %tobool.i, label %while.cond.preheader, label %if.then4.i

if.then4.i:                                       ; preds = %if.else.i
  %4 = bitcast ptr %0 to ptr
  %vtable6.i = load ptr, ptr %4, align 8
  %vfn7.i = getelementptr inbounds ptr, ptr %vtable6.i, i64 3
  %5 = load ptr, ptr %vfn7.i, align 8
  call void %5(ptr nonnull %0)
  br label %while.cond.preheader

while.cond.preheader:                             ; preds = %if.then.i, %if.else.i, %if.then4.i
  br label %while.cond

while.cond:                                       ; preds = %while.cond.preheader, %while.cond
  %call = call i32 @sleep(i32 10)
  br label %while.cond
}

declare void @_Z3foo3bar(ptr) local_unnamed_addr

declare i32 @sleep(i32) local_unnamed_addr

; Check that the load is hoisted even if it is inside an irreducible control flow
; because the load is anticipable on all paths.

; CHECK-LABEL: @bazv
; CHECK: bb2:
; CHECK-NOT: load
; CHECK-NOT: bitcast

define void @bazv() {
entry:
  %agg.tmp = alloca %class.bar, align 8
  %x= getelementptr inbounds %class.bar, ptr %agg.tmp, i64 0, i32 1
  %0 = load ptr, ptr %x, align 8
  %1 = bitcast ptr %agg.tmp to ptr
  %cmp.i = icmp eq ptr %0, %1
  br i1 %cmp.i, label %bb1, label %bb4

bb1:
  %b1 = bitcast ptr %0 to ptr
  %i = load ptr, ptr %b1, align 8
  %vfn.i = getelementptr inbounds ptr, ptr %i, i64 2
  %cmp.j = icmp eq ptr %0, %1
  br i1 %cmp.j, label %bb2, label %bb3

bb2:
  %l1 = load ptr, ptr %vfn.i, align 8
  br label %bb3

bb3:
  %l2 = load ptr, ptr %vfn.i, align 8
  br label %bb2

bb4:
  %b2 = bitcast ptr %0 to ptr
  ret void
}
