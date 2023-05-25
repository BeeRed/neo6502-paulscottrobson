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

all: assemble

assemble:
	make -C scripts
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(PYTHON) scripts$(S)errors.py en
	$(CCOPY) $(BINDIR)ramdata.inc .
	$(CCOPY) $(BINDIR)osvectors.inc .
	$(PYTHON) scripts$(S)tokens.py
	$(PYTHON) $(SCRIPTDIR)makebuild.py >include.files
	$(ASM) basic.asm -o build$(S)basic.bin

run: emulator assemble
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000
	
emulator:
	make -C $(ROOTDIR)emulator	

enctest:
	make -C scripts
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(PYTHON) $(BINDIR)listpgm.zip build$(S)program.bin

parts:
	make -C ../mos
	make -C ../mathslib