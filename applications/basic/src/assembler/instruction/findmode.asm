; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		findmode.asm
;		Purpose:	Work out the address mode
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;							Work out address mode & operand (in R0)
;
;			  Everything initial works out as absolute. ZP is checked specially.
;
; ************************************************************************************************

		.section code

ASIdentifyAddressMode:
		.debug
		lda 	(codePtr),y 				; what's next ?
		cmp 	#PR_LSQLSQENDRSQRSQ  		; EOL or : => implied
		beq 	_ASImplied
		cmp 	#PR_COLON
		beq 	_ASImplied
		;
		cmp 	#PR_HASH 					; # then immediate
		beq 	_ASImmediate
		;
		cmp 	#PR_LPAREN 					; if ( then indirection of some sort.
		beq 	_ASIndirect
		;
		;		Handle abs abs,x abs,y
		;
		jsr 	EXPEvalInteger16 			; remaining choices are nnnn nnnn,x and nnnn,y
		jsr 	ASCheckIndex 				; check index follows
		bcs 	_ASIndexed 					; index found ? then it will return X Y
		lda 	#AM_ABSOLUTE 				; otherwise return A
_ASIndexed:
		rts		
		;
		;		Implied (A not supported as yet)
		;
_ASImplied:
		lda 	#AM_IMPLIED 				; return implied mode		
		rts
		;
		;		Immediate
		;
_ASImmediate:
		iny 								; consume #
		jsr 	EXPEvalInteger8 			; 8 bit operand
		lda 	#AM_IMMEDIATE
		rts
		;
		;		Indirect, Indirect X,Indirect Y
		;
_ASIndirect:
		iny 								; consume the open bracket
		jsr 	EXPEvalInteger16 			; we do this because of jmp (xxxx) and (xxxx,x)
		jsr 	ASCheckIndex 				; look for ,X
		bcs 	_ASInternalIndirect 		; ,X or ,Y found.
		;
		jsr 	ERRCheckRParen 				; not found. Must be ) or ),Y
		jsr 	ASCheckIndex
		bcc 	_ASIIndirect 				; if ,[XY] not found, then exit assuming (xxxx)
		cmp 	#"Y" 						; must be ,Y in this mode.
		bne 	ASCISyntax 					; if not error
		lda 	#AM_ZINDY 					; return (nn),y
		rts

_ASIIndirect:
		lda 	#AM_ABSOLUTEI 				; might be jmp (xxxx)
		rts
		;
		;		Found lda (nnnn,[XY]
		;
_ASInternalIndirect:		
		cmp 	#"X"						; must have been X
		bne 	ASCISyntax 					; error if (nn,y) not allowed !
		jsr 	ERRCheckRParen 				; check complete e.g. (nnnn,x)
		lda 	#AM_ABSOLUTEIX 				; because it might be JMP (nnnn,x)
		rts

ASCISyntax:		
		.error_syntax 						; , without X or Y

; ************************************************************************************************
;
;					See if ,X or ,Y follows ; if so CS and A = X/Y code else CC.
;
; ************************************************************************************************

ASCheckIndex:
		lda 	(codePtr),y 				; check comma ?
		cmp 	#PR_COMMA
		bne 	_ASCIFail
		iny 								; consume comma
		lda 	(codePtr),y
		cmp 	#'X'-'A'+$40 				; check if X or Y
		beq 	_ASCIFound
		cmp 	#'Y'-'A'+$40
		bne 	ASCISyntax
_ASCIFound:
		tax 								; save X or Y in X
		iny 								; consume
		lda 	(codePtr),y 				; check followed by end of identifier
		iny
		cmp 	#$7C
		bne 	ASCISyntax
		txa 								; get X/Y back
		inc 	a 							; convert to 'X' or 'Y' characters
		sec
		rts

_ASCIFail:
		clc
		rts		

; ************************************************************************************************
;
;		Possible address modes
;			EOL : first =>
;					Implied, also used for A.
; 			( first =>
;					(nn) (nn,x) or (nn),y
;			# first =>
;					#nn
;			Otherwise =>
;					expression followed by ,x or ,y can be zero or absolute depending on the
;					operand.
;		
; ************************************************************************************************

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

