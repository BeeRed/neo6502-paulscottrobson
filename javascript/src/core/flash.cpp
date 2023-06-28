// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		flash.cpp
//		Purpose:	Flash Interface
//		Created:	27th June 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _HARDWAREFLASH_H
#define _HARDWAREFLASH_H

#include "sys_processor.h"
#include "hardware.h"
#include <stdio.h>

static FILE *fFlashImage = NULL;

// *******************************************************************************************************************************
//												Reset Hardware
// *******************************************************************************************************************************

int HWFlashCommand(int command,int data) {
	int retVal = 0;
	printf("Flash cmd:%d data:%d $%x\n",command,data,data);

	switch(command) {
		case HWF_ERASE:  					 			// Erase sector.
			break;
		case HWF_OPENREAD: 		 						// Open sector to read
			break;
		case HWF_OPENWRITE:  		 					// Open sector to write
			break;
		case HWF_READ: 				 					// Read one byte
			break;
		case HWF_WRITE:  			 					// Write one byte
			break;
		case HWF_ENDCOMMAND:
			break;
	}
	return 0;
}

#endif