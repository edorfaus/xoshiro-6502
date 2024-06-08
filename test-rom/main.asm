.include "core.asm"
.include "graphics.asm"
.include "testdata.asm"

; If set to 1, all sizes are shown.
; If set to anything else, changed sizes are shown.
;printSizes = 1

.macro printSizeSep where
	.if .defined(printSizes)
		.if printSizes = 1 || (!.blank({where}))
			.out ""
		.endif
	.endif
.endmacro

.ifndef printSizes
.macro printSize lbl
.endmacro
.else

size_Xoshiro128Plus     =  38
size_Xoshiro128PlusPlus =  88
size_Xoshiro128StarStar = 171
size_Xoshiro128Next     = 122
size_Xoshiro128Jump     =  62
size_Xoshiro128LongJump =  62

size_Xoshiro256Plus     =  74
size_Xoshiro256PlusPlus = 175
size_Xoshiro256StarStar = 331
size_Xoshiro256Next     = 145
size_Xoshiro256Jump     =  62
size_Xoshiro256LongJump =  62

size_Xoroshiro64Star      = 100 ; -12
size_Xoroshiro64StarStar  =  67
size_Xoroshiro64Next      = 120

.macro printSize lbl
	.ifndef lbl
		.error .concat("Label not defined: ", .string(lbl))
		.exitmacro
	.endif
	.define sz_lbl .ident(.concat("size_", .string(lbl)))
	.ifdef sz_lbl
		.if * - lbl - sz_lbl = 0 && printSizes <> 1
			.undefine sz_lbl
			.exitmacro
		.endif
		.define diff .sprintf(" ; %+3d", * - lbl - sz_lbl)
	.else
		.define diff ""
	.endif
	.out .sprintf("%26s = %3d%s", .string(sz_lbl), * - lbl, diff)
	.undefine diff
	.undefine sz_lbl
.endmacro

.endif

printSizeSep top

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

printSizeSep
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

printSizeSep
.include "../xoroshiro/64star.asm"
printSize Xoroshiro64Star
.include "../xoroshiro/64starstar.asm"
printSize Xoroshiro64StarStar
.include "../xoroshiro/64next.asm"
printSize Xoroshiro64Next

printSizeSep
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

printSizeSep bottom

.segment "ZEROPAGE"
verifyValues: .res 2
verifyStates: .res 2

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

TestsDone:
	jmp TestsDone

.align $40
; --------

TestXoshiro128:
	jsr InitTest_Xoshiro128
	jsr InitState_Xoshiro128

	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128Plus
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr WriteBlank

		jsr Xoshiro128PlusPlus
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr WriteBlank

		jsr Xoshiro128StarStar
		jsr verifyValueXoshiro128
		jsr verifySameStateXoshiro128

		jsr WriteBlank

		jsr Xoshiro128Next
		jsr verifyNextStateXoshiro128

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr InitState_Xoshiro128
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128Jump
		jsr verifyNextStateXoshiro128
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr InitState_Xoshiro128
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro128LongJump
		jsr verifyNextStateXoshiro128
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A, Y
InitState_Xoshiro128:
	; This assumes that the state variables are consecutive in memory.
	ldy #4*.sizeof(Xoshiro128State0)-1
	:
		lda Seed, y
		sta Xoshiro128State0, y
		dey
	bpl :-
	rts

; Clobbers: A
InitTest_Xoshiro128:
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

; --------

