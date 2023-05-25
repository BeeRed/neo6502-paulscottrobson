# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Makefile
#		Purpose :	Build OS Rom
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\..\documents\common.make
else
include ../../documents/common.make
endif

all: assemble

assemble:
	make -C keyboard
	$(PYTHON) $(SCRIPTDIR)makebuild.py >include.files
	$(PYTHON) scripts$(S)vectors.py >$(BINDIR)osvectors.inc
	$(ASM) osrom.asm -o build$(S)osrom.bin
	$(CCOPY) build$(S)osrom.bin $(BINDIR)
	$(CCOPY) ramdata.inc $(BINDIR)

run: emulator assemble
	$(EMULATOR) build$(S)osrom.bin@f800
	
emulator:
	make -C $(ROOTDIR)emulator	

keyboard:
	make -C keyboard