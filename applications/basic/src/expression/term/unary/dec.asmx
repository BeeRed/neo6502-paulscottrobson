; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dec.asm
;		Purpose:	Convert hex to integer
;		Created:	22nd May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;						Convert string to number, hexadecimal
;
; ************************************************************************************************

		.section code	

EXPUnaryDec: ;; [dec(]
		jsr 	EXPEvalString 					; string to R0, zTemp0		
		jsr 	ERRCheckRParen 					; )
		phy

		ldx 	#IFR0 							; zero the result
		jsr 	IFloatSetZero
		lda 	(zTemp0)						; read the length to X
		beq 	_EUDError 						; empty string
		tax
		ldy 	#2 								; start at offset 2.		
_EUDLoop:
		lda 	(zTemp0),y 						; get next
		cmp 	#"a" 							; l/c -> u/c
		bcc 	_EUDNoCase
		sbc 	#$20
_EUDNoCase:
		cmp 	#'0' 							; check 0..9
		bcc 	_EUDError		
		cmp 	#'9'+1
		bcc 	_EUDOkay
		cmp 	#'A'							; check A-F
		bcc 	_EUDError
		cmp 	#'F'+1
		bcs 	_EUDError
		sbc 	#6 								; hex adjust
_EUDOkay:		
		and 	#15 							; make constant
		phx
		pha
		ldx 	#IFR0 							; multiply R0 x 16
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		jsr 	IFloatShiftLeft
		pla 									; pop constant and OR in
		plx
		ora 	IFR0+IM0
		sta 	IFR0+IM0
		iny 									; next
		dex
		bne 	_EUDLoop
		ply
		rts
_EUDError:
		.error_value		

		.send code

;: [dec(string)]\
; Converts the string to an integer, assuming hexadecimal format\
; { print dec("7ffe") } prints 32766
				
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

