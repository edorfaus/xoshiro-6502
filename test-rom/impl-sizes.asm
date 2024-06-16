.include "isize-macros.asm"

; This file contains information about the last known sizes of the
; xoshiro/xoroshiro implementations, which are used for showing the
; differences to the current implementations, if any.
;
; Nothing in this file ends up in the finished ROM, it is purely for
; assemble-time informational purposes (given as terminal output).

.ifndef printSizes
	; If set to 1, all sizes are shown.
	; If set to anything else, changed sizes are shown.
	printSizes = 0
.endif

size_Xoshiro128Plus        =  38
size_Xoshiro128PlusPlus    =  88
size_Xoshiro128StarStar    = 171
size_Xoshiro128Next        = 122
size_Xoshiro128Jump        =  62
size_Xoshiro128LongJump    =  62
totalSize Xoshiro128:    ZP  0, RAM 20, code  543, data   32; total  595

size_Xoshiro256Plus        =  74
size_Xoshiro256PlusPlus    = 175
size_Xoshiro256StarStar    = 331
size_Xoshiro256Next        = 145
size_Xoshiro256Jump        =  62
size_Xoshiro256LongJump    =  62
totalSize Xoshiro256:    ZP  0, RAM 40, code  849, data   64; total  953

size_Xoroshiro64Star       = 100
size_Xoroshiro64StarStar   =  67
size_Xoroshiro64Next       = 120
totalSize Xoroshiro64:   ZP  0, RAM 12, code  287, data    0; total  299

size_Xoroshiro128Plus      =  19
size_Xoroshiro128StarStar  = 271
size_Xoroshiro128NextA     = 121
size_Xoroshiro128JumpA     =  65
size_Xoroshiro128LongJumpA =  65
totalSize Xoroshiro128A: ZP  0, RAM 24, code  541, data   32; total  597

size_Xoroshiro128PlusPlus  =  90
size_Xoroshiro128NextB     = 167
size_Xoroshiro128JumpB     =  65
size_Xoroshiro128LongJumpB =  65
totalSize Xoroshiro128B: ZP  0, RAM  0, code  387, data   32; total  419
totalSize Xoroshiro128:  ZP  0, RAM 24, code  928, data   64; total 1016

totalSize combined:      ZP  0, RAM 96, code 2607, data  160; total 2863
