.include "128next.asm"

.feature underline_in_numbers

.segment "LIBDATA"

xoshiro128JumpBits:
	.dword $8764_000B, $F542_D2D3, $6FA0_35C3, $77F2_DB5B

.segment "LIBCODE"

Xoshiro128Jump:
	; TODO
	rts
