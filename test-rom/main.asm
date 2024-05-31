.include "core.asm"
.include "graphics.asm"
.include "testdata.asm"

.include "../xoshiro/128plus.asm"
.include "../xoshiro/128plusplus.asm"
.include "../xoshiro/128starstar.asm"
.include "../xoshiro/128next.asm"

.segment "ZEROPAGE"
verifyValues: .res 2
verifyStates: .res 2

testLoopCounter: .res 1

.segment "CODE"

Main:
	jsr InitState_Xoshiro128

	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128Plus
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr Xoshiro128PlusPlus
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr Xoshiro128StarStar
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr Xoshiro128Next
		jsr verifyNextStateXoshiro128

		lda #3
		jsr WriteTile

	dec testLoopCounter
	bne :-

	jsr WriteTile

:	jmp :-

; Clobbers: A, Y
InitState_Xoshiro128:
	; This assumes that the state variables are consecutive in memory.
	ldy #4*.sizeof(Xoshiro128State0)-1
	:
		lda Seed, y
		sta Xoshiro128State0, y
		dey
	bpl :-

	lda #.lobyte(VerifyValuesXoshiro128)
	sta verifyValues+0
	lda #.hibyte(VerifyValuesXoshiro128)
	sta verifyValues+1

	lda #.lobyte(VerifyStatesXoshiro128)
	sta verifyStates+0
	lda #.hibyte(VerifyStatesXoshiro128)
	sta verifyStates+1

	rts

; Clobbers: A, Y
verifyValueXoshiro128:
	ldy #.sizeof(Xoshiro128Value)-1
	@loop:
		lda (verifyValues), y
		cmp Xoshiro128Value, y
		bne @failed
	dey
	bpl @loop
	@failed:
	clc
	lda verifyValues+0
	adc #.sizeof(Xoshiro128Value)
	sta verifyValues+0
	bcc :+
		inc verifyValues+1
	:
	jmp showVerifyResult

; Clobbers: A, Y
verifyNextStateXoshiro128:
	clc
	lda verifyStates+0
	adc #4*.sizeof(Xoshiro128State0)
	sta verifyStates+0
	bcc :+
		inc verifyStates+1
	:
	; Fall through to verifySameStateXoshiro128

; Clobbers: A, Y
verifySameStateXoshiro128:
	; This assumes that the state variables are consecutive in memory.
	ldy #4*.sizeof(Xoshiro128State0)-1
	@loop:
		lda (verifyStates), y
		cmp Xoshiro128State0, y
		bne showVerifyResult
	dey
	bpl @loop
	; Fall through to showVerifyResult

; Clobbers: A
showVerifyResult:
	lda #1
	cpy #$FF
	beq :+
		lda #2
	:
	jmp WriteTile
