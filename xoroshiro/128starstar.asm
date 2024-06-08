.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro128** 1.0.
; This expects the state to be advanced with NextA.
Xoroshiro128StarStar:
	; result = RotateLeft(state[0] * 5, 7) * 9
	; TODO
	rts
