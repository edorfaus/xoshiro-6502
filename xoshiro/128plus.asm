.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoshiro128+ 1.0.
; Clobbers: A
Xoshiro128Plus:
	; result = state[0] + state[3]
	clc
	.repeat .sizeof(Xoshiro128State0), i
		lda Xoshiro128State0+i
		adc Xoshiro128State3+i
		sta Xoshiro128Value+i
	.endrepeat
	rts
