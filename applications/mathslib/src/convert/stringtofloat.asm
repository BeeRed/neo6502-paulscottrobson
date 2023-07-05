; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		floatfromstring.asm
;		Purpose:	Convert string to integer/float accordingly.
;		Created:	25th May 2023
;		Reviewed: 	25th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;						Convert String XY length A to Float or Integer in R0.
;											(uses iTemp0)
;
; ************************************************************************************************

IFloatStringToFloatR0:
		sta 	IFCount 					; save length and positions out.
		stx 	iTemp0
		sty 	iTemp0+1

		ldx 	#IFR0 						; reset the current value.
		jsr 	IFloatSetZero
		stz 	IFSignFlag 					; clear the sign flag
		jsr 	IFSTFGetNext 				; get first
		beq 	_IFSTFFail 					; no character, fail.		
		bcc 	_IFSTFHaveChar 				; legitimate character, go do it.

		cmp 	#"-" 						; if not -, fail
		bne 	_IFSTFFail 					
		lda 	#IFSign 					; set sign flag
		sta 	IFSignFlag					
		;
		;		Integer processing loop
		;
_IFSTFLoop:
		jsr 	IFSTFGetNext 				; get next character
		bcs 	_IFSTFFail 					; bad character.
		beq 	_IFSTFExit 					; end of data
_IFSTFHaveChar:		
		cmp 	#"."						; decimal point ? if so, do the decimal code.
		beq 	_IFSTFDecimal
		jsr 	IFSTFAddR0 					; add number in (R0 = R0 x 10 + A)
		bra 	_IFSTFLoop 					; keep going until . or end.
		;
		;		Come here on error
		;
_IFSTFFail:
		sec
		bra 	_IFSTFReturn
		;
		;		Come here on dp found.
		;
_IFSTFDecimal:
		jsr 	IFSTFDecimal 				; call the decimal places code.
		bcs 	_IFSTFReturn 				; error
		;
		;		Come here if integer.
		;
_IFSTFExit:
		lda 	IFR0+IExp 					; copy sign flag in.
		ora 	IFSignFlag
		sta 	IFR0+IExp
		clc
_IFSTFReturn:		
		rts

; ************************************************************************************************
;
;					Convert String XY length A to Post Decimal value added to R0.
;										(uses iTemp0)
;
; ************************************************************************************************

IFloatAddDecimalToR0:
		sta 	IFCount 					; save it out.
		stx 	iTemp0
		sty 	iTemp0+1	

; ************************************************************************************************
;
;		Handle decimals. R0 is the integer total. Enter here for main conversion
;
; ************************************************************************************************

IFSTFDecimal:
		ldx 	#IFR0 						; push integer part on stack
		jsr 	IFloatPushRx
		ldx 	#IFR0 						; R0 is the decimal digits so far, zero initially
		jsr 	IFloatSetZero
		stz 	IFDecimalPlaces 			; zero DP.
_IFSTDLoop:
		jsr 	IFSTFGetNext 				; get next
		bcs 	_IFSTFFail2 				; bad character.
		beq 	_IFSTFComplete 				; end of data, work out the result.
		cmp 	#"."						; only one decimal
		beq 	_IFSTFExit2
		;
		jsr 	IFSTFAddR0 					; add number in (e.g. R0=R0*10+A)
		inc 	IFDecimalPlaces 			; count decimals
		lda 	IFDecimalPlaces 			; no more than 3 DP used.
		cmp 	#3
		bcc 	_IFSTDLoop
		;
		;		Now have an integer and count  ; so 3.25 will have R0 = 25 and count = 2
		;		multiply R0 by 10^count
		;
_IFSTFComplete:
		lda 	IFDecimalPlaces 			; decimals x 4 as accessing multiplier from a LUT.
		beq 	_IFSTFExit2					; if none, this is syntactically fine, just ignore
		dec 	a 							; table indexed from 1.
		asl 	a
		asl 	a
		tax
		lda 	TableTen,x 					; copy table entry into R0 - these are 0.1,0.01,0.001
		sta  	IFR1+IM0 					; 0.0001 etc, up to 5 decimals. 
		lda 	TableTen+1,x
		sta  	IFR1+IM1
		lda 	TableTen+2,x
		sta  	IFR1+IM2
		lda 	TableTen+3,x
		sta  	IFR1+IExp
		ldx 	#IFR1 						; multiply into result
		jsr 	IFloatMultiply
		ldx 	#IFR1  						; pop the integer part to R1
		jsr 	IFloatPullRx
		ldx 	#IFR1 						; add R1 to R0
		jsr 	IFloatAdd
_IFSTFExit2:
		clc
		rts

_IFSTFFail2:
		sec
		rts

; ************************************************************************************************
;
;					Fetch next character. Z if EOF. CS if bad character
;	
; ************************************************************************************************

IFSTFGetNext:
		lda 	IFCount  					; if count is zero, return with Z set.
		beq 	_IFSTFReturnOk

		lda 	(iTemp0) 					; get next character
		inc 	iTemp0 						; point at next.
		bne 	_IFSTFGNNoCarry
		inc 	iTemp0+1
_IFSTFGNNoCarry:		
		dec 	IFCount 					; dec count.
		cmp 	#"."	 					; check, dp is allowed.
		beq 	_IFSTFGOkay
		cmp 	#"0"						; < 0 fail.
		bcc 	_IFSTFGFail
		cmp 	#"9"+1 						; > 9 fail.
		bcs 	_IFSTFGFail
_IFSTFGOkay:
		cmp 	#0 							; clears Z flag		
_IFSTFReturnOk:
		clc
		rts

_IFSTFGFail:
		cmp 	#0 							; clears Z flag
		sec
		rts		

; ************************************************************************************************
;
;							Multiply R0 by 10 and add A. (uses R1)
;
; ************************************************************************************************

IFSTFAddR0:
		and 	#15 						; to int value
		pha 								; save it.
		lda 	#10 
		ldx 	#IFR1
		jsr 	IFloatSetByte
		jsr 	IFloatMultiply
		pla
		ldx 	#IFR1
		jsr 	IFloatSetByte
		jsr 	IFloatAdd
		rts

		.send code

		.section storage
IFCount:
		.fill 	1		
IFSignFlag:
		.fill 	1		
IFDecimalPlaces:
		.fill 	1		
		.send 	storage

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

