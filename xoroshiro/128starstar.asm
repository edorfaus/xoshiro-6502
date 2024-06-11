.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro128** 1.0.
; This expects the state to be advanced with NextA.
; Clobbers: A, X
Xoroshiro128StarStar:
	; result = RotateLeft(state[0] * 5, 7) * 9

	; value*5 = value*4 + value = value<<2 + value
	; value*5 step 1: value = state[0] << 1
	lda Xoroshiro128State0+0
	asl
	sta Xoroshiro128Value+0
	.repeat .sizeof(Xoroshiro128Value)-1, i
		lda Xoroshiro128State0+1+i
		rol
		sta Xoroshiro128Value+1+i
	.endrepeat

	; value*5 step 2: value <<= 1 (thus value = state[0] << 2)
	asl Xoroshiro128Value+0
	.repeat .sizeof(Xoroshiro128Value)-1, i
		rol Xoroshiro128Value+1+i
	.endrepeat

	; value*5 step 3: value += state[0]
	clc
	.repeat .sizeof(Xoroshiro128Value), i
		lda Xoroshiro128Value+i
		adc Xoroshiro128State0+i
		sta Xoroshiro128Value+i
	.endrepeat

	; RotateLeft(value, 7)
	; 7 = 8 - 1, so one full byte minus one bit : left a byte, right 1.
	lda Xoroshiro128Value+.sizeof(Xoroshiro128Value)-1
	pha
	lsr
	ldx #.sizeof(Xoroshiro128Value)-1-1
	:
		lda Xoroshiro128Value, x
		ror
		sta Xoroshiro128Value+1, x
	dex
	bpl :-
	pla
	ror
	sta Xoroshiro128Value+0

	; value*9 = value*8 + value = value<<3 + value
	; value*9 step 1: save value for later
	ldx #.sizeof(Xoroshiro128Value)-1
	:
		lda Xoroshiro128Value, x
		pha
	dex
	bpl :-

	; value*9 step 2: shift value left 3 times
	ldx #3
	:
		asl Xoroshiro128Value+0
		.repeat .sizeof(Xoroshiro128Value)-1, i
			rol Xoroshiro128Value+1+i
		.endrepeat
	dex
	bne :-

	; value*9 step 3: add in the old value
	clc
	.repeat .sizeof(Xoroshiro128Value), i
		pla
		adc Xoroshiro128Value+i
		sta Xoroshiro128Value+i
	.endrepeat

	rts
