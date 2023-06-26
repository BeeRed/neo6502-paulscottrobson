; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		random.asm
;		Purpose:	Random number generators
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									random number 0..1 (use 1 !)
;
; ************************************************************************************************

		.section code	

EXPUnaryRnd: ;; [rnd(]
		jsr 	EXPEvalNumber 				; number to R0
		jsr 	ERRCheckRParen 				; )
		ldx 	#IFR0 						; load random number to R0
		jsr 	EXPLoadInRandom
		lda 	#64-23 						; hack the exponent to make it in the range 0-1.
		sta 	IFR0+IExp 

		rts

;: [rnd(1)]\
; Returns a random number between 0 and 1. Always use the parameter 1 at present.\
; { print rnd(1) } prints , say 0.6307

; ************************************************************************************************
;
;								Random number 0..n-1
;
; ************************************************************************************************

ExpUnaryRand: ;; [rand(]
		jsr 	EXPEvalInteger 				; integer to R0
		jsr 	ERRCheckRParen 				; )
		ldx 	#IFR1 						; random to R1
		jsr 	EXPLoadInRandom
		jsr 	IFloatModulusInteger 		; calculate mod r1,r0
		rts

;: [rand(number)]\
; Returns a random integer between 0 and number-1. \
; { print rand(4) } prints one of 0,1,2 or 3.

; ************************************************************************************************
;
;								Random number to mantissa Rx
;
; ************************************************************************************************

EXPLoadInRandom:
		jsr 	IFloatSetZero 				; zero it
		jsr 	EXPRandom32 				; do a 23 bit number.
		sta 	IM0,x
		jsr 	EXPRandom32
		sta 	IM1,x
		jsr 	EXPRandom32
		and 	#$7F
		sta 	IM2,x
		rts

; ************************************************************************************************
;
;									32 bit random galois
;
; ************************************************************************************************

EXPRandom32:
		phy
		ldy 	#8
		lda 	EXPSeed+0
		ora 	EXPSeed+1
		ora 	EXPSeed+2
		ora 	EXPSeed+3
		bne 	_EXPRNoReset
		inc 	EXPSeed+0
		ldy 	#16
		sty 	EXPSeed+3
_EXPRNoReset:
		lda 	EXPSeed+0
_EXPRLoop:	
		asl		a
		rol 	EXPSeed+1
		rol 	EXPSeed+2
		rol 	EXPSeed+3
		bcc 	_EXPRNoEOR
		eor 	#$C5
_EXPRNoEOR:	
		dey
		bne 	_EXPRLoop
		sta 	EXPSeed+0
		ply
		rts
		.send code

		.section storage
EXPSeed:
		.fill 	4		
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

