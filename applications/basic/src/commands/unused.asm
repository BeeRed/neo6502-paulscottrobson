; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		unused.asm
;		Purpose:	Non-executable tokens
;		Created:	26th May 2023
;		Reviewed: 	26th June 2023
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************

; ************************************************************************************************
;
;									Non-executable tokens
;
; ************************************************************************************************

		.section code

NoExec01: ;; [then]
NoExec02: ;; [to]
NoExec03: ;; [step]
NoExec04: ;; [,]
NoExec05: ;; [;]
NoExec06: ;; [:]
NoExec07: ;; [)]
NoExec08: ;; [proc]
		.error_syntax
				
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

