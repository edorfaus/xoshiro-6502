.segment "DATA"

; Random data used to seed the PRNG (by setting its initial state).
; This is the same data that was used to initialize the C reference
; implementation to generate the other test data used for verification.
Seed:
	.byte $0C, $4A, $4D, $96, $95, $B8, $0A, $D4
	.byte $CB, $DE, $7F, $AD, $F0, $F0, $06, $30
	.byte $08, $FF, $21, $21, $A5, $AA, $23, $A2
	.byte $8B, $EE, $C2, $2E, $04, $0E, $DF, $2F

VerifyValuesXoshiro128:
	; plus, plusplus, starstar
	.dword $C6543AFC, $C06AC86F, $F1391922
	.dword $D4843189, $B459C753, $6FE53806
	.dword $D7559586, $AA04C486, $A5BE2840
	.dword $9C3FC0E5, $B3FB785A, $F510EE70

VerifyStatesXoshiro128:
	.dword $964D4A0C, $D40AB895, $AD7FDECB, $3006F0F0
	.dword $72410269, $EF382C52, $2E43BEC7, $62432F20
	.dword $FF3A011B, $B33A90FC, $2C5A18AE, $D81B946B
	.dword $941B058C, $605A8949, $A641E1B5, $0824BB59
	.dword $FC65379C, $52006D70, $87487639, $F1908343

VerifyJumpStatesXoshiro128:
	.dword $2A6DD50D, $01177499, $D7EB7D01, $DDC48284
	.dword $5EFDEE5A, $3AA13C3D, $8CC77479, $EB10A58F
	.dword $2CA76937, $14C9006E, $34097EA8, $FDD876EA
	.dword $01B72C9A, $A78174AA, $1CC317BE, $888235B2

VerifyLongJumpStatesXoshiro128:
	.dword $2564E401, $3319CF31, $BDBB52E4, $3401980C
	.dword $9C99646B, $52B8802B, $592CB24E, $8D36D8CC
	.dword $EBC4340C, $85D398CB, $D5F5856B, $0B662EA3
	.dword $AA2620A3, $A137523E, $7D75A27F, $B89BE680
