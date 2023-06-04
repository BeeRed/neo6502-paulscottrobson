// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		hardware.c
//		Purpose:	Hardware Emulation
//		Created:	10th May 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include "sys_processor.h"
#include "hardware.h"
#include <stdio.h>

static int scanKeyQueue[16];														// Simple queue of scan keys.
static int scanKeyQueueSize;

// *******************************************************************************************************************************
//												Reset Hardware
// *******************************************************************************************************************************

void HWReset(void) {
	scanKeyQueueSize = 0;
}

// *******************************************************************************************************************************
//												  Reset CPU
// *******************************************************************************************************************************

void HWSync(void) {
}

// *******************************************************************************************************************************
//										     Receive PS/2 events
// *******************************************************************************************************************************

void HWQueueKeyboardEvent(int scanCode) {
	//printf("Scancode %x\n",scanCode);
	if (scanKeyQueueSize < 16) {													// Push keycode on scanqueue if not empty.
		scanKeyQueue[scanKeyQueueSize++] = scanCode;
	}
}

// *******************************************************************************************************************************
//											Access scancode queue
// *******************************************************************************************************************************

int HWReadScancodeQueue(void) {
	if (scanKeyQueueSize == 0) return 0;											// empty queue returns zero
	int sc = scanKeyQueue[0];														// remember it
	for (int i = 0;i < scanKeyQueueSize;i++) { 										// shift them all up
		scanKeyQueue[i] = scanKeyQueue[i+1];
	}
	scanKeyQueueSize--; 															// decrement number available.
	return sc;

}