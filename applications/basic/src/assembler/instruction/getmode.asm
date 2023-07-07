; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		getmode.asm
;		Purpose:	Get address mode for given opcode.
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Get opcode for address mode A
;
; ************************************************************************************************

		.section code

ASGetModeForOpcode:
		phy
		tay 								; save in Y
		;
		;		Search the special case tables.
		;
		ldx 	#0
_ASGSearch:
		tya 								; check if opcode matches
		cmp 	ASGSpecialCases,x
		beq 	_ASGIsSpecial
		inx
		inx
		lda 	ASGSpecialCases,x 			; check end of table ($F3 is an illegal 65C02 opcode)
		cmp 	#$F3		
		bne 	_ASGSearch
		;
		tya 								; only interested in lower 5 bits.
		and 	#$1F
		tay
		;
		and 	#$0F 						; lower 4 bits of the opcode
		asl 	a 							; index into ASG Table
		tax
		cpy 	#$10 						; was bit 5 set,  e.g. the MSB is odd
		bcc 	_ASGEven
		inx 								; if so, take from second half.
_ASGEven:
		lda 	ASGTable,x 					; fetch the mode from the table
		ply
		rts

_ASGIsSpecial:
		lda 	ASGSpecialCases+1,x 		; get special case for that mode.
		ply
		rts

; ************************************************************************************************
;
;		Mostly identify address modes for the lower 5 bits of the opcode.
;
;		See 65C02 analysis.ods.
;
;		This table specifies the address modes for the lower nibble of an opcode. The first value
;		is where the upper nibble is even (e.g. 0x 2x) the second is for odd (e.g. 1x 3x)
;
; ************************************************************************************************

ASGTable:
		.byte 	AM_IMMEDIATE,AM_RELATIVE				; x0
		.byte 	AM_ZINDX,AM_ZINDY 						; x1
		.byte 	AM_IMMEDIATE,AM_ZIND 					; x2
		.byte 	AM_IMPLIED,AM_IMPLIED 					; x3 (all NOP)
		.byte 	AM_ZERO,AM_ZEROX 						; x4
		.byte 	AM_ZERO,AM_ZEROX 						; x5
		.byte 	AM_ZERO,AM_ZEROX 						; x6
		.byte 	AM_ZERO,AM_ZERO 						; x7
		.byte 	AM_IMPLIED,AM_IMPLIED 					; x8
		.byte 	AM_IMMEDIATE,AM_ABSOLUTEY				; x9
		.byte 	AM_IMPLIED,AM_IMPLIED 					; xA 
		.byte 	AM_IMPLIED,AM_IMPLIED 					; xB 
		.byte 	AM_ABSOLUTE,AM_ABSOLUTE 				; xC
		.byte 	AM_ABSOLUTE,AM_ABSOLUTEX 				; xD
		.byte 	AM_ABSOLUTE,AM_ABSOLUTEX 				; xE
		.byte 	AM_ZERO,AM_ZERO 						; xF
;
;		These are the special cases that don't fit the pattern.
;
ASGSpecialCases:
		.byte	$80	,	AM_RELATIVE						;	BRA	rel
		.byte	$14	,	AM_ZERO							;	TRB	nn
		.byte	$96	,	AM_ZEROY						;	STX	nn,y
		.byte	$B6	,	AM_ZEROY						;	LDX	nn,y
		.byte	$3C	,	AM_ABSOLUTEX					;	BIT	nnnn,x
		.byte	$6C	,	AM_ABSOLUTEI					;	JMP	(nnnn)
		.byte	$7C	,	AM_ABSOLUTEIX					;	JMP 	(nnnn,x)
		.byte	$BC	,	AM_ABSOLUTEX					;	LDY	nnnn,x
		.byte	$BE	,	AM_ABSOLUTEY					;	LDX	nnnn,y
		.byte	$00	,	AM_IMPLIED						;	BRK	
		.byte	$20	,	AM_ABSOLUTE						;	JSR	nnnn
		.byte	$40	,	AM_IMPLIED						;	RTI	
		.byte	$60	,	AM_IMPLIED						;	RTS	
		.byte 	$F3 									; (illegal opcode)

		.send code

; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************

