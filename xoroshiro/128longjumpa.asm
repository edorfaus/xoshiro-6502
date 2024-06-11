.include "128nexta.asm"

.segment "LIBDATA"

xoroshiro128LongJumpABits:
	.byte $DD, $DF, $9B, $10, $90, $AA, $7A, $C1
	.byte $D2, $A9, $8B, $26, $62, $5E, $EE, $7B
xoroshiro128LongJumpABitsLength = * - xoroshiro128LongJumpABits

.segment "LIBCODE"

; LongJumpA is equivalent to calling NextA 2^96 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 21 bytes (including the return address)
; Clobbers: A, X, Y, Xoroshiro128Value+0
Xoroshiro128LongJumpA:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #2*.sizeof(Xoroshiro128State0)
	:
		pha
	dey
	bne :-

	ldy #xoroshiro128LongJumpABitsLength-1
	sty Xoroshiro128Value+0
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		ldy Xoroshiro128Value+0
		and xoroshiro128LongJumpABits, y
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

		jsr Xoroshiro128NextA ; Clobbers: A, X, Y

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
