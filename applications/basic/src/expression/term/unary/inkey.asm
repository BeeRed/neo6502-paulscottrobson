; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inkey.asm
;		Purpose:	Get keyboard state
;		Created:	6th June 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Get next key or "" if no key available
;
; ************************************************************************************************

		.section code	

EXPUnaryInkey: ;; [INKEY$(]
		jsr 	ERRCheckRParen 					; )
		lda 	#1 								; alloc temp mem for result
		jsr 	StringTempAllocate
		jsr 	OSIsKeyAvailable 				; if no key exit with the empty string
		bcs 	_EUIExit
		jsr 	OSReadKeyboard 					; otherwise get it and put it in first character
		jsr 	StringTempWrite
_EUIExit:		
		rts

		.send code

;: [inkey$()]\
; Returns either an empty string if there is no keypress available, or a single character which
; is the next key in the keyboard queue.
; { print asc(inkey$()) } prints 0 (or the ASCII code of the key)
				
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

