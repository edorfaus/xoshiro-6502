.include "256next.asm"

.segment "LIBDATA"

xoshiro256JumpBits:
	.byte $39, $AB, $DC, $45, $29, $B1, $66, $1C
	.byte $A9, $58, $26, $18, $E0, $3F, $C9, $AA
	.byte $D5, $A6, $12, $66, $F0, $C9, $39, $2C
	.byte $18, $0E, $C6, $D3, $3C, $FD, $0A, $BA
xoshiro256JumpBitsLength = * - xoshiro256JumpBits

.segment "LIBCODE"

; Jump is equivalent to advancing the PRNG state 2^128 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 37 bytes (including the return address)
; Clobbers: A, X, Y, Xoshiro256Value
Xoshiro256Jump:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #4*.sizeof(Xoshiro256State0)
	:
		pha
	dey
	bne :-

	ldy #xoshiro256JumpBitsLength-1
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		and xoshiro256JumpBits, y
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
