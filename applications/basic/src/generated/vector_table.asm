;
;	This file is automatically generated.
;
VectorTable:
	.word	Command_REPEAT           ; $80 REPEAT
	.word	Command_UNTIL            ; $81 UNTIL
	.word	Command_WHILE            ; $82 WHILE
	.word	Command_WEND             ; $83 WEND
	.word	IfCommand                ; $84 IF
	.word	EndIf                    ; $85 ENDIF
	.word	Command_DO               ; $86 DO
	.word	Command_LOOP             ; $87 LOOP
	.word	NoExec08                 ; $88 PROC
	.word	NotImplemented           ; $89 ENDPROC
	.word	Command_FOR              ; $8a FOR
	.word	Command_NEXT             ; $8b NEXT
	.word	RUNEndOfLine             ; $8c [[END]]
	.word	Command_Shift_Handler    ; $8d [[SHIFT]]
	.word	ElseCode                 ; $8e ELSE
	.word	NoExec01                 ; $8f THEN
	.word	NoExec02                 ; $90 TO
	.word	NoExec03                 ; $91 STEP
	.word	CommandLET               ; $92 LET
	.word	Command_Print            ; $93 PRINT
	.word	NotImplemented           ; $94 INPUT
	.word	NotImplemented           ; $95 CALL
	.word	NotImplemented           ; $96 SYS
	.word	Command_REM              ; $97 REM
	.word	Command_EXIT             ; $98 EXIT
	.word	NoExec04                 ; $99 ,
	.word	NoExec05                 ; $9a ;
	.word	NoExec06                 ; $9b :
	.word	Command_REM2             ; $9c '
	.word	NoExec07                 ; $9d )
	.word	CommandDIM               ; $9e DIM
	.word	Command_CLEAR            ; $9f CLEAR
	.word	Command_NEW              ; $a0 NEW
	.word	Command_RUN              ; $a1 RUN
	.word	Command_STOP             ; $a2 STOP
	.word	Command_END              ; $a3 END
	.word	Command_ASSERT           ; $a4 ASSERT
	.word	NotImplemented           ; $a5 LIST
	.word	NotImplemented           ; $a6 SAVE
	.word	NotImplemented           ; $a7 LOAD
	.word	NotImplemented           ; $a8 POKE
	.word	NotImplemented           ; $a9 DOKE
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
	.word	NotImplemented           ; $d5 DEEK(
	.word	NotImplemented           ; $d6 PEEK(
	.word	EXPUnaryRight            ; $d7 RIGHT$(
	.word	EXPUnaryLeft             ; $d8 LEFT$(
	.word	EXPUnaryMid              ; $d9 MID$(
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
