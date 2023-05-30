; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		info.asm
;		Purpose:	Get variable information
;		Created:	29th May 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;		Extract Variable Identifier Information - on exit Y is positioned after identifier.
;
; ************************************************************************************************

		.section code

VARGetInfo:
		tya 								; calculate the address of the identifier start.
		clc
		adc 	codePtr
		sta 	VARNameAddress
		lda 	codePtr+1
		adc 	#0
		sta 	VARNameAddress+1	
		;
		;		Calculate hash and copy name into buffer for indexing.
		;
		stz 	VARHash 					
		ldx 	#0
_VARCopyName:
		clc 								; update the sum hash.
		lda 	VARHash
		adc 	(codePtr),y
		sta 	VARHash

		lda 	(codePtr),y 				; get character and save it in buffer
		iny
		sta 	VARBuffer,x 			
		inx
		cmp 	#$7C 						; until copied the type byte
		bcc 	_VARCopyName
		sta 	VARType 					; save type byte
		;
		;		Calculate which hash table list to use.
		;
		and 	#3 							; type is 0-3
		.VAREntryShift 						; 3 x entries per type
		sta 	zTemp0 
		;
		lda 	VARHash 					; force into range of hash entries per type.		
		and		#(VARHashEntriesPerType-1)
		adc 	zTemp0 						; index of hash table
		asl 	a 							; offset as 2 bytes / word.
		;
		adc 	#VARHashTables & $FF 		; address of hash table start to zTemp0 & VARHashEntry
		sta 	zTemp0
		sta 	VARHashEntry
		lda 	#VARHashTables >> 8
		adc 	#0
		sta 	zTemp0+1
		sta 	VARHashEntry+1

		rts

; ************************************************************************************************
;
;										Clear Hash tables
;
; ************************************************************************************************

VARClearHashTables:
		ldx 	#0
_VCHRLoop:
		lda 	#0
		sta 	VARHashTables,x		
		inx
		cpx 	#VARHashEntriesPerType*4*2
		bne 	_VCHRLoop
		rts

		.send code
		
		.section storage

VARNameAddress:	 							; address of name in code
		.fill 	2		
VARHash:  									; hash total.
		.fill 	1		
VARType: 									; type byte ($7C..$7F)
		.fill 	1		
VARBuffer: 									; buffer of variable names, ends in $7C..$7F
		.fill 	32		
VARHashEntry:	 							; address of hash entry (e.g. start of the chain)
		.fill 	2

VARHashEntriesPerType = 4 					; hash entries for each of the 4 types.
											; *** MUST BE A POWER OF 2, 64 max ***

VARHashTables:								; the tables entriespertype x types x word size.
		.fill 	VARHashEntriesPerType*4*2

VAREntryShift .macro 						; multiply by entries per type.
		asl 	a
		asl 	a
		.endm

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

