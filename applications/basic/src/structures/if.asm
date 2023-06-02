; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		if.asm
;		Purpose:	IF command
;		Created:	2nd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************

; ************************************************************************************************
;
;										IF (two forms)
;
; ************************************************************************************************

		.section code

IfCommand: ;; [if]
		jsr 	EXPEvalNumber 				; Get the if test.
		;
		lda 	(codePtr),y					; what follows ?
		cmp 	#PR_THEN  					; could be THEN <stuff> 
		bne 	_IfStructured 				; we still support it.

		; ------------------------------------------------------------------------
		;
		;						 IF ... THEN <statement> 
		;
		; ------------------------------------------------------------------------

		iny 								; consume THEN
		jsr 	IFloatCheckZero 			; is it zero
		beq 	_IfFail 					; if fail, go to next line
		rts 								; if THEN just continue
_IfFail:
		jmp 	RUNEndOfLine

		; ------------------------------------------------------------------------
		;
		;		   The modern, structured, nicer IF ... ELSE ... ENDIF
		;
		; ------------------------------------------------------------------------

_IfStructured:
		jsr 	IFloatCheckZero 			; is it zero
		bne 	_IfExit 					; if not, then continue normally.
		lda 	#PR_ELSE 					; look for else/endif 
		ldx 	#PR_ENDIF
		jsr 	ScanForward 				; and run from there
_IfExit: 
		rts

; ************************************************************************************************
;
;					ELSE code - should be found when running a successful IF clause
;
; ************************************************************************************************

ElseCode: ;; [else] 					
		lda 	#PR_ENDIF 					; else is only run after the if clause succeeds
		tax 								; so just go to the structure exit
		jsr 	ScanForward
		rts

; ************************************************************************************************
;
;										ENDIF code
;
; ************************************************************************************************

EndIf:	;; [endif]							
		rts 								; endif code does nothing

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