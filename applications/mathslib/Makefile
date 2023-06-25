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

all: assemble

assemble:
	$(CCOPY) $(BINDIR)ramdata.inc build
	$(PYTHON) scripts$(S)tenstable.py >src$(S)generated$(S)_tens.asm
	$(PYTHON) scripts$(S)tsc.py <test.tsc >build$(S)_test.asm
	$(PYTHON) scripts$(S)makelib.py >build$(S)libmathslib.asmlib
	$(CCOPY) build$(S)libmathslib.asmlib $(BINDIR)
	$(ASM) _main.asm -o build$(S)main.bin

run: emulator assemble
	$(EMULATOR) build$(S)main.bin@1000
	
emulator:
	make -C $(ROOTDIR)emulator	

reg:
	$(PYTHON) scripts$(S)maifloat.py

test: testscript run

testscript:
	python scripts$(S)testmake.py >test.tsc	