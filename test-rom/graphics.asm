.segment "CHR"

.repeat 16
	.byte 0
.endrepeat

.byte %00000000
.byte %00111000
.byte %01111100
.byte %01111100
.byte %01111100
.byte %00111000
.byte %00000000
.byte %00000000
.byte 0, 0, 0, 0, 0, 0, 0, 0

.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte %00000000
.byte %01100110
.byte %00111100
.byte %00011000
.byte %00111100
.byte %01100110
.byte %00000000
.byte %00000000

.repeat 2
	.byte %00000000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00011000
	.byte %00000000
.endrepeat
