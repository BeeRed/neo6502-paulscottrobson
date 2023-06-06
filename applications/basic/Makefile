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

BASICLOAD = 	\$$1000
BASICCODE = 	\$$6000
ENDMEMORY = 	\$$B000
MOSLOAD =   	\$$F800
STACKPAGES =	2

CONFIG =  -D BASICLOAD=$(BASICLOAD) -D BASICCODE=$(BASICCODE) -D ENDMEMORY=$(ENDMEMORY) -D STACKPAGES=$(STACKPAGES) 

all: assemble test

assemble: prelim
	$(ASM) $(CONFIG) basic.asm -o build$(S)basic.bin

autoasm:prelim
	$(ASM) $(CONFIG) basic.asm -D autoRun=1 -o build$(S)basic.bin

prelim:
	make -C scripts
	$(PYTHON) scripts$(S)errors.py en
	$(CCOPY) $(BINDIR)ramdata.inc build
	$(CCOPY) $(BINDIR)osvectors.inc build
	$(CCOPY) $(BINDIR)libmathslib.asmlib build
	$(PYTHON) scripts$(S)tokens.py
	$(PYTHON) $(SCRIPTDIR)makebuild.py >include.files

doc:
	python scripts$(S)makedoc.py > $(BINDIR)..$(S)documents$(S)basic.html

run: emulator assemble test
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)
	
autorun:emulator autoasm test
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)
	
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

var:
	$(PYTHON) scripts$(S)showvar.py	

test1: autoasm
	$(PYTHON) tests$(S)testbinary.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

test2: autoasm
	$(PYTHON) tests$(S)testunary.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

test3: autoasm
	$(PYTHON) tests$(S)testbrackets.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

test4: autoasm
	$(PYTHON) tests$(S)teststring.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

test5: autoasm
	$(PYTHON) tests$(S)testassign.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

test6: autoasm
	$(PYTHON) tests$(S)testarray.py >build$(S)test.bas
	$(PYTHON) $(BINDIR)makepgm.zip build$(S)test.bas -obuild$(S)program.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) build$(S)program.bin@$(BASICCODE)

edtest: prelim
	$(PYTHON) scripts$(S)maketest.py 
	$(ASM) basic.asm $(CONFIG) -D runEdit=1 -o build$(S)basic.bin
	$(EMULATOR) $(BINDIR)osrom.bin@$(MOSLOAD) build$(S)basic.bin@$(BASICLOAD) 
	$(PYTHON) scripts$(S)checktest.py 
