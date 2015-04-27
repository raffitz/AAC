.module flags
.pseg
        ; Testa flags
        ;       
	; r0 points to ARR1
        lcl	r0, LOWBYTE ARR1
        lch	r0, HIGHBYTE ARR1
	zeros	r1
	inca	r2,r1
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	passa	r3,r1
	jf.zero L1
	nop
	store	r0,r1
L1:	inca	r0,r0
	passb	r3,r1
	jt.zero L2
	nop
	store	r0,r1
L2:	inca	r0,r0		
	zeros	r3
	deca	r3,r3
	inca	r3,r3
	jf.carry L31
	nop
	store	r0,r1
L31:	jt.overflow L3
	nop
	inca	r0,r0
	store	r0,r1	
L3:	inca	r0,r0
	lcl	r3,255
	lch	r3,127
	inca	r3,r3
	jf.overflow L4
	nop
	store	r0,r1
L4:	inca	r0,r0
	asr	r2,r2
	jf.zero L5
	nop
	inca	r2,r2
	store	r0,r1
L5:	inca	r0,r0
HLT:    j HLT
        nop
	;; 
.dseg
ARR1:
        .word  0               ; zero -> errou Z passa (1)
        .word  0               ; zero -> errou Z passb (1)
        .word  0               ; zero -> errou C inca (1)
        .word  0               ; zero -> errou overflow inca (1)
        .word  0               ; zero -> errou O deca (1)
        .word  0               ; zero -> errou Z asr  (1)
.end
