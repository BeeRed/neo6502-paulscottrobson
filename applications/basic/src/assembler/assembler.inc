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

AM_RELATIVE 	= 'R' 						; bra nnnn

AM_ABSOLUTE 	= 'A' 			 			; lda nnnn
AM_ABSOLUTEX 	= 'X' 						; lda nnnn,x
AM_ABSOLUTEY 	= 'Y' 						; lda nnnn.y

AM_ABSOLUTEI  	= 'T' 						; jmp (nnnn)   [only instance]
AM_ABSOLUTEIX	= 'U' 						; jmp (nnnn,x) [only instance !]

AM_ZERO 	= ('A'|AM_ZPAGE) 				; lda nn
AM_ZEROX 	= ('X'|AM_ZPAGE)				; lda nn,x
AM_ZEROY 	= ('Y'|AM_ZPAGE)				; lda nn,y

AM_ZIND 	= ('T'|AM_ZPAGE) 				; lda (nn)
AM_ZINDX	= ('U'|AM_ZPAGE) 				; lda (nn,x)
AM_ZINDY	= ('V'|AM_ZPAGE) 				; lda (nn,y)
		
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

