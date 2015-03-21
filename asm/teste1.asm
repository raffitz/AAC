.module teste
.pseg
main:
	; r0 points to the stack
	loadlit r6, -1
	lcl r0, LOWBYTE X
	lch r0, HIGHBYTE X
	jal r0
HLT:
	j HLT
X:
	loadlit r4,29
	loadlit r3,0x0F
	add	r2, r3, r4
	jr	r7
.dseg
ARRAY:
.end
