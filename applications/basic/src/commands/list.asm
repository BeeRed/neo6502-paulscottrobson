; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		list.asm
;		Purpose:	List program
;		Created:	6th June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										LIST Command
;
; ************************************************************************************************

		.section code

Command_LIST:	;; [list]
		lda 	#6 							; set default spacing.
		sta 	CLIndent
		stz 	CLFrom 						; default from 
		stz 	CLFrom+1
		lda 	(codePtr),y 				; is there a to line (e.g. LIST ,xxx)
		cmp 	#PR_COMMA
		beq 	_CLToLine
		cmp 	#PR_LSQLSQENDRSQRSQ 		; EOL, default TO
		beq 	_CLDefaultTo
		jsr 	EXPEvalInteger16 			; from value *and* to value now.
		lda 	IFR0+IM0
		sta 	CLFrom
		sta 	CLTo
		lda 	IFR0+IM1
		sta 	CLFrom+1
		sta 	CLTo+1
		lda 	(codePtr),y
		cmp 	#PR_LSQLSQENDRSQRSQ 		; that's the lot ?
		beq 	_CLList
_CLToLine:		
		lda 	(codePtr),y 				; what follows.	
		cmp 	#PR_LSQLSQENDRSQRSQ 		; EOL, default TO
		beq 	_CLDefaultTo		
		jsr 	ERRCheckComma 				; sep comma
		lda 	(codePtr),y 				; if it is just LIST , then default TO
		cmp 	#PR_LSQLSQENDRSQRSQ
		beq 	_CLDefaultTo
		jsr 	EXPEvalInteger16 			; there's a To value.
		lda 	IFR0+IM0
		sta 	CLTo
		lda 	IFR0+IM1
		sta 	CLTo+1
		bra 	_CLList
_CLDefaultTo:
		lda 	#$FF
		sta 	CLTo
		sta 	CLTo+1
_CLList:
		lda 	PGMBaseHigh 				; back to the program start
		sta 	codePtr+1
		stz 	codePtr
		;
		ldx 	#OSWriteScreen & $FF 		; tokenise output to screen.
		ldy 	#OSWriteScreen >> 8
		jsr 	TOKSetDetokeniseOutput
		;
		;		Main loop
		;
_CLLoop:
		lda 	(codePtr) 					; finished
		beq 	_CLExit
		jsr 	OSKeyboardDataProcess
		jsr 	OSCheckBreak 				; check escape.
		bne 	_CLBreak
		ldx 	#CLFrom-CLFrom 				; compare line number vs from
		jsr 	_CLCompareLine
		cmp 	#255 						; < from then skip
		beq 	_CLNext
		ldx 	#CLTo-CLFrom   				; compare line number vs IFR0
		jsr 	_CLCompareLine
		cmp 	#1 							; > to then skip
		beq 	_CLNext
		;
		;		Actually list the line.
		;
		ldy 	#2 							; print line #
		lda 	(codePtr),y
		tax
		dey
		lda 	(codePtr),y
		jsr 	WriteIntXA
		;
		;		Get the indent, save it and add now if negative.
		;
		jsr 	GetIndent
		pha		
		bpl 	_CLSpacing 					; skip if +ve
		clc 								; move backwards
		adc 	CLIndent
		cmp 	#6 							; no further than this
		bcs 	_CLSaveIndent
		lda 	#6
_CLSaveIndent:		
		sta 	CLIndent 					; update the indent.
_CLSpacing:		
		lda 	#32
		jsr 	OSWriteScreen
		jsr 	OSGetScreenPosition
		cpx 	CLIndent
		bne 	_CLSpacing

		ldy 	codePtr+1 					; point YX to tokenised code/
		lda 	codePtr
		clc 
		adc 	#3
		tax
		bcc 	_CLNoCarry2
		iny
_CLNoCarry2:	
		jsr 	TOKDetokenise		
		lda 	#13	 						; next line
		jsr 	OSWriteScreen

		pla 								; get indent up
		bmi 	_CLNext 				 	; if +ve add to indent
		clc
		adc 	CLIndent
		sta 	CLIndent
_CLNext:
		clc 								; advance to next line.
		lda 	(codePtr)
		adc 	codePtr
		sta 	codePtr
		bcc 	_CLNoCarry
		inc 	codePtr+1
_CLNoCarry:		
		bra 	_CLLoop		
_CLExit:
		jmp 	WarmStart		
_CLBreak:
		.error_break
		
_CLCompareLine:
		ldy 	#1
		sec
		lda 	(codePtr),y
		sbc 	CLFrom,x
		sta 	zTemp0
		iny
		lda 	(codePtr),y
		sbc 	CLFrom+1,x
		bcc 	_CLIsNegative
		bne 	_CLIsPositive
		lda 	zTemp0
		bne 	_CLIsPositive
		rts
_CLIsPositive:		
		lda 	#1
		rts
_CLIsNegative:
		lda 	#255		
		rts

		.send code
		
		.section storage
CLFrom:	
		.fill 	2
CLTo:		
		.fill 	2
CLIndent:
		.fill 	1		
		.send storage

;:[list start,end]
; Program listing. Start and end are optional.
				
; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;		28/06/23  		Aligned code listing.
;
; ************************************************************************************************

