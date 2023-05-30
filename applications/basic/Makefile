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

assemble: prelim
	$(ASM) basic.asm -o build$(S)basic.bin

prelim:
	make -C scripts
	$(PYTHON) scripts$(S)errors.py en
	$(CCOPY) $(BINDIR)ramdata.inc build
	$(CCOPY) $(BINDIR)osvectors.inc build
	$(CCOPY) $(BINDIR)libmathslib.asmlib build
	$(PYTHON) scripts$(S)tokens.py
	$(PYTHON) $(SCRIPTDIR)makebuild.py >include.files

run: emulator assemble test
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000
	
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

test1: assemble
	$(PYTHON) tests$(S)testbinary.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000

test2: assemble
	$(PYTHON) tests$(S)testunary.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000

test3: assemble
	$(PYTHON) tests$(S)testbrackets.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000

test4: assemble
	$(PYTHON) tests$(S)teststring.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000

test5: assemble
	$(PYTHON) tests$(S)testassign.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 build$(S)program.bin@6000

edtest: prelim
	$(PYTHON) scripts$(S)maketest.py 
	$(ASM) basic.asm -D runEdit=1 -o build$(S)basic.bin
	$(EMULATOR) $(BINDIR)osrom.bin@f800 build$(S)basic.bin@1000 
	$(PYTHON) scripts$(S)checktest.py 
