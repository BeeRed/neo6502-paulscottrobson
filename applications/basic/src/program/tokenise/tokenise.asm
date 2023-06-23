; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		tokenise.asm
;		Purpose:	Tokenise the line from the data source.
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;								Tokenise line. Data source function in YX. 
;
; ************************************************************************************************

TOKTokenise:
		sty 	TOKDataSource+1 			; save source routine pointer
		stx 	TOKDataSource
		;
		lda 	#1 							; set first element flag.
		sta 	TOKIsFirstElement
		;
		lda 	#3 							; set the line length to three for the 
		sta 	TOKLineSize 				; line length itself and the line numbers.
		stz 	TOKLineNumber
		stz 	TOKLineNumber+1
		
		; ----------------------------------------------------------------------------------
		;
		;							Main tokenising loop
		;
		; ----------------------------------------------------------------------------------

_TOKMainLoop:
		jsr 	TOKGet 						; what follows.
		cmp 	#0 							; if zero, we are complete
		beq 	_TOKExit 
		cmp 	#' '						; space, consume and loop back.
		bne 	_TOKElement
		jsr 	TOKGetNext
		bra 	_TOKMainLoop
		;
		;		Check and dispatch various items that can be tokenised.
		;
_TOKElement:		
		jsr 	TOKIsDigit 					; is it 0..9 
		bcc 	_TOKNotDigit
		jsr 	TOKTokeniseInteger 			; get integer
		bcs 	_TOKFail 					; did it fail ?
		stz 	TOKIsFirstElement 			; clear first element flag
		bra 	_TOKMainLoop
_TOKNotDigit:
		stz 	TOKIsFirstElement 			; clear first element flag
		cmp 	#"$"						; check for hexadecimal ?
		bne 	_TOKNotHex
		jsr 	TOKTokeniseHexadecimal 
		bcs 	_TOKFail
		bra 	_TOKMainLoop
_TOKNotHex:
		cmp 	#"."						; is it decimal e.g. .012345 etc.
		bne 	_TOKNotDecimal
		jsr 	TOKTokeniseDecimals
		bcs 	_TOKFail
		bra 	_TOKMainLoop
_TOKNotDecimal:
		cmp 	#'"'						; quoted string ?
		bne 	_TOKNotString
		jsr 	TOKTokeniseString
		bcs 	_TOKFail
		bra 	_TOKMainLoop
_TOKNotString:
		jsr 	TOKIsAlpha 					; identifier ?
		bcs 	_TOKIdentifier
		jsr 	TOKTokenisePunctuation 		; punctuation
		bcs 	_TOKFail
		bra 	_TOKMainLoop
_TOKIdentifier:
		jsr 	TOKTokeniseIdentifier 		; identifier/token.
		bcs 	_TOKFail
		bra 	_TOKMainLoop

_TOKExit:									
		lda 	#PR_LSQLSQENDRSQRSQ 		; write EOL
		jsr 	TOKWriteA
		clc									; return with carry set.
		rts		
_TOKFail:
		sec
		rts		

; ************************************************************************************************
;
;							Write a byte to the token buffer
;
; ************************************************************************************************

TOKWriteA:
		phx
		ldx 	TOKLineSize
		sta 	TOKLineSize,x
		stz 	TOKLineSize+1,x 			; makes it look like a line on its own for RUN.
		plx
		inc 	TOKLineSize
		rts

; ************************************************************************************************
;
;								Get/Get advance
;
; ************************************************************************************************

TOKGet:	
		clc
		jmp 	(TOKDataSource)

TOKGetNext:
		sec	
		jmp 	(TOKDataSource)

		.send code

		.section storage
TOKDataSource:
		.fill 	2
TOKIsFirstElement:
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

