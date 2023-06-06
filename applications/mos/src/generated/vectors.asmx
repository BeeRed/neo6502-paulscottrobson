;
;	This file is automatically generated.
;
	* = $ffd6

	jmp		OSEditLine               ; Edit line, return completion in A, line in YX
	jmp		OSEditNewLine            ; Edit line, start clear.
	jmp		OSWriteString            ; Write length prefixed string YX to screen
	jmp		OSWriteStringZ           ; Write ASCIIZ string YX to screen
	jmp		OSGetScreenSize          ; Get size of screen to XY
	jmp		OSCheckBreak             ; NZ if ESC pressed.
	jmp		OSIsKeyAvailable         ; Check if key available (CS if so)
	jmp		OSReadKeystroke          ; Read A from keyboard, showing cursor while waiting.
	jmp		OSReadKeyboard           ; Read A from keyboard (device 1), CC = success
	jmp		OSWriteScreen            ; Write A to screen (device 0), CC = success
	jmp		OSReadDevice             ; Read device X to A, CC = success
	jmp		OSWriteDevice            ; Write A to device X, CC = success
