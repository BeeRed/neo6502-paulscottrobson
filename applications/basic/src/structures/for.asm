; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		for.asm
;		Purpose:	For/Next loops
;		Created:	2nd June 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

; ************************************************************************************************
;
;										FOR command
;
; ************************************************************************************************

Command_FOR:	;; [for]

		lda 	#STK_FOR 					; create frame
		jsr 	StackOpen 
		jsr 	CommandLET 					; do "I = 1" bit

		phy 								; save variable address to +4,+5
		ldy 	#4
		lda 	zTemp0
		sta 	(basicStack),y
		iny
		lda 	zTemp0+1
		sta 	(basicStack),y
		ply

		lda 	#PR_TO 						; TO symbol required.
		jsr 	ERRCheckA
		;
		jsr 	EXPEvalNumber 				; evaluate the terminal value.
		lda 	#10 						; save in slots 10-13
		ldx 	#IFR0
		jsr 	CFSaveR0X
		;
		lda 	(codePtr),y 				; STEP here ?
		cmp 	#PR_STEP
		bne 	_CFStep1
		iny 								; consume step
		jsr 	EXPEvalNumber 				; evaluate STEP
		bra 	_CFWriteStep

_CFStep1:
		ldx 	#IFR0 						; default R0, 1
		lda 	#1
		jsr 	IFloatSetByte
		;
		phy 								; check for fast loop,step 1, integer start/end.
		ldy 	#4 							; get variable address
		lda 	(basicStack),y
		sta 	zTemp0
		iny
		lda 	(basicStack),y
		sta 	zTemp0+1
		ldy 	#IExp 						; check that's an integer
		lda 	(zTemp0),y
		bne 	_CFNotOptimised
		ldy 	#13 						; check terminal value is integer.
		lda 	(basicStack),y
		bne 	_CFNotOptimised

		lda 	#$80 						; set the step so it's a string/
		sta 	IFR0+IExp		
_CFNotOptimised:
		ply		

_CFWriteStep:
	
		ldx 	#IFR0 						; Write to additive.
		lda 	#6
		jsr 	CFSaveR0X
		
		jsr 	STKSaveCodePosition 		; save loop position
		rts

;:[for .. next]
; Repeats a block of code a given number of times. The index variable (I in the examples) starts 
; at the first value and counts towards the second. The step is 1 by default, but can be any 
; number.
; { for i = 1 to 10:print i:next }
; { for i = 1 to 20 step 2:print i:next }

; ************************************************************************************************
;
;									Load RX from (Stack),Y
;
; ************************************************************************************************

CFLoadR0X:
		phy
		tay
		lda 	(basicStack),y
		sta 	IM0,x
		iny
		lda 	(basicStack),y
		sta 	IM1,x
		iny
		lda 	(basicStack),y
		sta 	IM2,x
		iny
		lda 	(basicStack),y
		sta 	IExp,x
		ply
		rts

; ************************************************************************************************
;
;									Save RX to (Stack),Y
;
; ************************************************************************************************

CFSaveR0X:
		phy
		tay
		lda 	IM0,x
		sta 	(basicStack),y
		iny
		lda 	IM1,x
		sta 	(basicStack),y
		iny
		lda 	IM2,x
		sta 	(basicStack),y
		iny
		lda 	IExp,x
		sta 	(basicStack),y
		ply
		rts

; ************************************************************************************************
;
;										NEXT command
;
; ************************************************************************************************

Command_NEXT:	;; [next]
		lda 	#STK_FOR
		jsr 	StackCheckFrame
		;
		phy 								; check optimised loop
		ldy 	#9
		lda 	(basicStack),y
		ply
		asl 	a
		bcs 	_CNOptimised
		;
		jsr 	_CNLoadValue 				; load index value to R0.

		ldx 	#IFR1 						; load adding value to R1.
		lda 	#6
		jsr 	CFLoadR0X
		jsr 	IFloatAdd 					; add them together and write back.
		jsr 	_CNSaveValue 

		lda 	#10 						; terminal value in R1
		ldx 	#IFR1
		jsr 	CFLoadR0X
		jsr 	IFloatCompare 				; compare terminal vs current

		ldx 	#IFR0 						; if zero, e.g. equal, loop back.
		jsr 	IFloatCheckZero
		beq 	_CNLoopBack
		;
		lda 	IFR0+IExp 					; if sign compare and sign add match, loop back.
		phy
		ldy 	#6+IExp
		eor 	(basicStack),y
		ply
		and 	#IFSign
		beq 	_CNLoopBack
_CNExitLoop:		
		jsr 	StackClose		 			; return
		rts

_CNLoopBack:		
		jsr 	STKLoadCodePosition 		; loop back
		rts
		;
		;		Optimised version (step 1, integer values)
		;
_CNOptimised:
		phy

		ldy 	#4 							; copy address of index variable to zTemp2
		lda 	(basicStack),y
		sta 	zTemp2
		iny
		lda 	(basicStack),y
		sta 	zTemp2+1
		;
		ldy 	#$FF 						; increment that value. this won't go round 
_CNIncrement: 								; for ever because maxint is $7FFFF
		iny		
		lda 	(zTemp2),y
		inc 	a
		sta 	(zTemp2),y
		beq 	_CNIncrement
		;
		clc 								; point zTemp0 to terminal value
		lda 	basicStack
		adc 	#10
		sta 	zTemp0
		lda 	basicStack+1
		adc 	#0
		sta 	zTemp0+1
		;
		ldy 	#1 							; compare value to terminal.
		clc
		lda 	(zTemp2) 		
		sbc 	(zTemp0)
		lda 	(zTemp2),y
		sbc 	(zTemp0),y
		iny
		lda 	(zTemp2),y
		sbc 	(zTemp0),y
		ply
		bcs 	_CNExitLoop
		bra 	_CNLoopBack

; ************************************************************************************************

_CNLoadValue:
		phy
		ldy 	#4 							; copy address to zTemp2
		lda 	(basicStack),y
		sta 	zTemp2
		iny
		lda 	(basicStack),y
		sta 	zTemp2+1
		;
		ldy 	#0 							; copy dword at zTemp2 to IFR0
		lda 	(zTemp2),y
		sta 	IFR0+IM0
		iny
		lda 	(zTemp2),y
		sta 	IFR0+IM1
		iny
		lda 	(zTemp2),y
		sta 	IFR0+IM2
		iny
		lda 	(zTemp2),y
		sta 	IFR0+IExp
		ply
		rts

_CNSaveValue:
		phy
		ldy 	#0
		lda 	IFR0+IM0
		sta 	(zTemp2),y
		iny		
		lda 	IFR0+IM1
		sta 	(zTemp2),y
		iny		
		lda 	IFR0+IM2
		sta 	(zTemp2),y
		iny		
		lda 	IFR0+IExp
		sta 	(zTemp2),y
		ply
		rts

; ************************************************************************************************
;
;		+0 		Token
;		+1,2,3 	Loop back position
;		+4,+5 	Address of the index variable (numeric)
;		+6..9	Additive value.
;		+10..13 Terminal value.
;
;		If Bit 31 of the additive value is set (would normally indicate a string), this means
; 		that the index value is an integer, the additive value is 1, and the terminal value
;		is an integer, allowing for optimisation.
;
; ************************************************************************************************

		.send code

; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
