.ifndef Xoshiro128Next

.include "128vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; Clobbers: A, X, Xoshiro128Value
Xoshiro128Next:
	; tmp = state[1] << 9
	; 9 = 8 + 1, so one full byte plus 1 bit.
	; No need to clear Xoshiro128Value+0, we just skip using it below.
	lda Xoshiro128State1+0
	asl
	sta Xoshiro128Value+1
	.repeat .sizeof(Xoshiro128State1)-1-1, i
		lda Xoshiro128State1+1+i
		rol
		sta Xoshiro128Value+2+i
	.endrepeat

	; For each byte in the state words...
	ldx #.sizeof(Xoshiro128State0)-1
	:
		; state[2] ^= state[0]
		lda Xoshiro128State2+0, x
		eor Xoshiro128State0+0, x
		sta Xoshiro128State2+0, x

		; state[3] ^= state[1]
		lda Xoshiro128State3+0, x
		eor Xoshiro128State1+0, x
		sta Xoshiro128State3+0, x

		; state[1] ^= state[2]
		lda Xoshiro128State1+0, x
		eor Xoshiro128State2+0, x
		sta Xoshiro128State1+0, x

		; state[0] ^= state[3]
		lda Xoshiro128State0+0, x
		eor Xoshiro128State3+0, x
		sta Xoshiro128State0+0, x
	dex
	bpl :-

	; state[2] ^= tmp
	ldx #.sizeof(Xoshiro128State2)-1
	:
		lda Xoshiro128State2+0, x
		eor Xoshiro128Value+0, x
		sta Xoshiro128State2+0, x
	dex
	; Low byte of tmp is always 0, so we skip doing the eor for it.
	bne :-

	; state[3] = bits.RotateLeft32(state[3], 11)
	; 11 = 8 + 3, so one full byte plus 3 bits.
	; First, the full byte.
	ldx Xoshiro128State3+.sizeof(Xoshiro128State3)-1
	.repeat .sizeof(Xoshiro128State3)-1, i
		lda Xoshiro128State3+.sizeof(Xoshiro128State3)-2-i
		sta Xoshiro128State3+.sizeof(Xoshiro128State3)-1-i
	.endrepeat
	stx Xoshiro128State3+0
	; Then, the 3 bits.
	; TODO: see if this lda can be elided by reordering above.
	lda Xoshiro128State3+.sizeof(Xoshiro128State3)-1
	ldx #3
	:
		asl
		.repeat .sizeof(Xoshiro128State3), i
			rol Xoshiro128State3+i
		.endrepeat
	dex
	bne :-

	rts

.endif
