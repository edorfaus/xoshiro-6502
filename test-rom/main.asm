.include "core.asm"
.include "graphics.asm"
.include "impl-sizes.asm"

.segment "LIBCODE"
.align $100

printSizeSep top
sizeGroupStart combined

sizeGroupStart Xoshiro128
.include "../xoshiro/128plus.asm"
printSize Xoshiro128Plus
.include "../xoshiro/128plusplus.asm"
printSize Xoshiro128PlusPlus
.include "../xoshiro/128starstar.asm"
printSize Xoshiro128StarStar
.include "../xoshiro/128next.asm"
printSize Xoshiro128Next
.include "../xoshiro/128jump.asm"
printSize Xoshiro128Jump
.include "../xoshiro/128longjump.asm"
printSize Xoshiro128LongJump
sizeGroupEnd Xoshiro128

printSizeSep
sizeGroupStart Xoshiro256
.include "../xoshiro/256plus.asm"
printSize Xoshiro256Plus
.include "../xoshiro/256plusplus.asm"
printSize Xoshiro256PlusPlus
.include "../xoshiro/256starstar.asm"
printSize Xoshiro256StarStar
.include "../xoshiro/256next.asm"
printSize Xoshiro256Next
.include "../xoshiro/256jump.asm"
printSize Xoshiro256Jump
.include "../xoshiro/256longjump.asm"
printSize Xoshiro256LongJump
sizeGroupEnd Xoshiro256

printSizeSep
sizeGroupStart Xoroshiro64
.include "../xoroshiro/64star.asm"
printSize Xoroshiro64Star
.include "../xoroshiro/64starstar.asm"
printSize Xoroshiro64StarStar
.include "../xoroshiro/64next.asm"
printSize Xoroshiro64Next
sizeGroupEnd Xoroshiro64

printSizeSep
sizeGroupStart Xoroshiro128
sizeGroupStart Xoroshiro128A
.include "../xoroshiro/128plus.asm"
printSize Xoroshiro128Plus
.include "../xoroshiro/128starstar.asm"
printSize Xoroshiro128StarStar
.include "../xoroshiro/128nexta.asm"
printSize Xoroshiro128NextA
.include "../xoroshiro/128jumpa.asm"
printSize Xoroshiro128JumpA
.include "../xoroshiro/128longjumpa.asm"
printSize Xoroshiro128LongJumpA
sizeGroupEnd Xoroshiro128A

printSizeSep
sizeGroupStart Xoroshiro128B
.include "../xoroshiro/128plusplus.asm"
printSize Xoroshiro128PlusPlus
.include "../xoroshiro/128nextb.asm"
printSize Xoroshiro128NextB
.include "../xoroshiro/128jumpb.asm"
printSize Xoroshiro128JumpB
.include "../xoroshiro/128longjumpb.asm"
printSize Xoroshiro128LongJumpB
sizeGroupEnd Xoroshiro128B
sizeGroupEnd Xoroshiro128

printSizeSep
sizeGroupEnd combined

printSizeSep bottom

; --------

totalSize tests:         ZP 11, RAM  0, code  739, data 1384; total 2134

sizeGroupStart tests

.include "testdata.asm"

.segment "ZEROPAGE"
verifyValues: .res 2
verifyStates: .res 2

currentValue: .res 2
currentState: .res 2
valueSize: .res 1
stateSize: .res 1

testLoopCounter: .res 1

.segment "CODE"

Main:
	jsr TestXoshiro128
	jsr WriteNewline
	jsr TestXoshiro256
	jsr WriteNewline
	jsr TestXoroshiro64
	jsr WriteNewline
	jsr TestXoroshiro128A
	jsr WriteNewline
	jsr TestXoroshiro128B

	; Write an end-of-tests marker.
	jsr WriteNewline
	jsr WriteNewline
	jsr WriteSeparator
	jsr WriteTile

TestsDone:
	jmp TestsDone

.align $10
; --------

; Shared code for the tests below.

; This code makes some assumptions about the layout of memory, e.g. that
; the state words for each PRNG are stored consecutively in RAM.

