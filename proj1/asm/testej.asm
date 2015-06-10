.module teste
.pseg
main:
	loadlit	r1, 1
	lcl	r2, 1
	lch	r2, 0
	add	r1, r2, r1
	j	COISAS
	nop
	nop
COISAS:
	loadlit	r0, X
	add	r1, r2, r1
	jr	r0
X:
	j	NEXT
NEXT:
	add	r1, r2, r1
	loadlit	r4, END
	j	END
END:
	j	END
.dseg
ARRAY:
.end
