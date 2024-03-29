; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S < %s | FileCheck %s
; Radar 10803727
@.str = private unnamed_addr constant [35 x i8] c"\0Ain_range input (should be 0): %f\0A\00", align 1
@.str1 = external hidden unnamed_addr constant [35 x i8], align 1

declare i32 @printf(ptr, ...)
define i64 @_Z8tempCastj(i32 %val) uwtable ssp {
; CHECK-LABEL: @_Z8tempCastj(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str1, i32 [[VAL:%.*]])
; CHECK-NEXT:    [[CONV:%.*]] = uitofp i32 [[VAL]] to double
; CHECK-NEXT:    [[CALL_I:%.*]] = call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str, double [[CONV]])
; CHECK-NEXT:    br i1 true, label [[LAND_RHS_I:%.*]], label [[IF_END_CRITEDGE:%.*]]
; CHECK:       land.rhs.i:
; CHECK-NEXT:    [[CMP1_I:%.*]] = icmp eq i32 [[VAL]], 0
; CHECK-NEXT:    br i1 [[CMP1_I]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[ADD:%.*]] = fadd double [[CONV]], 5.000000e-01
; CHECK-NEXT:    [[CONV3:%.*]] = fptosi double [[ADD]] to i64
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       if.end.critedge:
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i64 [ [[CONV3]], [[IF_THEN]] ], [ -1, [[IF_END]] ]
; CHECK-NEXT:    ret i64 [[RETVAL_0]]
;
entry:
  %call = call i32 (ptr, ...) @printf(ptr @.str1, i32 %val)
  %conv = uitofp i32 %val to double
  %call.i = call i32 (ptr, ...) @printf(ptr @.str, double %conv)
  %cmp.i = fcmp oge double %conv, -1.000000e+00
  br i1 %cmp.i, label %land.rhs.i, label %if.end.critedge

land.rhs.i:                                       ; preds = %entry
  %cmp1.i = fcmp olt double %conv, 1.000000e+00
  br i1 %cmp1.i, label %if.then, label %if.end

if.then:                                          ; preds = %land.rhs.i
  %add = fadd double %conv, 5.000000e-01
  %conv3 = fptosi double %add to i64
  br label %return

if.end.critedge:                                  ; preds = %entry
  br label %if.end

if.end:                                           ; preds = %if.end.critedge, %land.rhs.i
  br label %return

return:                                           ; preds = %if.end, %if.then
  %retval.0 = phi i64 [ %conv3, %if.then ], [ -1, %if.end ]
  ret i64 %retval.0
}

