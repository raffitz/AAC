.module teste2
.pseg
main:
        ;;  Generates the first 20 Fibonnaci numbers
        lcl r6, LOWBYTE ARR1
        lch r6, HIGHBYTE ARR1
        loadlit r5,18
L1:     load r1,r6
        inca r6,r6
        load r2,r6
        add r3,r1,r2
        inca r4,r6
        store r4,r3
        deca r5,r5
        jf.zero L1
        nop
        ; halt the processor
HLT:    j HLT
        nop
.dseg
ARR1:
      .word  1
      .word  1
.end