TestXoshiro256:
	jsr InitTest_Xoshiro256
	jsr InitState_Xoshiro256

	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256Plus
		jsr verifyValueXoshiro256
		jsr verifySameStateXoshiro256

		jsr WriteBlank

		jsr Xoshiro256PlusPlus
		jsr verifyValueXoshiro256
		jsr verifySameStateXoshiro256

		jsr WriteBlank

		jsr Xoshiro256StarStar
		jsr verifyValueXoshiro256
		jsr verifySameStateXoshiro256

		jsr WriteBlank

		jsr Xoshiro256Next
		jsr verifyNextStateXoshiro256

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr InitState_Xoshiro256
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256Jump
		jsr verifyNextStateXoshiro256
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr InitState_Xoshiro256
	lda #4
	sta testLoopCounter
	:
		jsr Xoshiro256LongJump
		jsr verifyNextStateXoshiro256
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoshiro256:
	lda #.lobyte(VerifyValuesXoshiro256)
	sta verifyValues+0
	lda #.hibyte(VerifyValuesXoshiro256)
	sta verifyValues+1

	lda #.lobyte(VerifyStatesXoshiro256)
	sta verifyStates+0
	lda #.hibyte(VerifyStatesXoshiro256)
	sta verifyStates+1

	rts

; Clobbers: A, Y
InitState_Xoshiro256:
	; This assumes that the state variables are consecutive in memory.
	ldy #4*.sizeof(Xoshiro256State0)-1
	:
		lda Seed, y
		sta Xoshiro256State0, y
		dey
	bpl :-
	rts

; Clobbers: A, Y
verifyValueXoshiro256:
	ldy #.sizeof(Xoshiro256Value)-1
	@loop:
		lda (verifyValues), y
		cmp Xoshiro256Value, y
		bne @failed
	dey
	bpl @loop
	@failed:
	clc
	lda verifyValues+0
	adc #.sizeof(Xoshiro256Value)
	sta verifyValues+0
	bcc :+
		inc verifyValues+1
	:
	jmp showVerifyResult

; Clobbers: A, Y
verifyNextStateXoshiro256:
	clc
	lda verifyStates+0
	adc #4*.sizeof(Xoshiro256State0)
	sta verifyStates+0
	bcc :+
		inc verifyStates+1
	:
	; Fall through to verifySameStateXoshiro256

; Clobbers: A, Y
verifySameStateXoshiro256:
	; This assumes that the state variables are consecutive in memory.
	ldy #4*.sizeof(Xoshiro256State0)-1
	@loop:
		lda (verifyStates), y
		cmp Xoshiro256State0, y
		bne @failed
	dey
	bpl @loop
	@failed:
	jmp showVerifyResult

; --------

TestXoroshiro64:
	jsr InitTest_Xoroshiro64
	jsr InitState_Xoroshiro64

	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro64Star
		jsr verifyValueXoroshiro64
		jsr verifySameStateXoroshiro64

		jsr WriteBlank

		jsr Xoroshiro64StarStar
		jsr verifyValueXoroshiro64
		jsr verifySameStateXoroshiro64

		jsr WriteBlank

		jsr Xoroshiro64Next
		jsr verifyNextStateXoroshiro64

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	rts

; Clobbers: A, Y
InitState_Xoroshiro64:
	; This assumes that the state variables are consecutive in memory.
	ldy #2*.sizeof(Xoroshiro64State0)-1
	:
		lda Seed, y
		sta Xoroshiro64State0, y
		dey
	bpl :-
	rts

; Clobbers: A
InitTest_Xoroshiro64:
	lda #.lobyte(VerifyValuesXoroshiro64)
	sta verifyValues+0
	lda #.hibyte(VerifyValuesXoroshiro64)
	sta verifyValues+1

	lda #.lobyte(VerifyStatesXoroshiro64)
	sta verifyStates+0
	lda #.hibyte(VerifyStatesXoroshiro64)
	sta verifyStates+1

	rts

; Clobbers: A, Y
verifyValueXoroshiro64:
	ldy #.sizeof(Xoroshiro64Value)-1
	@loop:
		lda (verifyValues), y
		cmp Xoroshiro64Value, y
		bne @failed
	dey
	bpl @loop
	@failed:
	clc
	lda verifyValues+0
	adc #.sizeof(Xoroshiro64Value)
	sta verifyValues+0
	bcc :+
		inc verifyValues+1
	:
	jmp showVerifyResult

