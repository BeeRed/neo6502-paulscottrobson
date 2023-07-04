; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		dir.asm
;		Purpose:	Show Directory
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										DIR Command
;
; ************************************************************************************************

		.section code

Command_DIR:	;; [dir]
		phy
		sec 								; reset read
		jsr 	OSReadDirectory
_CDLoop:clc
		jsr 	OSReadDirectory 			; read next
		bcs 	_CDExit 					; no more		
		stx 	zTemp0
		sty 	zTemp0+1
		jsr	 	OSWriteString				; write name
_CDPad:		
		lda 	#32
		jsr 	OSWriteScreen
		jsr 	OSGetScreenPosition
		cpx 	#16
		bcc 	_CDPad
		ldy 	#17
		lda 	(zTemp0),y
		tax
		dey
		lda 	(zTemp0),y
		jsr 	WriteIntXA
		ldx 	#_CDTail & $FF
		ldy 	#_CDTail >> 8
		jsr 	OSWriteString
		bra 	_CDLoop
_CDExit:ply
		rts		
		
_CDTail:
		.byte 	_CDTail2-*-1
		.text 	" bytes.",13
_CDTail2:				
		.send code

;:[DIR]\
; Lists files on the current storage media

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

