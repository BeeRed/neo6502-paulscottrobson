; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		instruction.asm
;		Purpose:	Handle a 65C02 instruction
;		Created:	5th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Handle 65C02 instruction
;
; ************************************************************************************************

		.section code

ASOpcode:
		.debug
		jsr 	ASCalculateOpcodeHash 		; calculate the opcode hash.
		sta 	ASCurrOpcode

		jsr 	ASIdentifyAddressMode 		; identify the address mode type.
		sta 	ASCurrMode

		jsr 	ASGenerateCode 				; search and generate appropriate code.
		rts
		
		.send code

		.section storage
ASCurrOpcode:
		.fill 	1
ASCurrMode:
		.fill 	1
		.send 	storage				
		
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

