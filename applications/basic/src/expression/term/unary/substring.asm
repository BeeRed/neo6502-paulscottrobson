; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		substring.asm
;		Purpose:	LEFT$ RIGHT$ and MID$ 
;		Created:	29th May 2023
;		Reviewed: 	8th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code	

; ************************************************************************************************
;
;							LEFT$(a$,n) - left most a$ characters
;
; ************************************************************************************************

EXPUnaryLeft: ;; [left$(]
		jsr 	EXPCommonStart 					; <string>, 
		pha 									; save string address on stack
		phx
		lda 	#0 								; start position (zero offset)
		pha
		jsr 	EXPEvalInteger8 				; characters to do
		bra 	EXPSubstringCommon

;: [left$(string,count)]\
; Returns the leftmost 'count' characters of a string.\
; { print left$("dennis",3) } prints den

; ************************************************************************************************
;
;							RIGHT$(a$,n) - right most a$ characters
;
; ************************************************************************************************

EXPUnaryRight: ;; [right$(]
		jsr 	EXPCommonStart 					; <string>, 
		pha 									; save string address on stack
		phx
		lda 	(IFR0) 							; the string length => stack.
		pha

		jsr 	EXPEvalInteger8 				; characters to do
		sta 	zTemp0 							; calculate length - required, start point.
		pla
		sec
		sbc 	zTemp0
		bcs 	_EUROffLeft 					; check not past start
		lda 	#0
_EUROffLeft:
		pha 									; start pos
		lda 	#255		 					; length
		bra 	EXPSubstringCommon

;: [right$(string,count)]\
; Returns the rightmost 'count' characters of a string.\
; { print right$("dennis",3) } prints nis

; ************************************************************************************************
;
;						MID$(a$,n[,m]) - m characters from position n (or all)
;
; ************************************************************************************************

EXPUnaryMid: ;; [mid$(]
		jsr 	EXPCommonStart 					; <string>, 
		pha 									; save string address on stack
		phx
		jsr 	EXPEvalInteger8 				; characters start
		beq 	_EUSError 						; 1 is left
		dec 	a 								; zero based.
		pha 		
		;
		lda 	(codePtr),y 					; comma follows
		cmp 	#PR_COMMA
		beq 	_EUMLength 						; if so m is provided
		lda 	#255 							; default m
		bra 	EXPSubstringCommon
_EUMLength:
		iny 									; consume comma		
		jsr 	EXPEvalInteger8 				; characters to do
		bra 	EXPSubstringCommon

_EUSError:
		.error_value		

;: [mid$(string,start<,count>)]\
; Returns a substring of a string. start is the start position, which is indexed from
; 1. The count parameter, which is optional is the number of characters to extract.\
; { print mid$("dennis",3) } prints nnis\
; { print mid$("dennis",4,2) } prints ni

; ************************************************************************************************
;
;					String to R0, comma following XA is address (also in IFR0)
;
; ************************************************************************************************

EXPCommonStart:
		jsr 	EXPEvalString
		jsr 	ERRCheckComma
		lda 	IFR0+IM0
		ldx 	IFR0+IM1
		rts

; ************************************************************************************************
;
;		Common code. A bytes to do, TOS is start point from zero, string address follows
;
; ************************************************************************************************

EXPSubstringCommon:
		sta 	zTemp1 							; count to do in zTemp1.
		jsr 	ERRCheckRParen 					; check right bracket.

		pla 									; start position
		sta 	zTemp1+1 						; save in zTemp1+1
		plx 									; get string address to zTemp2.
		stx 	zTemp2+1
		pla
		sta 	zTemp2
		;
		sec 									; length - start is the max count of chars
		lda 	(zTemp2)
		sbc 	zTemp1+1
		cmp 	zTemp1 							; if available < count
		bcs 	_EXPSSNoTrim
		sta 	zTemp1 							; update count with available
_EXPSSNoTrim:
		lda 	zTemp1 							; chars required.
		jsr 	StringTempAllocate 				; allocate memory for it.
		lda 	zTemp1 							; zero length string
		beq 	_EXPSSExit

		lda 	zTemp1+1 						; if length >= start exit
		cmp 	(zTemp2)
		bcs 	_EXPSSExit

		phy
		ldy 	zTemp1+1 						; start position
		iny 									; +1 for the length byte
_EXPSSCopy:
		lda 	(zTemp2),y
		jsr 	StringTempWrite		
		iny
		dec 	zTemp1
		bne 	_EXPSSCopy
		ply
_EXPSSExit:		
		rts

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

