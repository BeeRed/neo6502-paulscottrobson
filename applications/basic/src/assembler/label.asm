; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		label.asm
;		Purpose:	Handle a label
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Label command (.identifier)
;
; ************************************************************************************************

		.section code

ASLabel:
		jsr 	EXPTermR0 					; get term
		bcc 	_ALError 					; must be a reference term.
		bit 	IFR0+IExp	 				; string reference ?
		bmi 	_ALError
		;
		lda 	ASMOption 					; on pass 2 (e.g. OPT bit 1 is set)
		and 	#2
		beq 	_ASLNoCheck
		;
		phy 								; if the variable changes there's an error.
		lda 	(IFR0+IM0)
		beq 	_ASLOk1						; (providing not changed from zero)
		cmp 	('P'-'A')*4 + FastVariables	
		bne 	_ALChanged
_ASLOk1:		
		ldy 	#1
		lda 	(IFR0+IM0),y
		beq 	_ASLOk2
		cmp 	('P'-'A')*4 + FastVariables+1
		bne 	_ALChanged
_ASLOk2:		
		ply
_ASLNoCheck:		
		;
		phy
		lda 	('P'-'A')*4 + FastVariables	; copy P to variable
		sta 	(IFR0+IM0)
		ldy 	#1
		lda 	('P'-'A')*4 + FastVariables+1
		sta 	(IFR0+IM0),y
		lda 	#0 							; clear upper bytes
		iny
		sta 	(IFR0+IM0),y
		iny
		sta 	(IFR0+IM0),y
		ply
		rts

_ALError:	
		.error_syntax
_ALChanged:
		.error_align

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

