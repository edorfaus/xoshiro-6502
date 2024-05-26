.feature underline_in_numbers

.segment "RAM"

; PRNG value, as generated by one of the output functions.
; This is clobbered by Next, Jump and LongJump.
Xoshiro128Value: .res 4

; Internal PRNG state for Xoshiro128: 4 32-bit uints
; These must be initialized to be non-zero.
Xoshiro128State0: .res 4
Xoshiro128State1: .res 4
Xoshiro128State2: .res 4
Xoshiro128State3: .res 4

.segment "LIBDATA"

.segment "LIBCODE"

; Output function for xoshiro128+ 1.0.
Xoshiro128OutputPlus:
	; result = state[0] + state[3]
	clc
	.repeat .sizeof(Xoshiro128State0), i
		lda Xoshiro128State0+i
		adc Xoshiro128State3+i
		sta Xoshiro128Value+i
	.endrepeat
	rts

; Output function for xoshiro128++ 1.0.
Xoshiro128OutputPlusPlus:
	; result = RotateLeft(state[0] + state[3], 7) + state[0]
	; 7 = 8 - 1, so one full byte minus one bit : left a byte, right 1.

	; tmp = state[0] + state[3], but rotated left by 8 bits
	clc
	.repeat .sizeof(Xoshiro128State0), i
		lda Xoshiro128State0+i
		adc Xoshiro128State3+i
		sta Xoshiro128Value+((i+1) % .sizeof(Xoshiro128State0))
	.endrepeat

	; rotate right by 1 bit
	;lda Xoshiro128Value+0 ; already last value loaded above
	lsr
	.repeat .sizeof(Xoshiro128Value), i
		ror Xoshiro128Value+.sizeof(Xoshiro128Value)-1-i
	.endrepeat

	; result = tmp + state[0]
	clc
	.repeat .sizeof(Xoshiro128Value), i
		lda Xoshiro128Value+i
		adc Xoshiro128State0+i
		sta Xoshiro128Value+i
	.endrepeat

	rts

; Output function for xoshiro128** 1.1.
Xoshiro128OutputStarStar:
	; TODO
	rts

; Advance the PRNG state (to generate a new number).
; Clobbers: A, X, Xoshiro128Value
Xoshiro128Next:
	; tmp = state[1] << 9
	; 9 = 8 + 1, so one full byte plus 1 bit.
	; No need to clear Xoshiro128Value+0, we just skip using it below.
	lda Xoshiro128State1+0
	asl
	sta Xoshiro128Value+1
	.repeat .sizeof(Xoshiro128State1)-1, i
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

Xoshiro128Jump:
	; TODO
Xoshiro128LongJump:
	; TODO
	rts
