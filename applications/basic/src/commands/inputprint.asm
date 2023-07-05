; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		inputprint.asm 
;		Purpose:	Input (from keyboard) Print (to Screen)
;		Created:	26th May 2023
;		Reviewed: 	5th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;									INPUT statement
;
; ************************************************************************************************

Command_Input: ;; [input]
		lda 	#$FF 						; this flag determines input ($FF) output $(00)
		sta 	InputFlag
		bra 	Command_IP_Main

; ************************************************************************************************
;
;									PRINT statement
;
; ************************************************************************************************

Command_Print:	;; [print]
		stz 	InputFlag
		;
Command_IP_Main:		
		clc 								; carry being clear means last print wasn't comma/semicolon
		;
		;		Main Input/Print Loop
		;
_CPLoop:
		php 								; save "last action" flag

		lda 	(codePtr),y 				; get next character
		cmp  	#PR_LSQLSQENDRSQRSQ 		; end of line or colon, exit now.
		beq 	_CPExit 					; without consuming
		cmp 	#PR_COLON
		beq 	_CPExit

		pla 								; throw last action flag		
		;
		;		Decide what's next
		;
		lda 	(codePtr),y 				; next character and consume
		iny
		cmp 	#PR_SEMICOLON				; is it a semicolon (syntax seperator)
		beq 	_CPContinueWithSameLine
		cmp 	#PR_COMMA 					; comma (tab)
		beq 	_CPTab
		dey 								; undo the get.
		;
		;		check for INPUT state and identifier
		;
		bit 	InputFlag 					; check for Input
		bpl	 	_CPNotInput
		and 	#$C0 						; check 40-7F e.g. an identifier.
		cmp 	#$40
		bne 	_CPNotInput 				
		jsr 	_CPInputCode 				; input code
		bra 	Command_IP_Main 			; and go round again.
		;
		;		Not input so it's print.
		;
_CPNotInput:		
		jsr 	EXPEvaluateExpression 		; evaluate expression.
		bit 	IFR0+IExp 					; is it a number ?
		bpl 	_CPNumber
		;
		;		Print string
		;
		phy 
		clc 								; string address to YX
		lda 	IFR0+IM0
		tax
		lda 	IFR0+IM1
		tay 	
		jsr 	CPPrintYX 					; print YX
		ply
		bra 	Command_IP_Main 			; loop round clearing carry so NL if end		
		;
		;		Print number
		;
_CPNumber:
		phy
		jsr 	IFloatFloatToStringR0 		; convert to string at YX 
		jsr 	CPPrintYX 					; print string at YX
		ply		
		bra 	Command_IP_Main				; loop round clearing carry so NL if end		
		;
		;		Comma, Semicolon, Tab come here.
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
		;
		;		Input code
		;
_CPInputCode:
		jsr 	EXPTermR0 					; get the term, the thing being input to
											; (type being identifier is checked above)
		phy 								; save position
		jsr 	CPInputA					; input a line to YX

		lda 	IFR0+IExp 					; string ?
		bmi 	_CPInputString
		;
		;		Number Input Code
		;
		lda 	IFR0+IM0 					; push target address on stack
		pha
		lda 	IFR0+IM1
		pha
		;
		stx 	zTemp0 						; use VAL Code to convert.
		sty 	zTemp0+1
		jsr 	VALConversionZTemp0

		pla 								; do the assign.
		sta 	zTemp0+1
		pla
		sta 	zTemp0
		jsr 	AssignNumber

		ply
		rts

		;
		;										String Input Code
		;

_CPInputString:
		lda 	IFR0+IM0 					; copy target address to zTemp0
		sta 	zTemp0
		lda 	IFR0+IM1
		sta 	zTemp0+1
		;
		stx 	IFR0+IM0 					; string YX in result register
		sty 	IFR0+IM1
		jsr 	AssignString 				; assign the string
		ply 								; exit
		rts

; ************************************************************************************************
;
;							Print string at YX on output device
;
; ************************************************************************************************

CPPrintYX:
		stx 	zTemp0
		sty 	zTemp0+1
		lda 	(zTemp0)
		tax
		beq 	_CPPrintExit
		ldy 	#1
_CPPrintAYXLoop:
		lda 	(zTemp0),y
		jsr 	CPPrintA
		iny
		dex
		bne 	_CPPrintAYXLoop
_CPPrintExit:	
		rts		

; ************************************************************************************************
;
;								Input/Print vectors (potentially !)
;
; ************************************************************************************************

CPInputA:
		jmp 	OSEnterLine
CPPrintA:
		jmp 	OSWriteScreen
		.send code

;:[INPUT]
; Inputs values into variables. The syntax is the same as print, so semicolons, colons and quoted
; text works as normal.
; { INPUT "Enter your name ";a$ }

;:[PRINT]\
; Prints the following items on the display, can be a mixture of strings and numbers. A semicolon
; can be used to seperate elements, and a comma to move to the next tab position. If the last 
; character is not a semicolon or comma, a new line is printed after this.\
; { PRINT "Hello";name$,"tabbed" for example.}

		.section storage
InputFlag:
		.fill 	1
		.send storage

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
