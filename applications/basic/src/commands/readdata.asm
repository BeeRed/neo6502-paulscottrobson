; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		readdata.asm
;		Purpose:	Read & Data commands
;		Created:	9th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;											READ command
;
; ************************************************************************************************

		.section code

Command_READ: ;; [read]
		jsr 	EXPTermR0 					; get term to R0
		bcc 	_CRSyntax 					; fail if not a reference.
		lda 	IFR0+IM0 					; push address on the stack
		pha
		lda 	IFR0+IM1
		pha
		lda 	IFR0+IExp 					; push type on the stack
		;
		;		Now find something to be DATA
		;
		jsr 	SwapCodeDataPointers 		; swap code and data pointers over

		lda 	dataInStatement 			; if in a data statement, we don't need to search
		bne 	_CRHaveData  				; forward for the next one.

_CRNextLine:
		lda 	(codePtr)					; check end of program, e.g. nothing more to READ.
		beq 	_CRNoData
		;
		;		Look for Data.
		;
_CRKeepSearching:		
		lda 	#PR_DATA 					; scan for instruction DATA or EOL.
		ldx 	#PR_LSQLSQENDRSQRSQ
		jsr 	ScanForward
		cmp 	#PR_DATA 					; found data ?
		beq 	_CRHaveData 				; found it

		clc 								; try the next line, keep going.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_CRNextLine 
		inc 	codePtr+1
		bra 	_CRNextLine

_CRNoData:		 							; error , no more data
		.error_data
_CLType: 									; error , type mismatch
		.error_type		
_CRSyntax: 									; error , syntax
		.error_syntax
		;
		; 		Now have codePtr (dataPtr really) pointing at DATA keyword
		;
_CRHaveData:
		jsr 	EXPEvaluateExpression 		; some sort of value here -> R0
		pla 								; type of l-expr
		eor 	IFR0+IExp 					; check types match
		bmi 	_CLType

		pla 								; restore address
		sta 	zTemp0+1
		pla
		sta 	zTemp0
		jsr 	AssignData 					; write R0 there.
		;
		stz 	dataInStatement 			; clear in data flag
		lda 	(codePtr),y 				; data followed by a comma,e.g. more data follows
		cmp 	#PR_COMMA 					; if not, end of data statement and exit
		bne 	_CRSwapBack
		iny 								; consume comma
		inc 	dataInStatement 			; set in data statement flag.
		;
_CRSwapBack:		
		jsr 	SwapCodeDataPointers		; swap them back.		
		lda 	(codePtr),y 				; l-expr was followed by a comma
		iny
		cmp 	#PR_COMMA
		beq 	Command_READ 				; if so go round again.
		dey 								; unpick get.
		rts

; ************************************************************************************************
;
;									DATA command - effectively NOP
;
; ************************************************************************************************
		
Command_DATA: ;; [data]
		lda 	#PR_COLON 					; scan forward to : or EOL
		ldx 	#PR_LSQLSQENDRSQRSQ
		jsr 	ScanForward
		rts

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

