.ifndef Xoroshiro64Star

.include "64vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro64* 1.0.
; Clobbers: A, X, Y
Xoroshiro64Star:
	; result = state[0] * $9E3779BB

	; Push the state word to the stack, to shift single bits off it.
	ldy #.sizeof(Xoroshiro64Value)-1
	:
		lda Xoroshiro64State0, y
		pha
	dey
	bpl :-

	; This sentinel bit allows the @loop exit to not need to use Y.
	lda #$80
	sta Xoroshiro64Value+.sizeof(Xoroshiro64Value)-1

	; Clear the rest of the result word.
	asl ; lda #0
	.repeat .sizeof(Xoroshiro64Value)-1, i
		sta Xoroshiro64Value+i
	.endrepeat

	; Push a temporary result area to the stack.
	; This is shorter than value by 1 byte due to using A for high byte.
	.repeat .sizeof(Xoroshiro64Value)-1-1
		pha
	.endrepeat
	; Get stack pointer into X to use for indexing the temp vars.
	tsx
	pha

	@tmp = $0100
	@state = @tmp + .sizeof(Xoroshiro64Value) - 1

	@loop:
		; Get the next lowest bit of the state factor
		lsr @state+.sizeof(Xoroshiro64Value)-1, x
		.repeat .sizeof(Xoroshiro64Value)-1, i
			ror @state+.sizeof(Xoroshiro64Value)-1-1-i, x
		.endrepeat
		bcc @noAdd
			; The bit was 1, so add the fixed factor to the result.
			tay

			lda @tmp+0, x
			adc #$BB-1 ; -1 to account for carry being set
			sta @tmp+0, x

			lda @tmp+1, x
			adc #$79
			sta @tmp+1, x

			lda @tmp+2, x
			adc #$37
			sta @tmp+2, x

			tya
			adc #$9E
		@noAdd:
		ror a
		.repeat .sizeof(Xoroshiro64Value)-1, i
			ror @tmp+.sizeof(Xoroshiro64Value)-1-1-i, x
		.endrepeat
		.repeat .sizeof(Xoroshiro64Value), i
			ror Xoroshiro64Value+.sizeof(Xoroshiro64Value)-1-i
		.endrepeat
	bcc @loop

	; Pop the temporary values from the stack
	txa
	; -1 for @tmp being shorter, -1 for x vs sp offset, -1 for carry=1.
	adc #2*.sizeof(Xoroshiro64Value)-1-1-1
	tax
	txs

	rts

.endif
