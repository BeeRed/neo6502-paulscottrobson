; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		repeat.asm
;		Purpose:	Repeat/Until loops
;		Created:	2nd June 2023
;		Reviewed: 	10th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										REPEAT command
;
; ************************************************************************************************

Command_REPEAT:	;; [repeat]
		lda 	#STK_REPEAT 				
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position
		rts

;:[repeat .. until]
; Repeats a block of code until a condition is true.
; { c = 5:repeat:c = c-1:print c:until c = 0 }

; ************************************************************************************************
;
;										UNTIL command
;
; ************************************************************************************************

Command_UNTIL:	;; [until]
		lda 	#STK_REPEAT 				; check REPEAT			
		jsr 	StackCheckFrame
		jsr 	EXPEvalNumber 				; work out the test
		ldx 	#IFR0
		jsr 	IFloatCheckZero 			; check if zero
		beq 	_CULoopBack 				; if so keep looping
		jsr 	StackClose		 			; return
		rts

_CULoopBack:		
		jsr 	STKLoadCodePosition 		; loop back
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
