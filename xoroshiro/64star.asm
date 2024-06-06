.include "64vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro64* 1.0.
; Clobbers: A, X, Y
Xoroshiro64Star:
	; result = state[0] * $9E3779BB

	; Put a temporary result area on the stack, and clear the result.
	lda #0
	ldy #.sizeof(Xoroshiro64Value)-1
	:
		pha
		sta Xoroshiro64Value, y
	dey
	bpl :-

	; Put the second factor on the stack. We need it to be modifiable.
	lda #$9E
	pha
	lda #$37
	pha
	lda #$79
	pha
	lda #$BB
	pha

	; Get stack pointer into X to use for indexing the temp vars.
	tsx
	inx ; TODO: move the tsx up above the previous pha to save this inx

	@num2 = $0100
	@tmp = @num2 + 4

	ldy #4*8 ; number of bits in @num2
	@loop:
		; Get low bit of @num2
		lsr @num2+3, x
		ror @num2+2, x
		ror @num2+1, x
		ror @num2+0, x
		bcc @noAdd
			; The bit was 1, so add the first factor to the result.
			clc
			.repeat .sizeof(Xoroshiro64Value), i
				lda Xoroshiro64State0+i
				adc @tmp+i, x
				sta @tmp+i, x
			.endrepeat
		@noAdd:
		.repeat .sizeof(Xoroshiro64Value), i
			ror @tmp+.sizeof(Xoroshiro64Value)-1-i, x
		.endrepeat
		.repeat .sizeof(Xoroshiro64Value), i
			ror Xoroshiro64Value+.sizeof(Xoroshiro64Value)-1-i
		.endrepeat
	dey
	bne @loop

	; Pop the temporary values from the stack
	txa
	clc
	adc #4-1+.sizeof(Xoroshiro64Value)
	tax
	txs

	rts
