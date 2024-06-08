.ifndef Xoroshiro128NextA

.include "128vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; This is the next function to use with the + and ** output functions.
; Clobbers: A, X, Y
Xoroshiro128NextA:
	; state[1] ^= state[0]
	ldx #.sizeof(Xoroshiro128State1)-1
	:
		lda Xoroshiro128State1, x
		eor Xoroshiro128State0, x
		sta Xoroshiro128State1, x
	dex
	bpl :-

	; state[0] = RotateLeft(state[0], 24)
	; 24 = 3*8, so 3 full bytes.
	lda Xoroshiro128State0+.sizeof(Xoroshiro128State0)-3
	pha
	lda Xoroshiro128State0+.sizeof(Xoroshiro128State0)-2
	pha
	ldy Xoroshiro128State0+.sizeof(Xoroshiro128State0)-1
	ldx #.sizeof(Xoroshiro128State0)-4
	:
		lda Xoroshiro128State0+0, x
		sta Xoroshiro128State0+3, x
	dex
	bpl :-
	sty Xoroshiro128State0+2

	; state[0] ^= state[1] ^ (state[1] << 16)
	; 16 = 2*8, so 2 full bytes
	ldx #.sizeof(Xoroshiro128State0)-1-2
	:
		lda Xoroshiro128State0+2, x
		eor Xoroshiro128State1+2, x
		eor Xoroshiro128State1+0, x
		sta Xoroshiro128State0+2, x
	dex
	bpl :-
	ldx #1
	:
		pla
		eor Xoroshiro128State1+0, x
		sta Xoroshiro128State0+0, x
	dex
	bpl :-

	; state[1] = RotateLeft(state[1], 37)
	; 37 = 4*8 + 5 = 5*8 - 3 = -3*8 - 3, so right 3 bytes and 3 bits.
	; Step 1: right 3 bytes
	lda Xoroshiro128State1+0
	pha
	lda Xoroshiro128State1+1
	pha
	lda Xoroshiro128State1+2
	pha

	ldx #0
	ldy #.sizeof(Xoroshiro128State1)-3
	:
		lda Xoroshiro128State1+3, x
		sta Xoroshiro128State1+0, x
		inx
	dey
	bpl :-

	ldx #2
	:
		pla
		sta Xoroshiro128State1+.sizeof(Xoroshiro128State1)-3, x
	dex
	bpl :-

	; Step 2: right 3 bits
	lda Xoroshiro128State1+0
	ldy #3
	:
		lsr
		ldx #.sizeof(Xoroshiro128State1)-1
		:
			ror Xoroshiro128State1, x
		dex
		bpl :-
	dey
	bne :--

	rts

.endif
