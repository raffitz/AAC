.module teste7
.pseg
main:
     ; r0 points to the stack
     lcl r0, LOWBYTE STACK
     lch r0, HIGHBYTE STACK
     lcl r6, LOWBYTE DIV
     lch r6, HIGHBYTE DIV
     loadlit r5,30
        ; Generate primes until 30. R5 is the limit
     loadlit r4,2
        ; Start at 2
L1:  loadlit r2,2
L2:  passa r1,r4
     jal r6
     and r1,r1,r1
     jt.zero SKIP
     nop
     inca r2,r2
     sub r1,r4,r2
     jf.zero L2
     nop
        ;;  Doesn't divide any number
     store r0,r4
     inca r0,r0
SKIP:
     inca r4,r4
     sub r3,r4,r5
     jf.zero L1
     nop   
     passa r5,r0
     lcl r3, LOWBYTE STACK
     lch r3, HIGHBYTE STACK
L3:  load r1,r3
     passb r2,r1
     jal r6
     nop
     store r0,r1
     inca  r0,r0
     inca  r3,r3
     sub   r7,r3,r5
     jf.zero L3


HLT: j HLT
     nop
     ; Computes the remainder of R1 divided by R2, both positive
     ; by doing successive subtractions.
DIV: sub r1,r1,r2
     jt.neg ADD
     nop
     jt.zero RET
     nop
     j DIV
     nop
ADD: add r1,r1,r2
RET: jr r7
     nop
.dseg
STACK:  
.end
