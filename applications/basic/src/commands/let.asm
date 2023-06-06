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
		bcc 	CLError 					; must be a reference term.
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
		bmi 	CLType
		;
		plx 	 							; pop target address to zTemp0
		stx 	zTemp0+1 
		plx
		stx 	zTemp0
		; ---------------------------------------------------------------------------------------
		;
		;		Assign the value in IFR0 (string or number) to the data address in zTemp0
		;
		; ---------------------------------------------------------------------------------------

AssignData:		
		lda 	IFR0+IExp 					; string assignment
		bmi 	_CLStringAssign

		; ---------------------------------------------------------------------------------------
		;
		;									Number assignment
		;
		; ---------------------------------------------------------------------------------------

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

		; ---------------------------------------------------------------------------------------
		;
		;									  String assignment
		;
		; ---------------------------------------------------------------------------------------

_CLStringAssign:
		phy
		;
		;		If space doesn't contain a concreted string, go to concrete and store.
		;
		ldy 	#1 							; check if any concreted string.
		lda 	(zTemp0),y
		ora 	(zTemp0)
		beq 	_CLConcreteString
		;
		;		Check to see if the new string will fit in the old string.
		;
		lda 	(zTemp0) 					; copy address of string to zTemp1
		sta 	zTemp1
		lda 	(zTemp0),y
		sta 	zTemp1+1

		lda 	(zTemp1) 					; bytes available in the new slot
		sec 								; we want 3 for slot size, status, string size.
		sbc 	#3
		cmp 	(IFR0) 						; compare against string size.
		bcc 	_CLConcreteString 			; if so, concrete the string again.
		;
		;		Copy the new string into the old string concreted space.
		;
		lda 	(IFR0) 						; copy size + 1 bytes (for the length byte.)
		inc 	a
		tax
		ldy 	#0 							; offset in replacement string.
_CLReplaceString:
		lda 	(IFR0),y 					; copy new string into previous space.
		iny
		iny
		sta 	(zTemp1),y
		dey
		dex
		bne 	_CLReplaceString		
		bra 	_CLExit
		;
		;		Concrete string in IFR0
		;		
_CLConcreteString:
		jsr 	StringConcrete  			; concreted string in XA. 
		;
		;		Copy concreted string address to storage at zTemp0
		;		
		ldy 	#1 							; store the address
		sta 	(zTemp0)
		txa
		sta 	(zTemp0),y
_CLExit:
		ply
		rts

CLError:
		.error_variable
CLType:
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

