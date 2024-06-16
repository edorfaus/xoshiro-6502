.ifndef Xoroshiro128NextB

.include "128vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; This is the next function to use with the ++ output function.
; Clobbers: A, X, Y
Xoroshiro128NextB:
	; state[1] ^= state[0]
	ldx #.sizeof(Xoroshiro128State1)-1
	:
		lda Xoroshiro128State1, x
		eor Xoroshiro128State0, x
		sta Xoroshiro128State1, x
	dex
	bpl :-

	; state[0] = RotateLeft(state[0], 49) ^ state[1]
	; 49 = 6*8 + 1 = -2*8 + 1, so right 2 bytes and left 1 bit
	lda Xoroshiro128State0+1
	pha
	asl
	lda Xoroshiro128State0+0
	pha
	ldy #.sizeof(Xoroshiro128State0)-2
	:
		inx
		lda Xoroshiro128State0+2, x
		rol
		eor Xoroshiro128State1+0, x
		sta Xoroshiro128State0+0, x
	dey
	bne :-
	iny
	:
		inx
		pla
		rol
		eor Xoroshiro128State1, x
		sta Xoroshiro128State0, x
	dey
	bpl :-

	; state[0] ^= state[1] << 21
	; 21 = 2*8 + 5 = 3*8 - 3, so 3 bytes left and 3 bits right
	; The low 2 bytes will be unaffected by this step, so we skip them.
	; The third byte is also a special case, only doing 3 bits.
	; Step 1: handle the third byte: left 2 bytes + 5 bits
	lda Xoroshiro128State1+0
	.repeat 5
		asl
	.endrepeat
	eor Xoroshiro128State0+2
	sta Xoroshiro128State0+2
	; Step 2: handle all but the first 3 bytes
	tsx
	pha ; push arbitrary value, overwritten below before first use.
	ldy #.sizeof(Xoroshiro128State0)-3-1
	:
		lda Xoroshiro128State1+1, y
		sta $0100, x
		lda Xoroshiro128State1+0, y
		.repeat 3
			lsr $0100, x
			ror
		.endrepeat

		eor Xoroshiro128State0+3, y
		sta Xoroshiro128State0+3, y
	dey
	bpl :-
	pla

	; state[1] = RotateLeft(state[1], 28)
	; 28 = 3*8 + 4, so 3 whole bytes and 4 bits.
	; TODO: this has similar enough shift amounts to the previous step
	; that it's probably possible to reorder/combine to save some work.
	; Step 1: left 3 bytes
	.repeat 3, i
		lda Xoroshiro128State1+.sizeof(Xoroshiro128State1)-3+i
		pha
	.endrepeat
	ldx #.sizeof(Xoroshiro128State1)-3-1
	:
		lda Xoroshiro128State1+0, x
		sta Xoroshiro128State1+3, x
	dex
	bpl :-
	ldx #2
	:
		pla
		sta Xoroshiro128State1, x
	dex
	bpl :-

	; Step 2: left 4 bits
	lda Xoroshiro128State1+.sizeof(Xoroshiro128State1)-1
	ldx #4
	:
		asl
		.repeat .sizeof(Xoroshiro128State1), i
			rol Xoroshiro128State1+i
		.endrepeat
	dex
	bne :-

	rts

.endif
