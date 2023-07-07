; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		calcopcode.asm
;		Purpose:	Calculate the opcode hash
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Calculate opcode hash
;								 (see assembly.py assem2.py)
;
; ************************************************************************************************

		.section code

ASCalculateOpcodeHash:
		lda 	(codePtr),y 				; check for AND token.
		cmp 	#PR_AND
		beq 	_ASCOAnd

		jsr 	_ASCGetCharacter 			; get first alphanumeric character 0-25 rep A-Z
		jsr 	_ASCProcess 				; go through the shift/multiply process
		sta 	zTemp0

		jsr 	_ASCGetCharacter 			; get second alphanumeric character
		clc
		adc 	zTemp0 						; add previous result.

		rol 	a 							; 8 bit rotate left
		adc 	#0

		eor 	#165 						; XOR with 165

		jsr 	_ASCProcess 				; and shift/multiply again.
		sta 	zTemp0

		jsr 	_ASCGetCharacter 			; get third character
		clc
		adc 	zTemp0 						; and add
		pha

		lda 	(codePtr),y 				; check followed by
		cmp 	#$7C 						; $7C which identifies end of identifier.
		bne 	_ASCSyntax
		iny 

		pla 								; restore and exit
		rts

_ASCOAnd:
		iny 								; consume the token.
		lda 	#106 						; the hash value for "AND"
		rts 		
;
;		Get next character, check it is A-Z
;		
_ASCGetCharacter:
		lda 	(codePtr),y 				; get and consume character
		iny
		sec
		sbc 	#$40 						; shift $40 -> $00
		bmi 	_ASCSyntax 					; check range.
		cmp 	#26 		
		bcs 	_ASCSyntax
		rts
;
;		Part of hashing calculation a = a x 5 + 68
;
_ASCProcess:
		sta 	zTemp0+1 					; multiply by 5
		asl 	a
		asl 	a
		clc
		adc 	zTemp0+1
		;
		clc 								; add 68
		adc 	#68 
		rts

_ASCSyntax:
		.error_syntax

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

