; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		warmstart.asm
;		Purpose:	Handle warm start
;		Created:	6th June 2023
;		Reviewed: 	8th July 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;									Warm start entry point
;
; ************************************************************************************************

WarmStart:
		lda 	#"O" 						; Ready prompt
		jsr 	OSWriteScreen
		lda 	#"k"
		jsr 	OSWriteScreen
WarmStartNewLine:		 					; new line only
		lda 	#13
		jsr 	OSWriteScreen
WarmStartNoPrompt:
		ldx 	#$FF 						; 6502 stack reset.
		txs
		jsr 	OSScreenLine 				; edit
		inx 								; skip length byte to make it ASCIIZ
		bne 	_WSSkip
		iny
_WSSkip:		
		stx 	zTemp2 						; save address for tokeniser getter.
		sty 	zTemp2+1
		lda 	(zTemp2) 					; see if it's an empty line.
		beq 	WarmStartNoPrompt 			; if so ignore empty line.

		ldx 	#TOKGetCharacter & $FF 		; tokenise it.
		ldy 	#TOKGetCharacter >> 8
		sec 
		jsr 	TOKTokenise		
		bcs 	_WSSyntax 					; error in tokenising.
		
		lda 	TOKLineNumber 				; if line number zero
		ora 	TOKLineNumber+1
		bne 	_WSLineEdit 				; it's an editing command
		;
		;		Run line - run from the tokenised buffer.
		;
		lda 	#TOKLineSize & $FF 			; execute code.
		sta 	codePtr
		lda 	#TOKLineSize >> 8
		sta 	codePtr+1
		jmp 	RUNNewLine
		;
		;		Editing.
		;
_WSLineEdit:
		jsr 	PGMDeleteLine 				; delete line, perhaps ?
		lda 	TOKLineSize 				; check line is empty.
		cmp 	#4
		beq 	_WSNoInsert 				
		jsr 	PGMInsertLine				; if not, maybe insert
_WSNoInsert:
		jsr 	ClearCode 					; clear variables etc.
		bra 	WarmStartNoPrompt
		;
_WSSyntax:
		.error_syntax

; ************************************************************************************************
;
;			Get tokenise char. Get CC, Get advance CS, return zero when out of data
;
; ************************************************************************************************

TOKGetCharacter:
		lda 	(zTemp2)
		bcc 	_GSNoIncrement
		inc 	zTemp2
		bne 	_GSNoIncrement
		inc 	zTemp2+1
_GSNoIncrement:
		cmp 	#0
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
;		26/06/23 		Clear variables etc. after code editing.
;
; ************************************************************************************************

