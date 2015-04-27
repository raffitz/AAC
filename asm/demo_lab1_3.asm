.module test

;escreve o tamanho do array na posicao 27 (decimal) da memoria, e a partir dai o array inicial 
;escrevendo o array ordenado por ordem inversa por cima do mesmo


.pseg

main:		;Implementacao do algoritmo selection sort aplicado a um array
                ;r2 elemento a ordenar ficando na sua posicao final
                ;r3 para varrer todos os elementos do array

        lcl r0,LOWBYTE ARR1
        lch r0,HIGHBYTE ARR1
        load r4,r0	;r4 tem o numero de elementos que constituem o array
        add r4,r0,r4	;r4 tem o endereco final,aponta para a ultima posicao do array a ordenar
        inca r0,r0	;r0 aponta para o primeiro elemento do array a ordenar
        passa r1,r0	;r1	"	"	"		"	"	"
        load r2,r0	;r2 contem primeiro elemento do array

LOOP:   inca r1,r1	;
        load r3,r1	;
        sub r6,r2,r3	;r6 nao e utilizado apenas interessa o resultado presente à saida da ALU para as flags
        jt.negzero TROCA	;r2<=r3 faz troca de posicao no array

CONT:
        sub r6,r4,r1	;r6 nao e utilizado ...
        jf.zero LOOP	;r4>r1 o array ainda nao foi todo percorrido continua o loop
        sub r6,r4,r0	;
        deca r6,r6	;necessario para detectar se ja esta na penultima posicao do array na posicao final,nao sendo necessario prosseguir o teste
        jt.zero FIM	;r4=r0 array ja esta todo ordenado pode terminar
        inca r0,r0	;actualiza ponteiro para o elemento a ser testado
        load r2,r0	;le elemento seguinte do array 
        passa r1,r0	;r1 passa a apontar para a posicao onde vai ser colocado o elemento ordenado
        j LOOP

TROCA:
        store r0,r3	;Troca a posicao dos elementos na memoria 
        store r1,r2	;
        passa r5,r2	;r5 serve apenas como registo temporario
        passa r2,r3	;troca o conteudo dos registos, pois r2 tem o elemento a colocar na posicao final
        passa r3,r5	;e r3 tem o elemento que vai ser testado se e menor q o elemento que se encontra na posicao final
        j CONT		;conjtinua a ordenacao

FIM: j FIM
.dseg

ARR1:
        .word   8
        .word   -1
        .word   6
        .word   3
        .word   4
        .word   0
        .word   5
        .word   1
        .word   2
STACK:
.end
