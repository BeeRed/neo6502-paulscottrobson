// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		hardware.h
//		Purpose:	Hardware Emulation Header
//		Created:	10th May 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _HARDWARE_H
#define _HARDWARE_H

void HWReset(void);
void HWSync(void);
void HWQueueKeyboardEvent(int scanCode);

int HWReadScancodeQueue(void);

void HWFlashInitialise(void);
int HWFlashCommand(int command,int data);

#define HWF_ERASE  			(0x00)		 			// Erase sector.
#define HWF_OPENREAD 		(0x01) 					// Open sector to read
#define HWF_OPENWRITE  		(0x02) 					// Open sector to write
#define HWF_READ  			(0x03)					// Read one byte
#define	HWF_WRITE  			(0x04) 					// Write one byte
#define HWF_ENDCOMMAND 		(0x05) 					// End current command.

#endif