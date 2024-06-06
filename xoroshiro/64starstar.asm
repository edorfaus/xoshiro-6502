.include "64star.asm"

.segment "LIBCODE"

; Output function for xoroshiro64** 1.0.
; Clobbers: A, X, Y
Xoroshiro64StarStar:
	; tmp = state[0] * $9E3779BB
	jsr Xoroshiro64Star

	; result = RotateLeft(tmp, 5) * 5
	; For rotate, 5 == 8 - 3, so one byte left then 3 bits right.
	; For multiply, tmp * 5 == tmp * 4 + tmp = tmp << 2 + tmp
	; Shift by 2 is the same as rotating by 2 and masking off 2 bits.
	; Since the <<2 is after rot(5), that ends up as rot(5+2) = rot(7).
	; 7 = 8 - 1, so we will get there on the way to 8 - 3. Thus, we can
	; just keep that value, masking off the 2 bits, to avoid needing to
	; do the <<2 part separately.

	; Step 1: move left 1 byte, and right 1 bit, saving in two places.
	lda Xoroshiro64Value+.sizeof(Xoroshiro64Value)-1
	tay
	lsr
	ldx #.sizeof(Xoroshiro64Value)-1-1
	:
		lda Xoroshiro64Value+0, x
		ror
		pha
		sta Xoroshiro64Value+1, x
	dex
	bpl :-
	tya
	ror
	sta Xoroshiro64Value+0
	and #%1111_1100
	pha

	; Step 2: rotate 2 more bits right
	lda Xoroshiro64Value+0
	ldx #2
	:
		lsr
		.repeat .sizeof(Xoroshiro64Value), i
			ror Xoroshiro64Value+.sizeof(Xoroshiro64Value)-1-i
		.endrepeat
	dex
	bne :-

	; Step 3: result = tmp + tmp << 2 (using the above values for both)
	clc
	ldx #.sizeof(Xoroshiro64Value)
	ldy #0
	:
		pla
		adc Xoroshiro64Value, y
		sta Xoroshiro64Value, y
		iny
	dex
	bne :-

	rts
