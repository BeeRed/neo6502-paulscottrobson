; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		opt.asm
;		Purpose:	Set assembler options
;		Created:	7th July 2023
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;										OPT <constant>
;
; ************************************************************************************************

		.section code

Command_OPT: 	;; [OPT]
		jsr 	EXPEvalInteger8
		sta 	ASMOption
		rts

		.send code

;:[OPT expr]\
; Sets assembly options. Bit 0 indicates whether the listing should be displayed or not.
; Bit 1 indicates the pass (0 or 1). When pass is set (e.g. OPT 2 or OPT 3) then errors
; on the "second pass" of assembler code are enabled - branch ranges, valid addresses
; labels defined and so on.

		.section storage
ASMOption:
		.fill 	1
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

