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

static int sectorSize = 0;
static int sectorCount = 0;
static FILE *flashHandler = NULL;

// *******************************************************************************************************************************
//												Initialise Flash
// *******************************************************************************************************************************

void HWFlashInitialise(void) {
	HWFlashCommand(HWF_OPENREAD,0);
	HWFlashCommand(HWF_READ,0);
	HWFlashCommand(HWF_READ,0);
	sectorCount = HWFlashCommand(HWF_READ,0);
	sectorCount = (sectorCount << 8) | HWFlashCommand(HWF_READ,0);
	sectorSize = 1 << HWFlashCommand(HWF_READ,0);
	HWFlashCommand(HWF_ENDCOMMAND,0);
	printf("Flash:initialised sectors %d size %d\n",sectorCount,sectorSize);
}

// *******************************************************************************************************************************
//												Reset Hardware
// *******************************************************************************************************************************

int HWFlashCommand(int command,int data) {
	int retVal = 0;

	switch(command) {
		case HWF_ERASE:  					 			// Erase sector.
			HWFlashCommand(HWF_OPENWRITE,data);
			for (int i = 0;i < sectorSize;i++) 
						HWFlashCommand(HWF_WRITE,0xFF);
			HWFlashCommand(HWF_ENDCOMMAND,0);
			break;
		case HWF_OPENREAD: 		 						// Open sector to read
		case HWF_OPENWRITE:  		 					// Open sector to write
			printf("Flash cmd:%d data:%d $%x %c\n",command,data,data,data);
			flashHandler = fopen("storage/flash.image",(command == HWF_OPENREAD) ? "rb":"rb+");
			fseek(flashHandler,data * sectorSize,SEEK_SET);
			break;
		case HWF_READ: 				 					// Read one byte
			retVal = fgetc(flashHandler);
			break;
		case HWF_WRITE:  			 					// Write one byte
			if (data != 0xFF) printf("Flash cmd:%d data:%d $%x %c\n",command,data,data,data);
			fputc(data,flashHandler);
			break;
		case HWF_ENDCOMMAND:
			printf("Flash cmd:%d data:%d $%x %c\n",command,data,data,data);
			fclose(flashHandler);
			flashHandler = NULL;
			break;			
	}
	return retVal;
}

#endif