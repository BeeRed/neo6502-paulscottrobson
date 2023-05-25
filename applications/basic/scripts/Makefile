# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Makefile
#		Purpose :	Build Python stand alone applications
#		Date :		25th May 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\..\..\documents\common.make
else
include ../../../documents/common.make
endif

all: makepgm listpgm
	$(CCOPY) *.zip $(BINDIR)

makepgm:
	$(CCOPY) makepgm.py __main__.py
	zip -q makepgm.zip __main__.py tokeniser.py tokens.py
	$(CDEL) __main__.py

listpgm:
	$(CCOPY) listpgm.py __main__.py
	zip -q listpgm.zip __main__.py tokens.py
	$(CDEL) __main__.py	