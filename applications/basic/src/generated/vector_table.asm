;
;	This file is automatically generated.
;
VectorTable:
	.word	NotImplemented           ; $80 REPEAT
	.word	NotImplemented           ; $81 UNTIL
	.word	NotImplemented           ; $82 WHILE
	.word	NotImplemented           ; $83 WEND
	.word	NotImplemented           ; $84 IF
	.word	NotImplemented           ; $85 ENDIF
	.word	NotImplemented           ; $86 DO
	.word	NotImplemented           ; $87 LOOP
	.word	NotImplemented           ; $88 
	.word	NotImplemented           ; $89 PROC
	.word	NotImplemented           ; $8a ENDPROC
	.word	NotImplemented           ; $8b FOR
	.word	NotImplemented           ; $8c NEXT
	.word	RUNEndOfLine             ; $8d [[END]]
	.word	Command_Shift_Handler    ; $8e [[SHIFT]]
	.word	NotImplemented           ; $8f ELSE
	.word	NoExec01                 ; $90 THEN
	.word	NoExec02                 ; $91 TO
	.word	NoExec03                 ; $92 STEP
	.word	NotImplemented           ; $93 LET
	.word	Command_Print            ; $94 PRINT
	.word	NotImplemented           ; $95 INPUT
	.word	NotImplemented           ; $96 CALL
	.word	NotImplemented           ; $97 SYS
	.word	Command_REM              ; $98 REM
	.word	NotImplemented           ; $99 EXIT
	.word	NoExec04                 ; $9a ,
	.word	NoExec05                 ; $9b ;
	.word	NoExec06                 ; $9c :
	.word	Command_REM2             ; $9d '
	.word	NoExec07                 ; $9e )
	.word	NotImplemented           ; $9f DIM
	.word	Command_CLEAR            ; $a0 CLEAR
	.word	Command_NEW              ; $a1 NEW
	.word	Command_RUN              ; $a2 RUN
	.word	Command_STOP             ; $a3 STOP
	.word	Command_END              ; $a4 END
	.word	Command_ASSERT           ; $a5 ASSERT
	.word	NotImplemented           ; $a6 LIST
	.word	NotImplemented           ; $a7 SAVE
	.word	NotImplemented           ; $a8 LOAD
	.word	NotImplemented           ; $a9 
	.word	NotImplemented           ; $aa 
	.word	NotImplemented           ; $ab 
	.word	NotImplemented           ; $ac 
	.word	NotImplemented           ; $ad 
	.word	NotImplemented           ; $ae 
	.word	NotImplemented           ; $af 
	.word	NotImplemented           ; $b0 
	.word	NotImplemented           ; $b1 
	.word	NotImplemented           ; $b2 
	.word	NotImplemented           ; $b3 
	.word	NotImplemented           ; $b4 
	.word	NotImplemented           ; $b5 
	.word	NotImplemented           ; $b6 
	.word	NotImplemented           ; $b7 
	.word	NotImplemented           ; $b8 
	.word	NotImplemented           ; $b9 
	.word	NotImplemented           ; $ba 
	.word	NotImplemented           ; $bb 
	.word	NotImplemented           ; $bc 
	.word	NotImplemented           ; $bd 
	.word	NotImplemented           ; $be 
	.word	NotImplemented           ; $bf 
	.word	NotImplemented           ; $c0 
	.word	NotImplemented           ; $c1 
	.word	NotImplemented           ; $c2 
	.word	NotImplemented           ; $c3 
	.word	NotImplemented           ; $c4 
	.word	NotImplemented           ; $c5 
	.word	NotImplemented           ; $c6 
	.word	NotImplemented           ; $c7 
	.word	NotImplemented           ; $c8 
	.word	NotImplemented           ; $c9 
	.word	NotImplemented           ; $ca 
	.word	NotImplemented           ; $cb 
	.word	NotImplemented           ; $cc 
	.word	NotImplemented           ; $cd 
	.word	NotImplemented           ; $ce 
	.word	NotImplemented           ; $cf 
	.word	NotImplemented           ; $d0 
	.word	NotImplemented           ; $d1 
	.word	NotImplemented           ; $d2 
	.word	NotImplemented           ; $d3 
	.word	NotImplemented           ; $d4 
	.word	NotImplemented           ; $d5 
	.word	NotImplemented           ; $d6 
	.word	NotImplemented           ; $d7 RIGHT$(
	.word	NotImplemented           ; $d8 LEFT$(
	.word	NotImplemented           ; $d9 MID$(
	.word	EXPUnaryStr              ; $da STR$(
	.word	EXPUnaryVal              ; $db VAL(
	.word	EXPUnarySgn              ; $dc SGN(
	.word	EXPUnaryAbs              ; $dd ABS(
	.word	EXPUnaryLen              ; $de LEN(
	.word	EXPUnarySqr              ; $df SQR(
	.word	EXPUnaryChr              ; $e0 CHR$(
	.word	EXPUnaryAsc              ; $e1 ASC(
	.word	NotImplemented           ; $e2 INKEY$(
	.word	NotImplemented           ; $e3 EVENT(
	.word	NotImplemented           ; $e4 TIME
	.word	EXPUnaryInt              ; $e5 INT(
	.word	EXPUnaryFrac             ; $e6 FRAC(
	.word	EXPUnaryDec              ; $e7 DEC(
	.word	EXPUnaryHex              ; $e8 HEX$(
	.word	EXPUnaryRnd              ; $e9 RND(
	.word	ExpUnaryRand             ; $ea RAND(
	.word	EXPUnaryParenthesis      ; $eb (
	.word	EXPUnaryNull             ; $ec $
	.word	EXPUnaryInlineDec        ; $ed [[DECIMAL]]
	.word	EXPUnaryInlineString     ; $ee [[STRING]]
	.word	EXPCompareEqual          ; $ef =
	.word	EXPCompareNotEqual       ; $f0 <>
	.word	EXPCompareLessEqual      ; $f1 <=
	.word	EXPCompareLess           ; $f2 <
	.word	EXPCompareGreaterEqual   ; $f3 >=
	.word	EXPCompareGreater        ; $f4 >
	.word	EXPBinXor                ; $f5 XOR
	.word	EXPBinOr                 ; $f6 OR
	.word	EXPBinAnd                ; $f7 AND
	.word	EXPBinIDiv               ; $f8 DIV
	.word	EXPBinIMod               ; $f9 MOD
	.word	EXPBinLeft               ; $fa <<
	.word	EXPBinRight              ; $fb >>
	.word	EXPBinFDiv               ; $fc /
	.word	EXPBinMul                ; $fd *
	.word	EXPBinSub                ; $fe -
	.word	EXPBinAdd                ; $ff +
