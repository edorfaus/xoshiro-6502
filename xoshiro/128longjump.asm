.include "128next.asm"

.feature underline_in_numbers

.segment "LIBDATA"

xoshiro128LongJumpBits:
	.byte $1C, $58, $06, $62, $CC, $F5, $A0, $EF
	.byte $0B, $6F, $09, $9F, $B5, $23, $95, $2E
xoshiro128LongJumpBitsLength = * - xoshiro128LongJumpBits

.segment "LIBCODE"

; LongJump is equivalent to advancing the PRNG state 2^96 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 21 bytes (including the return address)
; Clobbers: A, X, Y, Xoshiro128Value
Xoshiro128LongJump:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #4*.sizeof(Xoshiro128State0)
	:
		pha
	dey
	bne :-

	ldy #xoshiro128LongJumpBitsLength-1
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		and xoshiro128LongJumpBits, y
		beq @jumpBitNotSet
			; It is set, so mix in the current state
			tya
			pha

			tsx
			inx
			inx
			ldy #4*.sizeof(Xoshiro128State0)-1
			:
				inx
				lda Xoshiro128State0, y
				eor $0100, x
				sta $0100, x
			dey
			bpl :-

			pla
			tay

		@jumpBitNotSet:
		jsr Xoshiro128Next ; Clobbers: A, X, Xoshiro128Value

		; Move on to the next jump-bit.
		pla
		asl
		bne @loop

		lda #1
	dey
	bpl @loop

	; Set the state to the calculated new state.
	ldy #4*.sizeof(Xoshiro128State0)-1
	:
		pla
		sta Xoshiro128State0, y
	dey
	bpl :-

	rts
