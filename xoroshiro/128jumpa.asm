.include "128nexta.asm"

.segment "LIBDATA"

xoroshiro128JumpABits:
	.byte $17, $08, $65, $DF, $4B, $32, $01, $FC
	.byte $DF, $90, $02, $94, $D8, $F5, $54, $A5
xoroshiro128JumpABitsLength = * - xoroshiro128JumpABits

.segment "LIBCODE"

; JumpA is equivalent to calling NextA 2^64 times.
Xoroshiro128JumpA:
	; TODO
	rts
