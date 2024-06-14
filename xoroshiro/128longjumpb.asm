.include "128nextb.asm"

.segment "LIBDATA"

xoroshiro128LongJumpBBits:
	.byte $9C, $6E, $68, $77, $73, $6C, $46, $E3
	.byte $36, $0F, $D5, $F2, $CF, $8D, $5D, $99
xoroshiro128LongJumpBBitsLength = * - xoroshiro128LongJumpBBits

.segment "LIBCODE"

; LongJumpB is equivalent to calling NextB 2^96 times.
Xoroshiro128LongJumpB:
	; TODO
	rts
