; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		rem.asm
;		Purpose:	Comment
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									REM Command (also ')
;
; ************************************************************************************************

		.section code

Command_REM:	;; [rem]
Command_REM2: 	;; [']

		lda 	(codePtr),y 				; optional string parameter
		cmp 	#PR_LSQLSQSTRINGRSQRSQ 
		bne 	_CRExit

		iny 								; skip over it, it's a comment.
		tya
		sec
		adc 	(codePtr),y
		tay

_CRExit:		
		rts
		.send code
;:[REM]\
; REM inserts comments in code. It is slightly different from most basics in that it requires the
; text of the REM statement to be in quotes, though later tokenisers will do this automatically\
; It is purely informative ; there are two forms, {REM} without a comment and {REM "<description>"} with
; a comment.\
; {REM "Calculate the players initial positions"}
				
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

