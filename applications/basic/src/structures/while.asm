; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		while.asm
;		Purpose:	While Wend loop
;		Created:	2nd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										WHILE command
;
; ************************************************************************************************

Command_WHILE:	;; [while]
		phy 								; save position of the test
		;
		jsr 	EXPEvalNumber 				; work out the while test.
		ldx 	#IFR0
		jsr 	IFloatCheckZero 			; check if zero
		beq 	_WHExitLoop 				; if so exit the loop, while has failed.
		;
		;		Test passed, so push the loop position (pre-number) on the stack.
		;
		tya 								; position *after* test.
		ply 								; restore position before test, at WHILE
		dey 								; so we execute the WHILE command again.
		pha 								; push after test on the stack

		lda 	#STK_WHILE 					; open while frame
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position - where the test value expr is.

		ply 								; restore the position *after* the test
		rts
		;
		;		End the while loop, so scan forward past the matching WEND.
		;
_WHExitLoop:
		pla 								; throw post loop position
		lda 	#PR_WEND 					; scan forward past WEND
		tax
		jsr 	ScanForward
		rts

;:[while .. wend]
; Repeats a block of code while a condition is true. The main difference between WHILE and REPEAT
; is that WHILE may never be executed, if the test is initially false.
; { x = 0:while x < 10:print x:x = x+1:wend }

; ************************************************************************************************
;
;										WEND command
;
; ************************************************************************************************

Command_WEND:	;; [wend]
		lda 	#STK_WHILE 					; check WHILE is TOS e.g. in a while loop :)
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; loop back to the WHILE keyword.
		jsr 	StackClose		 			; erase the frame
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
