.include "256next.asm"

.segment "LIBDATA"

xoshiro256LongJumpBits:
	.byte $39, $10, $9B, $B0, $2A, $CB, $E6, $35
	.byte $77, $71, $00, $69, $85, $4E, $E2, $41
	.byte $C5, $00, $4E, $44, $1C, $52, $2F, $B3
	.byte $76, $E1, $5D, $3E, $FE, $FD, $CB, $BF
xoshiro256LongJumpBitsLength = * - xoshiro256LongJumpBits

.segment "LIBCODE"

; LongJump is equivalent to advancing the PRNG state 2^192 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 37 bytes (including the return address)
; Clobbers: A, X, Y, Xoshiro256Value
Xoshiro256LongJump:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #4*.sizeof(Xoshiro256State0)
	:
		pha
	dey
	bne :-

	ldy #xoshiro256LongJumpBitsLength-1
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		and xoshiro256LongJumpBits, y
		beq @jumpBitNotSet
			; It is set, so mix in the current state
			tya
			pha

			tsx
			inx
			inx
			ldy #4*.sizeof(Xoshiro256State0)-1
			:
				inx
				lda Xoshiro256State0, y
				eor $0100, x
				sta $0100, x
			dey
			bpl :-

			pla
			tay

		@jumpBitNotSet:
		jsr Xoshiro256Next ; Clobbers: A, X, Xoshiro256Value

		; Move on to the next jump-bit.
		pla
		asl
		bne @loop

		lda #1
	dey
	bpl @loop

	; Set the state to the calculated new state.
	ldy #4*.sizeof(Xoshiro256State0)-1
	:
		pla
		sta Xoshiro256State0, y
	dey
	bpl :-

	rts
