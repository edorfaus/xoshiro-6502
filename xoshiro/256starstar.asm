.include "256vars.asm"

.segment "LIBCODE"

; Output function for xoshiro256** 1.0.
; Clobbers: A, X
Xoshiro256StarStar:
	; result = RotateLeft(state[1] * 5, 7) * 9

	; value*5 = value*4 + value = value<<2 + value
	; value*5 step 1: value = state[1] << 1
	lda Xoshiro256State1+0
	asl
	sta Xoshiro256Value+0
	.repeat .sizeof(Xoshiro256Value)-1, i
		lda Xoshiro256State1+1+i
		rol
		sta Xoshiro256Value+1+i
	.endrepeat

	; value*5 step 2: value <<= 1 (thus value = state[1] << 2)
	asl Xoshiro256Value+0
	.repeat .sizeof(Xoshiro256Value)-1, i
		rol Xoshiro256Value+1+i
	.endrepeat

	; value*5 step 3: value += state[1]
	clc
	.repeat .sizeof(Xoshiro256Value), i
		lda Xoshiro256Value+i
		adc Xoshiro256State1+i
		sta Xoshiro256Value+i
	.endrepeat

	; RotateLeft(value, 7)
	; 7 = 8 - 1, so one full byte minus one bit : left a byte, right 1.
	lda Xoshiro256Value+.sizeof(Xoshiro256Value)-1
	pha
	lsr
	.repeat .sizeof(Xoshiro256Value)-1, i
		lda Xoshiro256Value+.sizeof(Xoshiro256Value)-1-1-i
		ror
		sta Xoshiro256Value+.sizeof(Xoshiro256Value)-1-i
	.endrepeat
	pla
	ror
	sta Xoshiro256Value+0

	; value*9 = value*8 + value = value<<3 + value
	; value*9 step 1: save value for later
	.repeat .sizeof(Xoshiro256Value), i
		lda Xoshiro256Value+.sizeof(Xoshiro256Value)-1-i
		pha
	.endrepeat

	; value*9 step 2: shift value left 3 times
	ldx #3
	:
		asl Xoshiro256Value+0
		.repeat .sizeof(Xoshiro256Value)-1, i
			rol Xoshiro256Value+1+i
		.endrepeat
	dex
	bne :-

	; value*9 step 3: add in the old value
	clc
	.repeat .sizeof(Xoshiro256Value), i
		pla
		adc Xoshiro256Value+i
		sta Xoshiro256Value+i
	.endrepeat

	rts
