; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		directory.asm
;		Purpose:	Read a directory
;		Created:	2nd July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Directory Read.
;
;	Enter with CS to initialise.
;
;	Each subsequent call returns either CS (end of directory)
;										CC (record available), YX points to name (len prefix)
;
; ************************************************************************************************

		.section code

OSReadDirectory:
		bcs 	_OSRDReset
		;
_OSRDLoop:		
		jsr 	FSReadNextHeader 			; read next sector header.
		bcs 	_OSRDExit 					; exit, end of file space, CS
		lda 	shFirstNext 				; is it an 'F' record
		cmp 	#'F'
		bne 	_OSRDLoop
		ldx 	#shNameLength & $FF 		; return the buffer address
		ldy 	#shNameLength >> 8
		clc 								; return with carry clear.
		rts

_OSRDReset:
		stz 	currentSector 				; back to the start.
_OSRDExit:		
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

