.ifndef Xoroshiro128NextB

.include "128vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; This is the next function to use with the ++ output function.
Xoroshiro128NextB:
	; TODO
	rts

.endif
