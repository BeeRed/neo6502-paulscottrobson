; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		compare.asm
;		Purpose:	Compare operators
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code	

compare_equals .macro
		jsr 	EXPCompareBaseCode
		cmp 	#\1
		beq 	EXPReturnTrue
		bra 	EXPReturnFalse
		.endm

compare_not_equals .macro
		jsr 	EXPCompareBaseCode
		cmp 	#\1
		bne 	EXPReturnTrue
		bra 	EXPReturnFalse
		.endm

; ***************************************************************************************
;
; 						Return True/False as function or value
;
; ***************************************************************************************

EXPReturnTrue:		
		ldx 	#IFR0
		lda 	#1
		jsr 	IFloatSetByte
		jsr 	IFloatNegate
		rts

EXPReturnFalse:		
		ldx 	#IFR0
		jmp 	IFloatSetZero		

; ***************************************************************************************
;
; 								> = < (compare == value)
;
; ***************************************************************************************

;:	[=]	\
;		Compares two strings or numbers. Returns -1 if equal, 0 if not equal\
; 	{} if a = 1 then print "a is 1" }

EXPCompareEqual: 			;; [=]
		.compare_equals 0
		
;:	[<]	\
;		Compares two strings or numbers. Returns -1 if the first is less than the second, 0
; 		otherwise.\
;		{ if a < 1 then print "a is less than 1" }

EXPCompareLess: 			;; [<]
		.compare_equals $FF


;:	[>]	\
;		Compares two strings or numbers. Returns -1 if the first is greater than the second, 0
; 		otherwise.\
; 		{ if a > 1 then print "a is greater than 1" }

EXPCompareGreater: 			;; [>]
		.compare_equals 1

; ***************************************************************************************
;
; 								> = < (compare <> value)
;
; ***************************************************************************************

;
;:	[<>]	\
;		Compares two strings or numbers. Returns -1 if not equal, 0 if equal\
; 	{ if a <> 1 then print "a is not equal to 1" }

EXPCompareNotEqual: 		;; [<>]
		.compare_not_equals 0

;:	[<=]	\
;		Compares two strings or numbers. Returns -1 if the first is less than or equal to the 
;		second, 0 otherwise.\
; 		{ if a <= 1 then print "a is less than or equal to 1"}

EXPCompareLessEqual: 		;; [<=]
		.compare_not_equals 1

;:	[>=]	\
;		Compares two strings or numbers. Returns -1 if the first is greater than or equal to the 
;		second, 0 otherwise.\
; 		{ if a >= 1 then print "a is greater than or equal to 1"}

EXPCompareGreaterEqual: 	;; [>=]
		.compare_not_equals $FF

; ************************************************************************************************
;
;									Common compare code
;
; ************************************************************************************************

EXPCompareBaseCode:
		bit 	IFR0+IExp 					; string compare ?
		bmi 	_EXCBCString

		ldx 	#IFR1						; float compare
		jsr 	IFloatCompare
		lda 	IFR0+IM0	
		beq 	_EXCBCExit 					; return 0 if zero
		bit 	IFR0+IExp 					; return 1 if +ve
		bvc 	_EXCBCExit
		lda 	#255 						; return $FF if -ve
_EXCBCExit:		
		rts
		
_EXCBCString:
		.error_unimplemented
		phy
		ldy 	#1 							; check strings < 256 , don't do long compares.
		lda 	(IFR0),y
		ora 	(IFR1),y
		bne 	_EXCBCRange
		;
		lda 	(IFR0) 						; length of smaller of the two in X.
		cmp 	(IFR1)
		bcc 	_EXCBCSmaller
		lda 	(IFR1)
_EXCBCSmaller:
		tax
		beq 	_EXCBCMatches 				; if zero common length matches
		
_EXCBCCheckSmallerMatches:
		iny 								; compare directly as far as common length
		sec
		lda 	(IFR1),y
		sbc 	(IFR0),y
		bne 	_EXCBCExit2
		dex 
		bne 	_EXCBCCheckSmallerMatches

_EXCBCMatches:
		sec
		lda 	(IFR1) 						; common length matches. If same length equal
		sbc 	(IFR0)						; if len(r1) > len(r0) then r1 is longer

_EXCBCExit2:
		ply
		cmp 	#0
		beq 	_EXCBCReturn
		bmi 	_EXCBCFF
		lda 	#1
_EXCBCReturn:
		rts
_EXCBCFF:
		lda 	#$FF
		rts				

_EXCBCRange:
		.error_range				
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

