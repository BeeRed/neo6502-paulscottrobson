; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		call.asm
;		Purpose:	Call procedure
;		Created:	4th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										CALL command
;
; ************************************************************************************************

Command_CALL:	;; [call]
		lda 	#STK_CALL
		jsr 	StackOpen 

		lda 	(codePtr),y 				; check identifier follows.
		and 	#$C0
		cmp 	#$40
		bne 	_CCSyntax
		;
		jsr 	VARGetInfo 					; get the information
		jsr 	ERRCheckRParen 				; check right bracket follows.
		jsr 	VARFind 					; exists ?
		bcc 	_CCUnknown

		stx 	zTemp0+1 					; save target in XA
		sta 	zTemp0

		jsr 	STKSaveCodePosition 		; save return address on stack.

		ldy 	#3 							; check $FF marker
		lda 	(zTemp0),y
		cmp 	#$FF
		bne 	_CCUnknown

		dey 								; get Y offset to stack
		lda 	(zTemp0),y
		pha
		dey 								; get address
		lda 	(zTemp0),y
		sta 	codePtr+1
		lda 	(zTemp0)
		sta 	codePtr
		ply 								; restore Y
		rts

_CCSyntax:
		.error_syntax
_CCUnknown:
		.error_unknown

;:[call]
; Call a named procedure
; { call draw.everything() }

; ************************************************************************************************
;
;										UNTIL command
;
; ************************************************************************************************

Command_ENDPROC:	;; [endproc]
		lda 	#STK_CALL
		jsr 	StackCheckFrame
		jsr 	STKLoadCodePosition 		; return
		jsr 	StackClose		 			
		rts

;:[proc <name> ... endproc]
; Defines a procedure. A procedure definition must be the first thing on the line.
; { proc bump.me:a = a+1:endproc }

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
