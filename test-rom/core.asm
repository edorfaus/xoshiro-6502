.include "nes2header.inc"

nes2mapper 0
nes2prg 2 * 16 * 1024
nes2chr 1 * 8 * 1024
nes2mirror 'V'
nes2tv 'N'
nes2end

.feature underline_in_numbers

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

.segment "VECTORS"
	.word NMI, RESET, IRQ

.segment "ZEROPAGE"

nmiPpuAddr: .res 2
nmiPpuData: .res 1
nmiPpuWrite: .res 1

.segment "LIBCODE"

RESET:
	sei
	cld
	ldx #%0100_0000
	stx $4017
	ldx #$FF
	txs
	inx
	stx $4010
	stx $4015
	txa

	; This code is repeated several times here, because the PPU might
	; (or might not) ignore it until about a frame has passed, and we
	; want it to take effect as quickly as possible, for a black screen.
	ldy #%0000_0100
	sty PPUCTRL
	sta PPUMASK
	ldy #$3F
	sty PPUADDR
	sta PPUADDR
	sty PPUDATA

	bit PPUSTATUS
	:
		bit PPUSTATUS
	bpl :-

	@clearRamLoop:
		ldy #%0000_0100
		sty PPUCTRL
		sta PPUMASK
		ldy #$3F
		sty PPUADDR
		sta PPUADDR
		sty PPUDATA

		sta $0000, x
		sta $0100, x
		sta $0200, x
		sta $0300, x
		sta $0400, x
		sta $0500, x
		sta $0600, x
		sta $0700, x
	inx
	bne @clearRamLoop

	:
		bit PPUSTATUS
	bpl :-

	sta PPUCTRL
	sta PPUMASK

@writePalettes:
	;ldy #$3F
	sty PPUADDR
	sta PPUADDR
	ldx #8
	:
		ldy #$0F
		sty PPUDATA
		ldy #$2A
		sty PPUDATA
		ldy #$26
		sty PPUDATA
		ldy #$30
		sty PPUDATA
	dex
	bne :-

@clearScreen:
	ldy #$20
	sty nmiPpuAddr+1
	sty PPUADDR
	;lda #$00
	sta PPUADDR
	; 4 nametables
	ldy #4
		:
			.repeat 4
				sta PPUDATA
			.endrepeat
		inx
		bne :-
	dey
	bne :-

	; Turn on NMI; rendering will be turned on by the NMI handler.
	lda #%1000_0000
	sta PPUCTRL

	jmp Main

NMI:
	pha

	lda nmiPpuWrite
	beq :+
		lda nmiPpuAddr+1
		sta PPUADDR
		lda nmiPpuAddr+0
		sta PPUADDR
		lda nmiPpuData
		sta PPUDATA
		lda #0
		sta nmiPpuWrite
		inc nmiPpuAddr+0
		bne :+
			inc nmiPpuAddr+1
	:

	lda #%0000_1010 ; enable BG, not sprites
	sta PPUMASK
	lda #%1000_0000 ; enable NMI, first nametable, etc.
	sta PPUCTRL
	lda #0
	sta PPUSCROLL
	sta PPUSCROLL

	sta OAMADDR
	lda #$02
	sta OAMDMA

	pla
IRQ:
	rti

WriteTile:
	pha
	:
		lda nmiPpuWrite
	bne :-
	pla
	sta nmiPpuData
	dec nmiPpuWrite
	rts

WriteBlank:
	lda #0
	jmp WriteTile

WriteSeparator:
	lda #3
	jmp WriteTile

WriteNewline:
	:
		lda nmiPpuWrite
	bne :-
	clc
	lda nmiPpuAddr+0
	adc #32
	and #$FF-31
	sta nmiPpuAddr+0
	bcc :+
		inc nmiPpuAddr+1
	:
	rts
