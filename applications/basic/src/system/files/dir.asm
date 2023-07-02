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
		lda 	#32
		jsr 	OSWriteScreen
		ldy 	#17
		lda 	(zTemp0),y
		tax
		dey
		lda 	(zTemp0),y
		jsr 	WriteIntXA

		lda 	#13
		jsr 	OSWriteScreen
		bra 	_CDLoop
_CDExit:ply
		rts		
		
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

