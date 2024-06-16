; This file contains a set of macros that are used to measure the sizes
; of the xoshiro/xoroshiro implementations, by placing them around the
; includes.
;
; Nothing in this file ends up in the finished ROM, it is purely for
; assemble-time informational purposes (given as terminal output).

.macro printSizeSep where
	.if .defined(printSizes)
		.if printSizes = 1 || (!.blank({where}))
			.out ""
		.endif
	.endif
.endmacro

.macro printSize lbl
	.ifndef printSizes
		.exitmacro
	.endif
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

.macro _totalSizePart var, group, tok
	.if !.match(.left(2, {tok}), {foo 0})
		.error .sprintf("Invalid call to totalSize: bad '%s' size", var)
		.exitmacro
	.endif
	.define varName .sprintf("totalSize_%s_%s", .string(group), var)
	::.ident(varName) = .mid(1, 1, {tok})
	.undefine varName
.endmacro

.macro totalSize groupZP, ram, code, data
	.if !.match(.left(2, {groupZP}), {name:})
		.error "Invalid call to totalSize: expected 'group:'"
		.exitmacro
	.endif
	_totalSizePart "z", .left(1, {groupZP}), .mid(2, 2, {groupZP})
	_totalSizePart "r", .left(1, {groupZP}), {ram}
	_totalSizePart "c", .left(1, {groupZP}), {code}
	_totalSizePart "d", .left(1, {groupZP}), {data}
.endmacro

.macro sizeGroupStart group
	.scope group
		.pushseg
		.segment "ZEROPAGE"
			prePosZP = *
		.segment "RAM"
			prePosRam = *
		.segment "LIBDATA"
			prePosData = *
		.segment "LIBCODE"
			prePosCode = *
		.popseg
	.endscope
.endmacro

.macro _sizeDiff var, group, val
	.define sz .sprintf("totalSize_%s_%s", .string(group), .string(val))
	.ifndef ::.ident(sz)
		.define var ""
	.elseif 0 = val - ::.ident(sz)
		.define var ""
	.else
		.define var .sprintf(" (%+d)", val - ::.ident(sz))
		dt .set dt + (val - ::.ident(sz))
	.endif
	.undefine sz
.endmacro

.define fmt1 "totalSize %14s ZP %d%s, RAM %2d%s"
.define fmt .concat(fmt1, ", code %4d%s, data %3d%s; total %4d%s")
.undefine fmt1
.macro sizeGroupEnd group
	.define fmtGroup .concat(.string(group), ":")
	.scope .ident(.concat(.string(group), "_End"))
		.pushseg
		.segment "ZEROPAGE"
			z = * - ::group::prePosZP
		.segment "RAM"
			r = * - ::group::prePosRam
		.segment "LIBDATA"
			d = * - ::group::prePosData
		.segment "LIBCODE"
			c = * - ::group::prePosCode
		.popseg

		dt .set 0
		_sizeDiff dz, group, z
		_sizeDiff dr, group, r
		_sizeDiff dc, group, c
		_sizeDiff dd, group, d

		t = z + r + d + c
		.if dt = 0
			.define dts ""
		.else
			.define dts .sprintf(" (%+d)", dt)
		.endif

		.out .sprintf(fmt, fmtGroup, z, dz, r, dr, c, dc, d, dd, t, dts)

		.undefine dts
		.undefine dz
		.undefine dr
		.undefine dc
		.undefine dd
	.endscope
	.undefine fmtGroup
.endmacro
.undefine fmt
