P = &A123
OPT 2
[ .test 
 	lda #42
 	lda 42
 	lda 32766
 	lda test
 	nop
 	jsr 32766
 	jmp (32766)
 	lda (22)
 	lda (22,x)
 	lda (22),y
] 