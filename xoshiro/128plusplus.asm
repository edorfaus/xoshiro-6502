.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoshiro128++ 1.0.
; Clobbers: A
Xoshiro128PlusPlus:
	; result = RotateLeft(state[0] + state[3], 7) + state[0]
	; 7 = 8 - 1, so one full byte minus one bit : left a byte, right 1.

	; tmp = state[0] + state[3], but rotated left by 8 bits
	clc
	.repeat .sizeof(Xoshiro128State0), i
		lda Xoshiro128State0+i
		adc Xoshiro128State3+i
		sta Xoshiro128Value+((i+1) .mod .sizeof(Xoshiro128State0))
	.endrepeat

	; rotate right by 1 bit
	;lda Xoshiro128Value+0 ; already last value loaded above
	lsr
	.repeat .sizeof(Xoshiro128Value), i
		ror Xoshiro128Value+.sizeof(Xoshiro128Value)-1-i
	.endrepeat

	; result = tmp + state[0]
	clc
	.repeat .sizeof(Xoshiro128Value), i
		lda Xoshiro128Value+i
		adc Xoshiro128State0+i
		sta Xoshiro128Value+i
	.endrepeat

	rts
