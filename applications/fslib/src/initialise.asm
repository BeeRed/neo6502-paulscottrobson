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
		stz 	sectorSize
		stz 	sectorSize+1
		;
		;		Read in from the first sector (unaffected by size or count !)
		;		the sector size and count values. 
		;
		;		Note in this version, a maximum of 256 sectors only allowed.
		;
		lda 	#0 							; open sector 0 to read.
		jsr 	FSHOpenRead
		;
		jsr 	FSHRead 					; read header.
		jsr 	FSHRead
		;
		jsr 	FSHRead 					; read # of sectors.
		sta 	sectorCount
		jsr 	FSHRead
		sta 	sectorCount+1

		jsr 	FSHRead 					; power of sectors
		inc 	sectorSize
_FSICalcSS:
		asl 	sectorSize
		rol 	sectorSize+1
		dec 	a
		bne 	_FSICalcSS

		jsr 	FSHEndCommand		
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

