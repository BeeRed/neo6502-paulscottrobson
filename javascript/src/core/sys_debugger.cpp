// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_debugger.c
//		Purpose:	Debugger Code (System Dependent)
//		Created:	10th May 2023
//		Author:		Paul Robson (paul@robsons->org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gfx.h"
#include "sys_processor.h"
#include "debugger.h"
#include "hardware.h"

#include "6502/__6502mnemonics.h"

#include "font5x7.h"

#define DBGC_ADDRESS 	(0x0F0)														// Colour scheme.
#define DBGC_DATA 		(0x0FF)														// (Background is in main.c)
#define DBGC_HIGHLIGHT 	(0xFF0)

static int renderCount = 0;

// *******************************************************************************************************************************
//											This renders the debug screen
// *******************************************************************************************************************************

static const char *labels[] = { "A","X","Y","PC","SP","SR","CY","N","V","B","D","I","Z","C", NULL };

void DBGXRender(int *address,int showDisplay) {
	int n = 0;
	char buffer[32];
	CPUSTATUS *s = CPUGetStatus();

	#ifndef EMSCRIPTEN

	GFXSetCharacterSize(36,24);
	DBGVerticalLabel(21,0,labels,DBGC_ADDRESS,-1);									// Draw the labels for the register

	#define DN(v,w) GFXNumber(GRID(24,n++),v,16,w,GRIDSIZE,DBGC_DATA,-1)			// Helper macro

	DN(s->a,2);DN(s->x,2);DN(s->y,2);DN(s->pc,4);DN(s->sp+0x100,4);DN(s->status,2);DN(s->cycles,4);
	DN(s->sign,1);DN(s->overflow,1);DN(s->brk,1);DN(s->decimal,1);DN(s->interruptDisable,1);DN(s->zero,1);DN(s->carry,1);

	n = 0;
	int a = address[1];																// Dump Memory.
	for (int row = 15;row < 23;row++) {
		GFXNumber(GRID(0,row),a,16,4,GRIDSIZE,DBGC_ADDRESS,-1);
		for (int col = 0;col < 8;col++) {
			int c = CPUReadMemory(a);
			GFXNumber(GRID(5+col*3,row),c,16,2,GRIDSIZE,DBGC_DATA,-1);
			c = (c & 0x7F);if (c < ' ') c = '.';
			GFXCharacter(GRID(30+col,row),c,GRIDSIZE,DBGC_DATA,-1);
			a = (a + 1) & 0xFFFF;
		}		
	}

	int p = address[0];																// Dump program code. 
	int opc;

	for (int row = 0;row < 14;row++) {
		int isPC = (p == ((s->pc) & 0xFFFF));										// Tests.
		int isBrk = (p == address[3]);
		GFXNumber(GRID(0,row),p,16,4,GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_ADDRESS,	// Display address / highlight / breakpoint
																	isBrk ? 0xF00 : -1);
		opc = CPUReadMemory(p);p = (p + 1) & 0xFFFF;								// Read opcode.
		strcpy(buffer,_mnemonics[opc]);												// Work out the opcode.
		char *at = strchr(buffer,'@');												// Look for '@'
		if (at != NULL) {															// Operand ?
			char hex[6],temp[32];	
			if (at[1] == '1') {
				sprintf(hex,"%02x",CPUReadMemory(p));
				p = (p+1) & 0xFFFF;
			}
			if (at[1] == '2') {
				sprintf(hex,"%02x%02x",CPUReadMemory(p+1),CPUReadMemory(p));
				p = (p+2) & 0xFFFF;
			}
			if (at[1] == 'r') {
				int addr = CPUReadMemory(p);
				p = (p+1) & 0xFFFF;
				if ((addr & 0x80) != 0) addr = addr-256;
				sprintf(hex,"%04x",addr+p);
			}
			strcpy(temp,buffer);
			strcpy(temp+(at-buffer),hex);
			strcat(temp,at+2);
			strcpy(buffer,temp);
		}
		GFXString(GRID(5,row),buffer,GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_DATA,-1);	// Print the mnemonic
	}

	#endif 

	static int lineAddresses[24] = {
		0x400,0x480,0x500,0x580,0x600,0x680,0x700,0x780,
		0x428,0x4A8,0x528,0x5A8,0x628,0x6A8,0x728,0x7A8,
		0x450,0x4D0,0x550,0x5D0,0x650,0x6D0,0x750,0x7D0
	};

	renderCount++;
	if (showDisplay != 0) {
		int xc = 40;int yc = 24;
		int xs = 4;int ys = 4;
		SDL_Rect r;
		r.w = xs*xc*7;r.h = ys*yc*8;
		r.x = WIN_WIDTH/2-r.w/2;r.y = WIN_HEIGHT/2-r.h/2;
		SDL_Rect rc2;rc2 = r;
		rc2.w += 8;rc2.h += 8;rc2.x -=4;rc2.y -= 4;
		GFXRectangle(&rc2,0);
		GFXRectangle(&r,0);
		for (int y = 0;y < yc;y++) {
			for (int x = 0;x < xc;x++) {
				int ch = CPUReadMemory(x+lineAddresses[y]);
				//ch = x + y * 40;
				int flip = (ch & 0xC0) == 0;
				if ((ch & 0xC0) == 0x40 && (renderCount & 0x20) != 0) flip = -1;
				if (ch != 0xE0 && ch != 0xA0) {
					rc2.w = xs;rc2.h = ys;					
					for (int ypx = 0;ypx < 8;ypx++) {
						rc2.x = r.x + x * 7 * xs;
						rc2.y = r.y + (y*8+ypx) * ys;
						int b = 0;
						int c = (ch & 0x3F) ^ 0x20;
						b = font5x7[c*8+ypx] ^ (flip ? 0xFF:0x00);
						while (b != 0) {
							if (b & 0x80) GFXRectangle(&rc2,0xF80);
							b = (b << 1) & 0xFF;
							rc2.x += rc2.w;
						}
					}
				}			
			}			
			rc2.w = rc2.h = 8;
			rc2.y = r.y + y * 8 * ys + 4 * ys - rc2.h/2;
			rc2.x = r.x - rc2.w*2;
			GFXRectangle(&rc2,CPUReadMemory(0x200+y) ? 0x0FF : 0xF00);
		}
	}
}
