.include "core.asm"
.include "graphics.asm"

.include "../xoshiro/128plus.asm"
.include "../xoshiro/128next.asm"

.segment "CODE"

Main:
	jsr Xoshiro128Plus
	jsr Xoshiro128Next

	lda #1
	jsr WriteTile

	lda #2
	jsr WriteTile

	lda #3
	jsr WriteTile

:	jmp :-
