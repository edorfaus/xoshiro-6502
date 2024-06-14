.include "128nextb.asm"

.segment "LIBDATA"

xoroshiro128JumpBBits:
	.byte $09, $92, $CC, $AF, $6A, $6F, $CA, $05
	.byte $2B, $D7, $A6, $A6, $E9, $9C, $2D, $DC
xoroshiro128JumpBBitsLength = * - xoroshiro128JumpBBits

.segment "LIBCODE"

; JumpB is equivalent to calling NextB 2^64 times.
Xoroshiro128JumpB:
	; TODO
	rts