; Initialize the currentValue, currentState, valueSize and stateSize
; variables according to the given arguments.
; Clobbers: A
.macro initCurrent valueVar, stateVar, stateWordCount
	lda #.lobyte(valueVar)
	sta currentValue+0
	lda #.hibyte(valueVar)
	sta currentValue+1

	lda #.sizeof(valueVar)
	sta valueSize

	lda #.lobyte(stateVar)
	sta currentState+0
	lda #.hibyte(stateVar)
	sta currentState+1

	lda #.sizeof(stateVar) * stateWordCount
	sta stateSize
.endmacro

; Initialize the verifyValues and verifyStates variables to the given
; arguments.
; Clobbers: A
.macro initVerify values, states
	lda #.lobyte(values)
	sta verifyValues+0
	lda #.hibyte(values)
	sta verifyValues+1

	lda #.lobyte(states)
	sta verifyStates+0
	lda #.hibyte(states)
	sta verifyStates+1
.endmacro

; Initializes the current state, using bytes from Seed.
; Clobbers: A, Y
initState:
	ldy stateSize
	dey
	:
		lda Seed, y
		sta (currentState), y
		dey
	bpl :-
	rts

; Verify that the current value is equal to the expected value, and
; advance the expected value to the next entry in the list.
; Clobbers: A, Y
verifyValue:
	ldy valueSize
	dey
	@loop:
		lda (verifyValues), y
		cmp (currentValue), y
		bne @failed
	dey
	bpl @loop
	@failed:
	clc
	lda verifyValues+0
	adc valueSize
	sta verifyValues+0
	bcc :+
		inc verifyValues+1
	:
	jmp showVerifyResult

; Advance the expected state to the next entry in the list, and verify
; that the current state is equal to that expected state.
; Clobbers: A, Y
verifyNextState:
	clc
	lda verifyStates+0
	adc stateSize
	sta verifyStates+0
	bcc :+
		inc verifyStates+1
	:
	; Fall through to verifySameState

; Verify that the current state is equal to the expected state.
; Clobbers: A, Y
verifySameState:
	ldy stateSize
	dey
	@loop:
		lda (verifyStates), y
		cmp (currentState), y
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

.align $40
; --------

TestXoshiro128:
	jsr InitTest_Xoshiro128
	jsr initState

	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128Plus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro128PlusPlus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro128StarStar
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro128Next
		jsr verifyNextState

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128Jump
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128LongJump
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoshiro128:
	initCurrent Xoshiro128Value, Xoshiro128State0, 4
	initVerify VerifyValuesXoshiro128, VerifyStatesXoshiro128
	rts

; --------

TestXoshiro256:
	jsr InitTest_Xoshiro256
	jsr initState

	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256Plus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro256PlusPlus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro256StarStar
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoshiro256Next
		jsr verifyNextState

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256Jump
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256LongJump
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoshiro256:
	initCurrent Xoshiro256Value, Xoshiro256State0, 4
	initVerify VerifyValuesXoshiro256, VerifyStatesXoshiro256
	rts

; --------

TestXoroshiro64:
	jsr InitTest_Xoroshiro64
	jsr initState

	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro64Star
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoroshiro64StarStar
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoroshiro64Next
		jsr verifyNextState

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	rts

; Clobbers: A
InitTest_Xoroshiro64:
	initCurrent Xoroshiro64Value, Xoroshiro64State0, 2
	initVerify VerifyValuesXoroshiro64, VerifyStatesXoroshiro64
	rts

; --------

TestXoroshiro128A:
	jsr InitTest_Xoroshiro128A
	jsr initState

	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128Plus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoroshiro128StarStar
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoroshiro128NextA
		jsr verifyNextState

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128JumpA
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128LongJumpA
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoroshiro128A:
	initCurrent Xoroshiro128Value, Xoroshiro128State0, 2
	initVerify VerifyValuesXoroshiro128A, VerifyStatesXoroshiro128A
	rts

; --------

TestXoroshiro128B:
	jsr InitTest_Xoroshiro128B
	jsr initState

	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128PlusPlus
		jsr verifyValue
		jsr verifySameState

		jsr WriteBlank

		jsr Xoroshiro128NextB
		jsr verifyNextState

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128JumpB
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr initState
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128LongJumpB
		jsr verifyNextState
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoroshiro128B:
	jsr InitTest_Xoroshiro128A ; Reuse the initCurrent code
	;initCurrent Xoroshiro128Value, Xoroshiro128State0, 2
	initVerify VerifyValuesXoroshiro128B, VerifyStatesXoroshiro128B
	rts

sizeGroupEnd tests
