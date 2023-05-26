# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Makefile
#		Purpose :	Build Basic
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

all: assemble test

assemble:
	make -C scripts
	$(PYTHON) scripts$(S)errors.py en
	$(CCOPY) $(BINDIR)ramdata.inc build
	$(CCOPY) $(BINDIR)osvectors.inc build
	$(CCOPY) $(BINDIR)libmathslib.asmlib build
	$(PYTHON) scripts$(S)tokens.py
	$(PYTHON) $(SCRIPTDIR)makebuild.py >include.files
	$(ASM) basic.asm -o build$(S)basic.bin

run: emulator assemble test
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@4000
	
emulator:
	make -C $(ROOTDIR)emulator	

test:
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin

enctest: test
	make -C scripts
	$(PYTHON) $(BINDIR)listpgm.zip build$(S)program.bin

parts:
	make -C ../mos
	make -C ../mathslib

reg:
	$(PYTHON) scripts$(S)showreg.py	