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
	$(CCOPY) $(BINDIR)ramdata.inc .

run: emulator assemble
	$(EMULATOR) build$(S)osrom.bin@f800
	
emulator:
	make -C $(ROOTDIR)emulator	

enctest:
	make -C scripts
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(PYTHON) $(BINDIR)listpgm.zip build$(S)program.bin
