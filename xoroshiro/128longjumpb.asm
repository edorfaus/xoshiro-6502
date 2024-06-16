.include "128nextb.asm"

.segment "LIBDATA"

xoroshiro128LongJumpBBits:
	.byte $9C, $6E, $68, $77, $73, $6C, $46, $E3
	.byte $36, $0F, $D5, $F2, $CF, $8D, $5D, $99
xoroshiro128LongJumpBBitsLength = * - xoroshiro128LongJumpBBits

.segment "LIBCODE"

; LongJumpB is equivalent to calling NextB 2^96 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 21 bytes (including the return address)
; Clobbers: A, X, Y, Xoroshiro128Value+0
Xoroshiro128LongJumpB:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #2*.sizeof(Xoroshiro128State0)
	:
		pha
	dey
	bne :-

	ldy #xoroshiro128LongJumpBBitsLength-1
	sty Xoroshiro128Value+0
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		ldy Xoroshiro128Value+0
		and xoroshiro128LongJumpBBits, y
		beq @jumpBitNotSet
			; It is set, so mix in the current state
			tsx
			inx
			ldy #2*.sizeof(Xoroshiro128State0)-1
			:
				inx
				lda Xoroshiro128State0, y
				eor $0100, x
				sta $0100, x
			dey
			bpl :-
		@jumpBitNotSet:

		jsr Xoroshiro128NextB ; Clobbers: A, X, Y

		; Move on to the next jump-bit.
		pla
		asl
		bne @loop

		lda #1
		dec Xoroshiro128Value+0
	bpl @loop

	; Set the state to the calculated new state.
	ldy #2*.sizeof(Xoroshiro128State0)-1
	:
		pla
		sta Xoroshiro128State0, y
	dey
	bpl :-

	rts
