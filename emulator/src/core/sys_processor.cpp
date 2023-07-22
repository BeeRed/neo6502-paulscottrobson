// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_processor.c
//		Purpose:	Processor Emulation.
//		Created:	10th May 2023
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "hardware.h"
#include "modes.h"

// *******************************************************************************************************************************
//														   Timing
// *******************************************************************************************************************************

#define CYCLE_RATE 		(16*1024*1024)												// Cycles per second (16Mhz)
#define FRAME_RATE		(60)														// Frames per second (60 arbitrary)
#define CYCLES_PER_FRAME (CYCLE_RATE / FRAME_RATE)									// Cycles per frame (20,000)

// *******************************************************************************************************************************
//														CPU / Memory
// *******************************************************************************************************************************

static BYTE8 a,x,y,s;																// 6502 A,X,Y and Stack registers
static BYTE8 carryFlag,interruptDisableFlag,breakFlag,								// Values representing status reg
			 decimalFlag,overflowFlag,sValue,zValue;
static WORD16 pc;																	// Program Counter.
static BYTE8 ramMemory[MEMSIZE];													// Memory at $0000 upwards
static int argumentCount;
static char **argumentList;
static LONG32 cycles;																// Cycle Count.
static BYTE8 inFastMode; 															// Fast mode
static WORD16 lowVideoAddress,highVideoAddress;  									// Write to video range.

// *******************************************************************************************************************************
//											 Memory and I/O read and write macros.
// *******************************************************************************************************************************

#define Read(a) 	_Read(a)														// Basic Read
#define Write(a,d)	_Write(a,d)														// Basic Write
#define ReadWord(a) (Read(a) | ((Read((a)+1) << 8)))								// Read 16 bit, Basic
#define Cycles(n) 	cycles += (n)													// Bump Cycles
#define Fetch() 	_Read(pc++)														// Fetch byte
#define FetchWord()	{ temp16 = Fetch();temp16 |= (Fetch() << 8); }					// Fetch word

static inline BYTE8 _Read(WORD16 address);											// Need to be forward defined as 
static inline void _Write(WORD16 address,BYTE8 data);								// used in support functions.

#include "6502/__6502support.h"

// *******************************************************************************************************************************
//											   Read and Write Inline Functions
// *******************************************************************************************************************************

BYTE8 *CPUAccessMemory(void) {
	return ramMemory;
}

static inline BYTE8 _Read(WORD16 address) {
	if (address == 0xC010) HWClearStrobe();
	return ramMemory[address];
}

static inline void _Write(WORD16 address,BYTE8 data) { 

	if (address == 0xC010) HWClearStrobe();

	if (address == 0xCF10) { 														// Write $CF10 : Command to flash subsystem.
		HWFlashCommand(data,														// Command in write
	 					ramMemory[0xCF11],											// Sector in $CF11
	 					ramMemory[0xCF12],											// SubPage in $CF12
	 					ramMemory[0xCF13]+ramMemory[0xCF14]*256, 					// Address in $CF13,4
	 					ramMemory[0xCF15]);											// Read count in $CF15
	}

	if (address == 0xCF18) { 														// Mode change
		HWSetMode(data);
		MODEHANDLER(1,0,0);															// Reset mode.
		lowVideoAddress = MODEHANDLER(2,0,0);										// get video memory range.	
		highVideoAddress = MODEHANDLER(3,0,0);
	}

	if (address < 0xC000 || address >= 0xCF10) ramMemory[address] = data;			// RAM write, I/O Write, ROM Write

	if (address >= lowVideoAddress && address <= highVideoAddress) { 				// VRAM Write.
		MODEHANDLER(0,address,data);
	}
	if (address == 0xFFFF) inFastMode = 1;
}

// *******************************************************************************************************************************
//													Remember Arguments
// *******************************************************************************************************************************

void CPUSaveArguments(int argc,char *argv[]) {
	argumentCount = argc;
	argumentList = argv;
}

// *******************************************************************************************************************************
//														Reset the CPU
// *******************************************************************************************************************************


