.ifndef Xoshiro256Next

.include "256vars.asm"

.segment "LIBCODE"

; Advance the PRNG state (to generate a new number).
; Clobbers: A, X, Xoshiro256Value
Xoshiro256Next:
	; tmp = state[1] << 17
	; 17 = 8 + 8 + 1, so two full bytes plus 1 bit.
	; No need to clear low Xoshiro256Value, we just skip using it below.
	lda Xoshiro256State1+0
	asl
	sta Xoshiro256Value+2
	; Since it's unused, we can use this value byte as a loop counter.
	lda #.sizeof(Xoshiro256Value)-2-1
	sta Xoshiro256Value+0
	ldx #1
	:
		lda Xoshiro256State1+0, x
		rol
		sta Xoshiro256Value+2, x

		inx
		dec Xoshiro256Value+0
	bne :-

	; For each byte in the state words...
	ldx #.sizeof(Xoshiro256State0)-1
	:
		; state[2] ^= state[0]
		lda Xoshiro256State2+0, x
		eor Xoshiro256State0+0, x
		sta Xoshiro256State2+0, x

		; state[3] ^= state[1]
		lda Xoshiro256State3+0, x
		eor Xoshiro256State1+0, x
		sta Xoshiro256State3+0, x

		; state[1] ^= state[2]
		lda Xoshiro256State1+0, x
		eor Xoshiro256State2+0, x
		sta Xoshiro256State1+0, x

		; state[0] ^= state[3]
		lda Xoshiro256State0+0, x
		eor Xoshiro256State3+0, x
		sta Xoshiro256State0+0, x
	dex
	bpl :-

	; state[2] ^= tmp
	ldx #.sizeof(Xoshiro256State2)-1-1
	:
		lda Xoshiro256State2+1, x
		eor Xoshiro256Value+1, x
		sta Xoshiro256State2+1, x
	dex
	; Low bytes of tmp are always 0, so we skip doing the eor for them.
	bne :-

	; state[3] = bits.RotateLeft32(state[3], 45)
	; 45 = 5*8 + 5, so 5 full bytes plus 5 bits.
	; On the other hand, the state word is only 8 bytes (64 bits) long,
	; so if we rotate right instead, we need to rotate by 64-45=19 bits.
	; 19 = 8 + 8 + 3, so two full bytes plus 3 bits, which is shorter.
	; First, the two full bytes.
	lda Xoshiro256State3+0
	pha
	lda Xoshiro256State3+1
	pha
	ldx #0
	:
		lda Xoshiro256State3+2, x
		sta Xoshiro256State3+0, x

		inx
		cpx #.sizeof(Xoshiro256State3)-2
	bne :-
	pla
	sta Xoshiro256State3+.sizeof(Xoshiro256State3)-1
	pla
	sta Xoshiro256State3+.sizeof(Xoshiro256State3)-2
	; Then, the 3 bits.
	lda Xoshiro256State3+0
	ldx #3
	:
		lsr
		.repeat .sizeof(Xoshiro256State3), i
			ror Xoshiro256State3+.sizeof(Xoshiro256State3)-1-i
		.endrepeat
	dex
	bne :-

	rts

.endif
