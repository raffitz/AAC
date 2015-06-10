.module teste
.pseg
main:
		; testes overflows
		loadlit r1, 1
		lcl r0, 0
		lch r0, 128	; r0 = 0x8000
		deca r2, r0	; V
		inca r1, r1	; clears flags
		loadlit r0, -1
		inca r0, r0	; V, Z
		inca r1, r1	; clears flags

END:	j END	

.dseg
ARRAY:
.end
