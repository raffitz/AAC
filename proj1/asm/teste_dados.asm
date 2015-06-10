.module teste
.pseg
main:
	loadlit r4,29
	loadlit r3,0x0F
	add	r2, r3, r4
	add	r2, r2, r4
	nop
	nop
	nop
	add	r2, r2, r4
X:	j	X
.dseg
ARRAY:
.end
