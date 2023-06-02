; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		do.asm
;		Purpose:	Do/Loop loops
;		Created:	2nd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										DO command
;
; ************************************************************************************************

Command_DO:	;; [do]
		lda 	#STK_DO
		jsr 	StackOpen 
		jsr 	STKSaveCodePosition 		; save loop position
		rts

;:[do .. loop .. exit]
; Repeats a block of code until you finish the loop by using the EXIT command
; { c = 0: do: c = c + 1:if c = 10:exit:endif:print c:loop }

; ************************************************************************************************
;
;										EXIT command
;
; ************************************************************************************************

Command_EXIT:	;; [exit]
		lda 	#STK_DO 					; check in LOOP
		jsr 	StackCheckFrame
		jsr 	StackClose 					; close it
		lda 	#PR_LOOP 					; forward to LOOP
		tax
		jsr 	ScanForward
		rts

; ************************************************************************************************
;
;										LOOP command
;
; ************************************************************************************************

Command_LOOP:	;; [loop]
		lda 	#STK_DO 				
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; loop back
		rts

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
