; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inputprint.asm 
;		Purpose:	Input (from keyboard) Print (to Screen)
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									PRINT statement
;
; ************************************************************************************************

Command_Print:	;; [print]
		;
Command_IP_Main:		
		clc 								; carry being clear means last print wasn't comma/semicolon
		;
		;		Print Loop
		;
_CPLoop:
		php 								; save last action flag
		lda 	(codePtr),y 				; get next character
		cmp  	#PR_LSQLSQENDRSQRSQ 		; end of line or colon, exit now.
		beq 	_CPExit 					; without consuming
		cmp 	#PR_COLON
		beq 	_CPExit
		pla 								; throw last action flag
		;
		;		Decide what's next
		;
		lda 	(codePtr),y 				; next character and bump
		iny
		cmp 	#PR_SEMICOLON				; is it a semicolon
		beq 	_CPContinueWithSameLine
		cmp 	#PR_COMMA 					; comma
		beq 	_CPTab
		dey 								; undo the get.

		jsr 	EXPEvaluateExpression 		; evaluate expression.
		bit 	IFR0+IExp 					; is it a number ?
		bpl 	_CPNumber
		;
		phy 
		clc 								; string address to YX
		lda 	IFR0+IM0
		tax
		lda 	IFR0+IM1
		tay 	
		inx 								; point to 1st character
		bne 	_CPNoCarry
		iny
_CPNoCarry:		
		lda 	(IFR0+IM0)					; length to A
		jsr 	CPPrintAYX 					; print AYX
		ply
		bra 	Command_IP_Main 			; loop round clearing carry so NL if end		
		;
		;		Print number
		;
_CPNumber:
		phy
		jsr 	IFloatFloatToStringR0 		; convert to string at YX length A
		jsr 	CPPrintAYX 					; print AYX
		ply		
		bra 	Command_IP_Main				; loop round clearing carry so NL if end		
		;
		;		Comma, Semicolon.
		;
_CPTab:	
		lda 	#9 							; print TAB
		jsr 	CPPrintA
_CPContinueWithSameLine:		
		sec 								; loop round with carry set, which
		bra 	_CPLoop 					; will inhibit final CR
		;
		;		Exit
		;
_CPExit:
		plp 								; get last action flag
		bcs 	_CPExit2  					; carry set, last was semicolon or comma
		lda 	#13 						; print new line
		jsr 	CPPrintA
_CPExit2:		
		rts

CPPrintAYX:
		stx 	zTemp0
		sty 	zTemp0+1
		tax
		beq 	_CPPrintExit
		ldy 	#0
_CPPrintAYXLoop:
		lda 	(zTemp0),y
		jsr 	CPPrintA
		iny
		dex
		bne 	_CPPrintAYXLoop
_CPPrintExit:	
		rts		

CPPrintA:
		jmp 	OSWriteScreen
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