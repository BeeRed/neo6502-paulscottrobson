# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Makefile
#		Purpose :	Build Emulator
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

all: testfs

#assemble:
#	$(CCOPY) $(BINDIR)ramdata.inc build
#	$(PYTHON) scripts$(S)tenstable.py >src$(S)generated$(S)_tens.asm
#	$(PYTHON) scripts$(S)tsc.py <test.tsc >build$(S)_test.asm
#	$(PYTHON) scripts$(S)makelib.py >build$(S)libmathslib.asmlib
#	$(CCOPY) build$(S)libmathslib.asmlib $(BINDIR)
#	$(ASM) _main.asm -o build$(S)main.bin

testfs:
	cd python ; $(PYTHON) makedemo.py			
	$(CCOPY) python$(S)flash.image ..$(S)basic