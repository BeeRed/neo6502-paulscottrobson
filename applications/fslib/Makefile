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

all: assemble testfs

SOURCES = python$(S)files$(S)text1.bas python$(S)files$(S)text2.bas python$(S)files$(S)text3.bas python$(S)files$(S)text1.txt


assemble:
	$(PYTHON) $(SCRIPTDIR)makelib.py >build$(S)libwwfslib.asmlib
	$(CCOPY) build$(S)libwwfslib.asmlib $(BINDIR)
	$(CCOPY) python$(S)fsmanager.py $(BINDIR)

%.bas:%.txt
	$(PYTHON) $(BINDIR)makepgm.zip $<
	$(CCOPY) a.out $@
	$(CDEL) a.out

testfs: 
	$(PYTHON) $(BINDIR)fsmanager.py $(SOURCES) show
	$(CCOPY) flash.image ..$(S)basic$(S)storage