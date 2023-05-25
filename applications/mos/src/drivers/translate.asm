; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		translate.asm
;		Purpose:	PS/2 Scancode conversion
;		Created:	25th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

		.section code

ifkey	.macro
		lda 	OSKeyStatus+\1
		and 	#\2
		.endm

; ************************************************************************************************
;
;				Convert PS/2 scancode to ASCII, returns CS if failed, CC/A if okay
;
; ************************************************************************************************

OSTranslateToASCII:
		tax
		lda 	OSASCIIFromScanCode,x 		; get ASCII keystroke from scan code
		beq 	_OSTTAFail 					; wrong keyboard map/type ?
		tax 								; save in X
		.ifkey 	OS_KP_LEFTCTRL_ROW,OS_KP_LEFTCTRL_COL
		bne 	_OSTTAControl 				; check for CTRL + x
		.ifkey 	OS_KP_LEFTSHIFT_ROW,OS_KP_LEFTSHIFT_COL
		bne 	_OSTTAShift 				; check for left/right shift
		.ifkey 	OS_KP_RIGHTSHIFT_ROW,OS_KP_RIGHTSHIFT_COL
		beq 	_OSTTAExit
_OSTTAShift:
		cpx 	#"a"						; check alpha
		bcc 	_OSTTANotAlpha
		cpx 	#"z"+1 						
		bcs 	_OSTTANotAlpha
		txa									; capitalise.
		eor 	#$20
		tax
		bra 	_OSTTAExit

_OSTTANotAlpha:								; not alpha, check the table.
		stx 	rTemp0 						; save ASCII code.
		ldy 	#0 							; check the shift table
_OSTTACheckShiftTable:		
		lda 	OSShiftFixTable+1,y 		; tax = shifted character
		tax
		lda 	OSShiftFixTable,y 			; check unshifted match
		cmp 	rTemp0
		beq 	_OSTTAExit
		iny 								; next pair
		iny
		lda 	OSShiftFixTable,y 			; until all checked
		bpl 	_OSTTACheckShiftTable
		ldx 	rTemp0 						; not shiftable.
		bra 	_OSTTAExit
_OSTTAControl:
		txa
		and 	#31
		tax
_OSTTAExit:
		txa
		clc
		rts

_OSTTAFail:
		sec
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

