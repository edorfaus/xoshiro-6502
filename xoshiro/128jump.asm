.include "128next.asm"

.segment "LIBDATA"

xoshiro128JumpBits:
	.byte $77, $F2, $DB, $5B, $6F, $A0, $35, $C3
	.byte $F5, $42, $D2, $D3, $87, $64, $00, $0B
xoshiro128JumpBitsLength = * - xoshiro128JumpBits

.segment "LIBCODE"

; Jump is equivalent to advancing the PRNG state 2^64 times.
; This subroutine uses quite a bit of stack space, for temporary data.
; Stack required: 21 bytes (including the return address)
; Clobbers: A, X, Y, Xoshiro128Value
Xoshiro128Jump:
	; This routine assumes that the state is stored contiguously in RAM.

	lda #0
	ldy #4*.sizeof(Xoshiro128State0)
	:
		pha
	dey
	bne :-

	ldy #xoshiro128JumpBitsLength-1
	lda #1
	@loop:
		; Check if this jump-bit is set
		pha
		and xoshiro128JumpBits, y
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
