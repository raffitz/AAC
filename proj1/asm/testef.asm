.module teste
.pseg
main:
		; flags are S, C, Z, V
		lcl r0, 255
		lch r0, 255
		loadlit r1, 1
		add r0, r0, r1	; C, Z
		nop
		nop
		jf.neg X1
J1:		jt.carry X2
J2:		jt.zero X3
J3:		jt.overflow X4	; not taken
J4:		loadlit r2, 1
		loadlit r1, 0
		loadlit r0, -1
		add r2, r1, r2	; clear all flags
		addinc r0, r1, r0	; C, Z
		jf.neg X5
J5:		jt.carry X6
J6:		jt.zero X7
J7:		jt.overflow X8	; not taken
J8:		jt.neg X9	; not taken
J9:		inca r0, r0	; clear all flags
		deca r0, r0 ; Z
		jf.zero X10	; not taken
J10:	jt.zero X11
J11:	deca r0, r0 ; S
		zeros r0
		and r0, r0, r0	; Z
		lch r0, 128
		zeros r1
		or r0, r0, r1	; S
		inca r1, r1	; clear all flags
		jt.neg X12	; not taken
J12:	jt.carry X13	; not taken
J13:	jt.zero X14	; not taken
J14:	jt.overflow X15	; not taken
J15:	loadlit r2, -1
		passa r2, r2
		ones r2
		asr r2, r2	; C, Z (carry because a 1 is dropped out)
		jt.zero A1
		nop
A1:		deca r2, r2	; S
		nop
		nop
		nop
		lcl r0, 255
		lch r0, 127	; r0 has max positive value
		inca r0, r0	; S, V
		zeros r1	; does not change flags
		passb r1, r1	; does not change flags
		jt.overflow A2	; taken
		nop
		nop
		nop
A2:		nop
		j END


; many jumps
X1:		j J1
X2:		j J2
X3:		j J3
X4:		j J4

X5:		j J5
X6:		j J6
X7:		j J7
X8:		j J8
X9:		j J9

X10:	j J10
X11:	j J11

X12:	j J12
X13:	j J13
X14:	j J14
X15:	j J15

END:	j END
.dseg
ARRAY:
.end
