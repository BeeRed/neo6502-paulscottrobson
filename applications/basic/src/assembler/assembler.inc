; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		assembler.inc
;		Purpose:	Assembler comments
;		Created:	1st July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;								Address modes (bit 7 set for zero page.)
;
; ************************************************************************************************

		.section code

AM_ZPAGE 		= $80 						; bit 7 set for ZP/8 bit operands only

AM_IMPLIED 		= 'I'						; none

AM_IMMEDIATE 	= ('#'|AM_ZPAGE)			; immediate

AM_ABSOLUTE 	= 'A' 			 			; lda nnnn
AM_ABSOLUTEX 	= 'X' 						; lda nnnn,x
AM_ABSOLUTEY 	= 'Y' 						; lda nnnn.y

AM_ABSOLUTEIX	= 'I' 						; jmp (nnnn,x) [only instance !]

AM_ZERO 	= ('A'|AM_ZPAGE) 				; lda nn
AM_ZEROX 	= ('X'|AM_ZPAGE)				; lda nn,x
AM_ZEROY 	= ('Y'|AM_ZPAGE)				; lda nn,y

AM_IND 		= ('P'|AM_ZPAGE) 				; lda (nn)
AM_INDX		= ('Q'|AM_ZPAGE) 				; lda (nn,x)
AM_INDY		= ('R'|AM_ZPAGE) 				; lda (nn,y)
		
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

