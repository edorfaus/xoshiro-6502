.include "256vars.asm"

.segment "LIBCODE"

; Output function for xoshiro256++ 1.0.
; Clobbers: A
Xoshiro256PlusPlus:
	; result = RotateLeft(state[0] + state[3], 23) + state[0]
	; 23 = 3*8 - 1, so left 3 full bytes, then right 1 bit.

	; tmp = state[0] + state[3], but rotated left by 3*8 bits
	clc
	.repeat .sizeof(Xoshiro256State0), i
		lda Xoshiro256State0+i
		adc Xoshiro256State3+i
		sta Xoshiro256Value+((i+3) .mod .sizeof(Xoshiro256State0))
	.endrepeat

	; rotate right by 1 bit
	lda Xoshiro256Value+0
	lsr
	.repeat .sizeof(Xoshiro256Value), i
		ror Xoshiro256Value+.sizeof(Xoshiro256Value)-1-i
	.endrepeat

	; result = tmp + state[0]
	clc
	.repeat .sizeof(Xoshiro256Value), i
		lda Xoshiro256Value+i
		adc Xoshiro256State0+i
		sta Xoshiro256Value+i
	.endrepeat

	rts
