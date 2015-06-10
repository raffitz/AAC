.module teste3
.pseg
main:
        
     lcl r6, LOWBYTE ARR1
     lch r6, HIGHBYTE ARR1
     ; r0 points to the stack
     lcl r0, LOWBYTE STACK
     lch r0, HIGHBYTE STACK
     ; multiplies the elements of array ARR1 by themselves
     ; ARR1[0] contains number of elements in array
     lcl r1, LOWBYTE MUL
     lch r1, HIGHBYTE MUL
     load r2,r6                 
L1:  add r3,r6,r2  
     load r4,r3
     load r5,r3
     jal r1
     nop
     store r3,r5
     deca r2,r2  
     jf.zero L1
     nop
     ;  Now, sort the result
SRT: lcl r6, LOWBYTE ARR1
     lch r6, HIGHBYTE ARR1
     load r7,r6
L2:  lcl r6, LOWBYTE ARR1
     lch r6, HIGHBYTE ARR1
     load r0,r6
     deca r0,r0
     inca r6,r6
     ;  r6 now points to beginning of array and r0 contains length - 1
L3:  inca r5,r6
     load r1,r6
     load r2,r5
     sub r3,r1,r2
     jt.neg NOSW
     nop
     passa r4,r1
     passa r1,r2
     passa r2,r4
NOSW:store r6,r1
     store r5,r2
     inca r6,r6
     deca r0,r0
     jf.zero L3
     nop
     deca r7,r7
     jf.zero L2
     nop
HLT: j HLT
     nop
     ; multiplies r4>0 by r5>0  and returns r5.
     ; Preserves all registers, saving them on the stack (pointed by r0)
MUL: store r0, r1
     inca  r0, r0
     store r0, r2
     inca  r0, r0
     store r0, r3 
     inca  r0, r0
     store r0, r4
     inca  r0, r0
     store r0, r6
     loadlit r1,15
     loadlit r2,1
     loadlit r6,0
ML0: and r3,r4,r2
     jt.zero ML1
     nop
     add r6,r6,r5
ML1: asr r4,r4
     lsl r5,r5
     deca r1,r1
     jf.zero ML0
     nop
     passa r5,r6    
     load r6, r0
     deca r0, r0
     load r4, r0
     deca r0, r0
     load r3, r0
     deca r0, r0
     load r2, r0
     deca r0, r0
     load r1, r0
     jr r7
     nop
.dseg
ARR1:
      .word  12        ; Length of array
      .word  7
      .word  11
      .word  19
      .word  17
      .word  21
      .word  9
      .word  23
      .word  15
      .word  5
      .word  3
      .word  1
      .word  13
STACK:
.end