void CPUReset(void) {
	HWReset();																		// Reset Hardware
	Write(0xFFFC,0);Write(0xFFFD,0x10);												// Boot to $1000 if no

	#ifdef EMSCRIPTEN
	#define OSROMSIZE (4096)
	FILE *f = fopen("storage/osrom.bin","rb");
	fread(ramMemory+0x10000-OSROMSIZE,1,OSROMSIZE,f);
	fclose(f);
	#define BASROMSIZE (12288)
	f = fopen("storage/basic.bin","rb");
	fread(ramMemory+0x1000,1,BASROMSIZE,f);
	fclose(f);
	#else
	for (int i = 1;i < argumentCount;i++) {
		char szBuffer[128];
		int loadAddress;
		strcpy(szBuffer,argumentList[i]);											// Get buffer
		
		char *p = strchr(szBuffer,'@');
		if (p == NULL) exit(fprintf(stderr,"Bad argument %s\n",argumentList[i]));
		*p++ = '\0';
		if (*p == '$') p++; 
		if (sscanf(p,"%x",&loadAddress) != 1) exit(fprintf(stderr,"Bad argument %s\n",argumentList[i]));
		printf("Loading '%s' to $%06x ..",szBuffer,loadAddress);
		FILE *f = fopen(szBuffer,"rb");
		if (f == NULL) exit(fprintf(stderr,"No file %s\n",argumentList[i]));
		while (!feof(f) && loadAddress < MEMSIZE) {
			ramMemory[loadAddress++] = fgetc(f);
		}
		fclose(f);
		printf("Okay\n");		
	}
	#endif
	inFastMode = 0;																	// Fast mode flag reset
	resetProcessor();																// Reset CPU

	HWSetMode(3);																	// Default mode.
	MODEHANDLER(1,0,0);																// Reset mode.
	lowVideoAddress = MODEHANDLER(2,0,0);											// get video memory range.	
	highVideoAddress = MODEHANDLER(3,0,0);
}

// *******************************************************************************************************************************
//													  Invoke IRQ
// *******************************************************************************************************************************

void CPUInterruptMaskable(void) {
	irqCode();
}

// *******************************************************************************************************************************
//												Execute a single instruction
// *******************************************************************************************************************************

BYTE8 CPUExecuteInstruction(void) {
	if (pc == 0xFFFF) {
		printf("Hit CPU $FFFF - exiting emulator\n");
		CPUExit();
		return FRAME_RATE;
	}
	BYTE8 opcode = Fetch();															// Fetch opcode.
	switch(opcode) {																// Execute it.
		#include "6502/__6502opcodes.h"
	}
	int cycleMax = inFastMode ? CYCLES_PER_FRAME*10:CYCLES_PER_FRAME; 		
	if (cycles < cycleMax) return 0;												// Not completed a frame.
	cycles = 0;																		// Reset cycle counter.
	HWSync();																		// Update any hardware
	return FRAME_RATE;																// Return frame rate.
}

// *******************************************************************************************************************************
//												Read/Write Memory
// *******************************************************************************************************************************

BYTE8 CPUReadMemory(WORD16 address) {
	return Read(address);
}

void CPUWriteMemory(WORD16 address,BYTE8 data) {
	Write(address,data);
}


#include "gfx.h"

// *******************************************************************************************************************************
//		Execute chunk of code, to either of two break points or frame-out, return non-zero frame rate on frame, breakpoint 0
// *******************************************************************************************************************************

BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2) { 
	BYTE8 next;
	do {
		BYTE8 r = CPUExecuteInstruction();											// Execute an instruction
		if (r != 0) return r; 														// Frame out.
		next = CPUReadMemory(pc);
	} while (pc != breakPoint1 && pc != breakPoint2 && next != 0xDB);				// Stop on breakpoint or $03 break
	return 0; 
}

// *******************************************************************************************************************************
//									Return address of breakpoint for step-over, or 0 if N/A
// *******************************************************************************************************************************

WORD16 CPUGetStepOverBreakpoint(void) {
	BYTE8 opcode = CPUReadMemory(pc);												// Current opcode.
	if (opcode == 0x20) return (pc+3) & 0xFFFF;										// Step over JSR.
	return 0;																		// Do a normal single step
}

void CPUEndRun(void) {
	FILE *f = fopen("memory.dump","wb");
	fwrite(ramMemory,1,MEMSIZE,f);
	fclose(f);	
}

void CPUExit(void) {	
	printf("Exiting.\n");
	GFXExit();
}


// *******************************************************************************************************************************
//											Retrieve a snapshot of the processor
// *******************************************************************************************************************************

static CPUSTATUS st;																	// Status area

CPUSTATUS *CPUGetStatus(void) {
	st.a = a;st.x = x;st.y = y;st.sp = s;st.pc = pc;
	st.carry = carryFlag;st.interruptDisable = interruptDisableFlag;st.zero = (zValue == 0);
	st.decimal = decimalFlag;st.brk = breakFlag;st.overflow = overflowFlag;
	st.sign = (sValue & 0x80) != 0;st.status = constructFlagRegister();
	st.cycles = cycles;
	return &st;
}

