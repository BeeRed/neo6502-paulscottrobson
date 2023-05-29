; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dtkidentifier.asm
;		Purpose:	Detokenise identifier
;		Created:	28th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
		
		.section code

; ************************************************************************************************
;
;										Detokenise identifier
;
; ************************************************************************************************

TOKDIdentifier:
		ldy 	#$FF
		sty 	TOKDIFirstChar
_TOKDLoop:
		tay 								; token in Y
		lda 	#'.' 						; handle special cases.
		cpy 	#$64
		beq 	_TOKDIOutput
		lda 	#'_'
		cpy 	#$65
		beq 	_TOKDIOutput
		tya 								; handle a-z
		clc
		adc	 	#$21
		cpy 	#$5A
		bcc 	_TOKDIOutput
		sec 								; handle 0-9
		sbc 	#$4B
_TOKDIOutput:		
		bit 	TOKDIFirstChar
		bpl 	_TOKDINoSpacing
		pha
		jsr 	TOKDSpacing
		stz 	TOKDIFirstChar
		pla
_TOKDINoSpacing:		
		jsr 	TOKDOutput		
		jsr 	TOKDGet 					; get next token
		cmp 	#$7C
		bcc 	_TOKDLoop
		beq 	_TOKDIExit 					; it's a number, no tail.
		lsr 	a 							; string ?
		bcc 	_TOKDICheckArray
		pha
		lda 	#"$"
		jsr 	TOKDOutput
		pla
_TOKDICheckArray:
		lsr 	a 							; array ?
		bcc 	_TOKDIExit		
		lda 	#"("
		jsr 	TOKDOutput
_TOKDIExit:
		rts		


		.send code
		
		.section storage
TOKDIFirstChar:
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

