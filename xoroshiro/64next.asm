.include "64vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; Clobbers: A, X, Xoroshiro64Value
Xoroshiro64Next:
	; TODO
	rts
