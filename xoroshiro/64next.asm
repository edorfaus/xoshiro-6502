.include "64vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; Clobbers: A, X, Y
Xoroshiro64Next:
	; state[1] ^= state[0]
	ldx #.sizeof(Xoroshiro64State1)-1
	:
		lda Xoroshiro64State1, x
		eor Xoroshiro64State0, x
		sta Xoroshiro64State1, x
	dex
	bpl :-

	; state[0] = RotateLeft(state[0], 26)
	; 26 = 3*8 + 2, so 3 full bytes plus 2 bits.
	; Modulo the word size, 3*8 == -1*8, so 1 byte right + 2 bits left.
	; Part 1: right 1 byte
	lda Xoroshiro64State0+0
	.repeat .sizeof(Xoroshiro64State0)-1, i
		ldx Xoroshiro64State0+1+i
		stx Xoroshiro64State0+0+i
	.endrepeat
	sta Xoroshiro64State0+.sizeof(Xoroshiro64State0)-1
	; Part 2: left 2 bits
	;lda Xoroshiro64State0+.sizeof(Xoroshiro64State0)-1
	ldx #2
	:
		asl
		.repeat .sizeof(Xoroshiro64State0), i
			rol Xoroshiro64State0+i
		.endrepeat
	dex
	bne :-

	; state[0] ^= state[1] ^ (state[1] << 9)
	ldy #.sizeof(Xoroshiro64State0)
	;ldx #0
	txa
	clc
	:
		eor Xoroshiro64State1, x
		eor Xoroshiro64State0, x
		sta Xoroshiro64State0, x
		lda Xoroshiro64State1, x
		rol
		inx
	dey
	bne :-

	; state[1] = RotateLeft(state[1], 13)
	; 13 = 1*8 + 5 = 2*8 - 3, so 2 bytes left and 3 bits right.
	; Part 1: left 2 bytes
	ldx Xoroshiro64State1+.sizeof(Xoroshiro64State1)-1
	lda Xoroshiro64State1+.sizeof(Xoroshiro64State1)-2
	.repeat .sizeof(Xoroshiro64State1)-2, i
		ldy Xoroshiro64State1+0+i
		sty Xoroshiro64State1+2+i
	.endrepeat
	stx Xoroshiro64State1+1
	sta Xoroshiro64State1+0
	; Part 2: right 3 bits
	;lda Xoroshiro64State0+0
	ldx #3
	:
		lsr
		.repeat .sizeof(Xoroshiro64State1), i
			ror Xoroshiro64State1+.sizeof(Xoroshiro64State1)-1-i
		.endrepeat
	dex
	bne :-

	rts
