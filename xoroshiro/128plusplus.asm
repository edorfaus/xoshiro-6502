.include "128vars.asm"

.segment "LIBCODE"

; Output function for xoroshiro128++ 1.0.
; This expects the state to be advanced with NextB.
; Clobbers: A, X, Y
Xoroshiro128PlusPlus:
	; tmp = state[0] + state[1]
	ldx #0
	ldy #.sizeof(Xoroshiro128Value)
	clc
	:
		lda Xoroshiro128State0, x
		adc Xoroshiro128State1, x
		sta Xoroshiro128Value, x
		inx
	dey
	bne :-

	; tmp = RotateLeft(tmp, 17)
	; 17 = 2*8 + 1, so 2 whole bytes plus one bit
	; Step 1: left 2 bytes
	ldy Xoroshiro128Value+.sizeof(Xoroshiro128Value)-1
	lda Xoroshiro128Value+.sizeof(Xoroshiro128Value)-2
	pha
	ldx #.sizeof(Xoroshiro128Value)-2-1
	:
		lda Xoroshiro128Value+0, x
		sta Xoroshiro128Value+2, x
	dex
	bpl :-
	sty Xoroshiro128Value+1
	pla
	sta Xoroshiro128Value+0

	; Step 2: left 1 bit
	lda Xoroshiro128Value+.sizeof(Xoroshiro128Value)-1
	asl
	.repeat .sizeof(Xoroshiro128Value), i
		rol Xoroshiro128Value+i
	.endrepeat

	; result = tmp + state[0]
	ldx #0
	ldy #.sizeof(Xoroshiro128Value)
	clc
	:
		lda Xoroshiro128Value, x
		adc Xoroshiro128State0, x
		sta Xoroshiro128Value, x
		inx
	dey
	bne :-

	rts
