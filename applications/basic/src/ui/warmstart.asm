; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		warmstart.asm
;		Purpose:	Handle warm start
;		Created:	6th June 2023
;		Reviewed: 	No
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
WarmStartNewLine:		
		lda 	#13
		jsr 	OSWriteScreen
WarmStartNoPrompt:
		ldx 	#$FF 						; 6502 stack reset.
		txs
		jsr 	OSEditNewLine 				; edit
		cmp 	#27  						; ESC new line/ignore
		beq 	WarmStartNewLine  		
		cmp 	#13 						; anything other than CR keep going
		bne 	WarmStartNoPrompt
		jsr 	OSWriteScreen 				; echo the CR

		inx 								; skip length byte to make it ASCIIZ
		bne 	_WSSkip
		iny
_WSSkip:		
		stx 	zTemp2 						; save address
		sty 	zTemp2+1

		ldx 	#TOKGetCharacter & $FF 		; tokenise it.
		ldy 	#TOKGetCharacter >> 8
		sec
		jsr 	TOKTokenise		

		lda 	TOKLineNumber 				; if line number zero
		ora 	TOKLineNumber+1
		bne 	_WSLineEdit

		lda 	#TOKLineSize & $FF 			; execute code.
		sta 	codePtr
		lda 	#TOKLineSize >> 8
		sta 	codePtr+1
		jmp 	RUNNewLine
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

