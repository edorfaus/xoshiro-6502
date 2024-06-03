.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoshiro128** 1.1.
; Clobbers: A, X
Xoshiro128StarStar:
	; result = RotateLeft(state[1] * 5, 7) * 9

	; value*5 = value*4 + value = value<<2 + value
	; value*5 step 1: value = state[1] << 1
	lda Xoshiro128State1+0
	asl
	sta Xoshiro128Value+0
	.repeat .sizeof(Xoshiro128Value)-1, i
		lda Xoshiro128State1+1+i
		rol
		sta Xoshiro128Value+1+i
	.endrepeat

	; value*5 step 2: value <<= 1 (thus value = state[1] << 2)
	asl Xoshiro128Value+0
	.repeat .sizeof(Xoshiro128Value)-1, i
		rol Xoshiro128Value+1+i
	.endrepeat

	; value*5 step 3: value += state[1]
	clc
	.repeat .sizeof(Xoshiro128Value), i
		lda Xoshiro128Value+i
		adc Xoshiro128State1+i
		sta Xoshiro128Value+i
	.endrepeat

	; RotateLeft(value, 7)
	; 7 = 8 - 1, so one full byte minus one bit : left a byte, right 1.
	lda Xoshiro128Value+.sizeof(Xoshiro128Value)-1
	pha
	lsr
	.repeat .sizeof(Xoshiro128Value)-1, i
		lda Xoshiro128Value+.sizeof(Xoshiro128Value)-1-1-i
		ror
		sta Xoshiro128Value+.sizeof(Xoshiro128Value)-1-i
	.endrepeat
	pla
	ror
	sta Xoshiro128Value+0

	; value*9 = value*8 + value = value<<3 + value
	; value*9 step 1: save value for later
	.repeat .sizeof(Xoshiro128Value), i
		lda Xoshiro128Value+.sizeof(Xoshiro128Value)-1-i
		pha
	.endrepeat

	; value*9 step 2: shift value left 3 times
	ldx #3
	:
		asl Xoshiro128Value+0
		.repeat .sizeof(Xoshiro128Value)-1, i
			rol Xoshiro128Value+1+i
		.endrepeat
	dex
	bne :-

	; value*9 step 3: add in the old value
	clc
	.repeat .sizeof(Xoshiro128Value), i
		pla
		adc Xoshiro128Value+i
		sta Xoshiro128Value+i
	.endrepeat

	rts
