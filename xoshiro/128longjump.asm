.include "128next.asm"

.feature underline_in_numbers

.segment "LIBDATA"

xoshiro128LongJumpBits:
	.dword $B523_952E, $0B6F_099F, $CCF5_A0EF, $1C58_0662

.segment "LIBCODE"

Xoshiro128LongJump:
	; TODO
	rts
