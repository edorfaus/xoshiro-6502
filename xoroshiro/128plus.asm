.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro128+ 1.0.
; This expects the state to be advanced with NextA.
; Clobbers: A, X, Y
Xoroshiro128Plus:
	; result = state[0] + state[1]
	ldx #0
	ldy #.sizeof(Xoroshiro128Value)
	clc
	:
		lda Xoroshiro128State0, x
		adc Xoroshiro128State1, x
		sta Xoroshiro128Value, x
		inx
	dey
	bne :-

	rts
