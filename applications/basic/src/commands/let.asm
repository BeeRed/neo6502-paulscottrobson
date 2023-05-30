; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		let.asm
;		Purpose:	Assignment statement
;		Created:	30th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										LET Command
;
; ************************************************************************************************

		.section code

CommandLET:	;; [let]
		jsr 	EXPTermR0 					; get term
		bcc 	_CLError 					; must be a reference term.
		;
		lda 	IFR0+IM0 					; push address and type onto stack
		pha
		lda 	IFR0+IM1
		pha
		lda 	IFR0+IExp
		pha

		lda 	#PR_EQUAL 					; equals for syntax
		jsr 	ERRCheckA

		jsr 	EXPEvaluateExpression 		; right hand side.
		pla 								; type of l-expr
		eor 	IFR0+IExp 					; check types match
		bmi 	_CLType
		;
		plx 	 							; pop target address to zTemp0
		stx 	zTemp0+1 
		plx
		stx 	zTemp0
		;
		lda 	IFR0+IExp 					; string assignment
		bmi 	_CLStringAssign
		;
		;		Number assignment
		;
		phy 						
		ldy 	#3
		sta 	(zTemp0),y
		dey
		lda 	IFR0+IM2
		sta 	(zTemp0),y
		dey
		lda 	IFR0+IM1
		sta 	(zTemp0),y
		lda 	IFR0+IM0
		sta 	(zTemp0)
		ply
		rts
		;
		;		String assignment
		;
_CLStringAssign:
		.error_unimplemented

_CLError:
		.error_variable
_CLType:
		.error_type
		.send code
		
;:[let]
; Assignment statement - sets a variable to a value. The LET is optional.\
; { let count = 42 : name$ = "Agragjag" }
				
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

