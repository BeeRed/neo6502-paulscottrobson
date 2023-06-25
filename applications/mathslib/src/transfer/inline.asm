; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inline.asm
;		Purpose:	Load inline constant
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Load 4 byte inline constant following into Rx 
;								(uses iTemp0 but should be test only ?)
;
; ************************************************************************************************

		.section code
		
IFloatLoadInline:		
		pla 								; pop address off to iTemp0
		sta 	iTemp0
		pla
		sta 	iTemp0+1

		ldy 	#1
		lda 	(iTemp0),y 					; copy byte 0
		sta 	0,x
		iny
		lda 	(iTemp0),y 					; copy byte 1
		sta 	1,x
		iny
		lda 	(iTemp0),y 					; copy byte 2
		sta 	2,x
		iny
		lda 	(iTemp0),y 					; copy byte 3
		sta 	3,x

		clc 								; inc pointer, 1 for return, 4 for data
		lda 	iTemp0
		adc 	#5
		sta 	iTemp0
		bcc 	_IFLINoCarry
		inc 	iTemp0+1
_IFLINoCarry:
		jmp 	(iTemp0)					; effectively RTS		

		.send 	code


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

