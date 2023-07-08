; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		initialise.asm
;		Purpose:	Initialise the Filesystem library
;		Created:	1st July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Initialise the Filesystem
;
; ************************************************************************************************

		.section code

FSInitialise:
		stz 	sectorCount 				; initial values to read $00
		stz 	sectorCount+1
		;
		;		Read in from the first sector (unaffected by size or count !)
		;		the sector size and count values. 
		;
		;		Note in this version, a maximum of 256 sectors only allowed.
		;
		lda 	#0 							; read header sector 0
		jsr 	FSReadHeaderA

		lda 	sectorHeader+2 				; copy sector count
		sta 	sectorCount
		lda 	sectorHeader+3
		sta 	sectorCount+1

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

