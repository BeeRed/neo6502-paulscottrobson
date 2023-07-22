// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		modes.h
//		Purpose:	Modes header file
//		Created:	22nd July 2023
//		Author:		Paul Robson (paul@robsons->org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _MODES_H
#define _MODES_H

extern int (*display_handler)(int,int,int);

#define MODEHANDLER(c,a,d) (*display_handler)(c,a,d)

void mode0WriteChar(int x,int y,char c,int reverse);

int mode0Handler(int cmd,int address,int data);
int mode3Handler(int cmd,int address,int data);

#endif

