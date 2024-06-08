.ifndef Xoroshiro128NextA

.include "128vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; This is the next function to use with the + and ** output functions.
Xoroshiro128NextA:
	; state[1] ^= state[0]
	; state[0] = RotateLeft(state[0], 24) ^ state[1] ^ (state[1] << 16)
	; state[1] = RotateLeft(state[1], 37)
	; TODO
	rts

.endif
