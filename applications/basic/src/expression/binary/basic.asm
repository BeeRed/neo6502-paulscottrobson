; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		basic.asm
;		Purpose:	Basic binary operators - simple links to routines.
;		Created:	26th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code	

; ************************************************************************************************
;
;									Basic operators
;
; ************************************************************************************************

EXPBinAdd:	;; [+]
		ldx 	#IFR1
		jmp 	IFloatAdd

;: [+]\
; Binary operator, adds two numbers\
; { print 3+4 } will display 7

EXPBinSub:	;; [-]
		ldx 	#IFR1
		jmp 	IFloatSubtract

;: [-]\
; Binary operator, subtracts two numbers\
; { print 3-4 } will display -1

EXPBinMul:	;; [*]
		ldx 	#IFR1
		jmp 	IFloatMultiply

;: [*]\
; Binary operator, multiplies two numbers\
; { print 3*4 } will display 12

EXPBinFDiv:	;; [/]
		ldx 	#IFR1
		jsr 	IFloatDivideFloat
		bcs 	EXPDZero
		rts

;: [/]\
; Binary operator, divides two numbers and returns a floating
; point result.\
; { print 11 / 4 } will display 2.75

EXPBinIDiv:	;; [div]
		ldx 	#IFR1
		jsr 	IFloatDivideFloat
		bcs 	EXPDZero
		jmp 	IFloatIntegerR0

;: [div]\
; Binary operator, divides two numbers and returns an integer
; result. This is useful because BASIC is faster with integers.\
; { print 11 div 4 } will display 2

EXPDZero:
		.error_divzero

EXPBinIMod: ;; [mod]
		ldx 	#IFR1
		phy
		jsr 	IFPreProcessBitwise 		; set up everything.
		bne 	EXPDRange
		jsr 	IFloatModulusInteger
		ply
		rts
EXPDRange:
		.error_range

;: [mod]\
; Binary operator, returns the remainder of the integer division 
; of two numbers.\
; { print 11 mod 4 } will display 3

;: [and]\
; Bitwise and of two numbers, which must be integers.

EXPBinAnd: ;; [and]
		ldx 	#IFR1
		jsr 	IFloatBitwiseAnd
		bcs 	EXPDRange
		rts

;: [or]\
; Bitwise or of two numbers, which must be integers.

EXPBinOr: ;; [or]
		ldx 	#IFR1
		jsr 	IFloatBitwiseOr
		bcs 	EXPDRange
		rts

;: [xor]\
; Bitwise xor of two numbers, which must be integers.

EXPBinXor: ;; [xor]
		ldx 	#IFR1
		jsr 	IFloatBitwiseXor
		bcs 	EXPDRange
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
;
; ************************************************************************************************

