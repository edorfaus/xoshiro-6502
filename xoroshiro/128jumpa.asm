.include "128nexta.asm"

.segment "LIBDATA"

xoroshiro128JumpABits:
	.byte $17, $08, $65, $DF, $4B, $32, $01, $FC
	.byte $DF, $90, $02, $94, $D8, $F5, $54, $A5
xoroshiro128JumpABitsLength = * - xoroshiro128JumpABits

.segment "LIBCODE"

; JumpA is equivalent to calling NextA 2^64 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 21 bytes (including the return address)
; Clobbers: A, X, Y, Xoroshiro128Value+0
Xoroshiro128JumpA:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #2*.sizeof(Xoroshiro128State0)
	:
		pha
	dey
	bne :-

	ldy #xoroshiro128JumpABitsLength-1
	sty Xoroshiro128Value+0
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		ldy Xoroshiro128Value+0
		and xoroshiro128JumpABits, y
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
