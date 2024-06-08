.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro128+ 1.0.
; This expects the state to be advanced with NextA.
Xoroshiro128Plus:
	; result = state[0] + state[1]
	; TODO
	rts
