.include "128nexta.asm"

.segment "LIBDATA"

xoroshiro128LongJumpABits:
	.byte $DD, $DF, $9B, $10, $90, $AA, $7A, $C1
	.byte $D2, $A9, $8B, $26, $62, $5E, $EE, $7B
xoroshiro128LongJumpABitsLength = * - xoroshiro128LongJumpABits

.segment "LIBCODE"

; LongJumpA is equivalent to calling NextA 2^96 times.
Xoroshiro128LongJumpA:
	; TODO
	rts
