.include "256vars.asm"

.segment "LIBCODE"

; Output function for xoshiro256+ 1.0.
; Clobbers: A
Xoshiro256Plus:
	; result = state[0] + state[3]
	clc
	.repeat .sizeof(Xoshiro256State0), i
		lda Xoshiro256State0+i
		adc Xoshiro256State3+i
		sta Xoshiro256Value+i
	.endrepeat
	rts