; Clobbers: A, Y
verifyNextStateXoroshiro64:
	clc
	lda verifyStates+0
	adc #2*.sizeof(Xoroshiro64State0)
	sta verifyStates+0
	bcc :+
		inc verifyStates+1
	:
	; Fall through to verifySameStateXoroshiro64

; Clobbers: A, Y
verifySameStateXoroshiro64:
	; This assumes that the state variables are consecutive in memory.
	ldy #2*.sizeof(Xoroshiro64State0)-1
	@loop:
		lda (verifyStates), y
		cmp Xoroshiro64State0, y
		bne @failed
	dey
	bpl @loop
	@failed:
	jmp showVerifyResult

; --------

TestXoroshiro128A:
	jsr InitTest_Xoroshiro128A
	jsr InitState_Xoroshiro128

	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128Plus
		jsr verifyValueXoroshiro128
		jsr verifySameStateXoroshiro128

		jsr WriteBlank

		jsr Xoroshiro128StarStar
		jsr verifyValueXoroshiro128
		jsr verifySameStateXoroshiro128

		jsr WriteBlank

		jsr Xoroshiro128NextA
		jsr verifyNextStateXoroshiro128

		jsr WriteSeparator

	dec testLoopCounter
	bne :-

	; Note: we are here assuming that the jump and long-jump test states
	; are stored directly after the test states used above.
	; If this stops being true, add code to reinitialize verifyStates.

	jsr InitState_Xoroshiro128
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128JumpA
		jsr verifyNextStateXoroshiro128
	dec testLoopCounter
	bne :-

	jsr WriteSeparator

	jsr InitState_Xoroshiro128
	lda #4
	sta testLoopCounter
	:
		jsr Xoroshiro128LongJumpA
		jsr verifyNextStateXoroshiro128
	dec testLoopCounter
	bne :-

	jsr WriteSeparator
	jsr WriteTile

	rts

; Clobbers: A
InitTest_Xoroshiro128A:
	lda #.lobyte(VerifyValuesXoroshiro128A)
	sta verifyValues+0
	lda #.hibyte(VerifyValuesXoroshiro128A)
	sta verifyValues+1

	lda #.lobyte(VerifyStatesXoroshiro128A)
	sta verifyStates+0
	lda #.hibyte(VerifyStatesXoroshiro128A)
	sta verifyStates+1

	rts

; Clobbers: A, Y
InitState_Xoroshiro128:
	; This assumes that the state variables are consecutive in memory.
	ldy #2*.sizeof(Xoroshiro128State0)-1
	:
		lda Seed, y
		sta Xoroshiro128State0, y
		dey
	bpl :-
	rts

; Clobbers: A, Y
verifyValueXoroshiro128:
	ldy #.sizeof(Xoroshiro128Value)-1
	@loop:
		lda (verifyValues), y
		cmp Xoroshiro128Value, y
		bne @failed
	dey
	bpl @loop
	@failed:
	clc
	lda verifyValues+0
	adc #.sizeof(Xoroshiro128Value)
	sta verifyValues+0
	bcc :+
		inc verifyValues+1
	:
	jmp showVerifyResult

; Clobbers: A, Y
verifyNextStateXoroshiro128:
	clc
	lda verifyStates+0
	adc #2*.sizeof(Xoroshiro128State0)
	sta verifyStates+0
	bcc :+
		inc verifyStates+1
	:
	; Fall through to verifySameStateXoroshiro128

; Clobbers: A, Y
verifySameStateXoroshiro128:
	; This assumes that the state variables are consecutive in memory.
	ldy #2*.sizeof(Xoroshiro128State0)-1
	@loop:
		lda (verifyStates), y
		cmp Xoroshiro128State0, y
		bne @failed
	dey
	bpl @loop
	@failed:
	jmp showVerifyResult
