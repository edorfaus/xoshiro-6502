.segment "DATA"

; Random data used to seed the PRNG (by setting its initial state).
; This is the same data that was used to initialize the C reference
; implementation to generate the other test data used for verification.
Seed:
	.byte $0C, $4A, $4D, $96, $95, $B8, $0A, $D4
	.byte $CB, $DE, $7F, $AD, $F0, $F0, $06, $30
	.byte $08, $FF, $21, $21, $A5, $AA, $23, $A2
	.byte $8B, $EE, $C2, $2E, $04, $0E, $DF, $2F

; -- Xoshiro128

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

; -- Xoshiro256

; Here, each value and state word is defined as a 64-bit word - but ca65
; only supports word sizes up to 32 bits. Therefore, these tables split
; each 64-bit word into two 32-bit words, storing the low word first to
; end up with the expected little-endian byte order.

VerifyValuesXoshiro256:
	; plus{Lo,Hi}, plusplus{Lo,Hi}, starstar{Lo,Hi}
	.dword $C5103897,$03E9C699, $E1CF3EEF,$20ED40B1, $BD14DBB8,$9C2D273F
	.dword $55CF0AC3,$71DB4A5C, $77A967F1,$F9FE2DE6, $B4F9B327,$356DE24A
	.dword $2C64E6AD,$EB6BC35F, $873337D5,$DB8AD9CD, $C0F5DFC9,$A6C7AB72
	.dword $4710A0F1,$66BF2BD9, $41B6A15F,$7B5ADF81, $0C9630C4,$097F1C4C

VerifyStatesXoshiro256:
	.dword $964D4A0C,$D40AB895, $AD7FDECB,$3006F0F0
	.dword $2121FF08,$A223AAA5, $2EC2EE8B,$2FDF0E04

	.dword $15F07A4C,$CBD34661, $1A136BCF,$462FE2C0
	.dword $0AFAB504,$97C848CF, $3FDE9077,$A60803FB

	.dword $303D81F4,$2BF4A75A, $0519A487,$1A34EC6E
	.dword $C894CF48,$999B3A88, $FC2764B9,$BF771C04

	.dword $C90341CA,$8EB75730, $FDB0EA3B,$A85B71BC
	.dword $B1A74EBC,$6AB397E1, $7E0D5F27,$D807D4A8

	.dword $4ABEF4D6,$FEEBF224, $8514E54D,$4C5FB16D
	.dword $ACD20F76,$077D3BB0, $94A29077,$B6A38E0B

VerifyJumpStatesXoshiro256:
	.dword $E37F33C3,$0471EBA7, $13644109,$9AA42DB5
	.dword $768BC7B1,$2BB6A118, $5EAE7D69,$A9594A75

	.dword $A2980117,$00380A45, $064C5D06,$3910C148
	.dword $EA84DB93,$34768513, $CFC6D5E6,$2CD290CE

	.dword $4CA58F15,$98F01993, $46739E09,$6F433EAC
	.dword $C69E7B10,$33B2D1A3, $2AF448F4,$8FEA755D

	.dword $1388713E,$EF9ACC23, $B21C6602,$27F42EE3
	.dword $6E00701B,$D30846DE, $9E3295F6,$975EE6D6

VerifyLongJumpStatesXoshiro256:
	.dword $BEE273C9,$4AA6161C, $054B14DC,$8B273747
	.dword $456633FE,$F8C572C6, $90CD6E8E,$5466144E

	.dword $A54655DF,$A9290DCA, $B2735883,$0BCEF432
	.dword $FBC4FDFF,$EF4F5D1A, $03B5F245,$5AD7A3FC

	.dword $2F47F114,$8A3B3779, $C5B83153,$69910278
	.dword $871B42CF,$65FE2297, $3C009B73,$3E371CAC

	.dword $8DE16A23,$4BC74347, $2EC5F7E2,$F0196A71
	.dword $172FED0E,$B6606E0A, $E78A0739,$BE940FD7

; -- Xoroshiro64

VerifyValuesXoroshiro64:
	; star, starstar
	.dword $A308C2C4, $E579BAE4
	.dword $1B34214B, $0094CEEF
	.dword $2CDF9955, $0BBFD539
	.dword $3BA099FE, $44603EE3

VerifyStatesXoroshiro64:
	.dword $964D4A0C, $D40AB895
	.dword $FFFBF5B1, $FE532848
	.dword $97ECC02F, $1BBF2035
	.dword $95CC671A, $7C03518A
	.dword $1DF5270C, $E6D21D39
