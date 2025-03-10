; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s
; PR2540
; Outval should end up with a select from 0/2, not all constants.

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32"
target triple = "i386-pc-linux-gnu"
@g_37 = common global i32 0		; <i32*> [#uses=1]
@.str = internal constant [4 x i8] c"%d\0A\00"		; <[4 x i8]*> [#uses=1]

define i32 @main() nounwind  {
; CHECK-LABEL: @main(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[L:%.*]] = load i32, i32* @g_37, align 4
; CHECK-NEXT:    [[CMPA:%.*]] = icmp ne i32 [[L]], 0
; CHECK-NEXT:    [[CMPB:%.*]] = icmp eq i1 [[CMPA]], false
; CHECK-NEXT:    [[OUTVAL_SEL:%.*]] = select i1 [[CMPA]], i32 1, i32 0
; CHECK-NEXT:    [[OR_COND:%.*]] = or i1 [[CMPA]], [[CMPB]]
; CHECK-NEXT:    [[BRMERGE:%.*]] = or i1 [[OR_COND]], [[CMPA]]
; CHECK-NEXT:    [[OUTVAL_SEL_MUX:%.*]] = select i1 [[OR_COND]], i32 [[OUTVAL_SEL]], i32 2
; CHECK-NEXT:    br i1 [[BRMERGE]], label [[FUNC_1_EXIT:%.*]], label [[INFLOOP:%.*]]
; CHECK:       func_1.exit:
; CHECK-NEXT:    [[POUT:%.*]] = tail call i32 (i8*, ...) @printf(i8* noalias getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 [[OUTVAL_SEL_MUX]]) #[[ATTR0:[0-9]+]]
; CHECK-NEXT:    ret i32 0
; CHECK:       infloop:
; CHECK-NEXT:    br label [[INFLOOP]]
;
entry:
  %l = load i32, i32* @g_37, align 4		; <i32> [#uses=1]
  %cmpa = icmp ne i32 %l, 0		; <i1> [#uses=3]
  br i1 %cmpa, label %func_1.exit, label %mooseblock

mooseblock:		; preds = %entry
  %cmpb = icmp eq i1 %cmpa, false		; <i1> [#uses=2]
  br i1 %cmpb, label %monkeyblock, label %beeblock

monkeyblock:		; preds = %monkeyblock, %mooseblock
  br i1 %cmpb, label %cowblock, label %monkeyblock

beeblock:		; preds = %beeblock, %mooseblock
  br i1 %cmpa, label %cowblock, label %beeblock

cowblock:		; preds = %beeblock, %monkeyblock
  %cowval = phi i32 [ 2, %beeblock ], [ 0, %monkeyblock ]		; <i32> [#uses=1]
  br label %func_1.exit

func_1.exit:		; preds = %cowblock, %entry
  %outval = phi i32 [ %cowval, %cowblock ], [ 1, %entry ]		; <i32> [#uses=1]
  %pout = tail call i32 (i8*, ...) @printf( i8* noalias  getelementptr ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i32 %outval ) nounwind 		; <i32> [#uses=0]
  ret i32 0
}

declare i32 @printf(i8*, ...) nounwind

