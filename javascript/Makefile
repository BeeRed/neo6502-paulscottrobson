# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		Makefile
#		Purpose :	Build Emulator
#		Date :		4th June 2023
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

ifeq ($(OS),Windows_NT)
include ..\documents\common.make
else
include ../documents/common.make
endif

SOURCES = 	framework/main.cpp framework/gfx.cpp framework/debugger.cpp src/core/sys_processor.cpp src/core/sys_debugger.cpp src/core/hardware.cpp
FLAGS = -DINCLUDE_OS_SUPPORT -I. -I framework -I./cpu -I./bin -I include -O2 -s USE_SDL=2 -s WASM=1 -s USE_SDL_IMAGE=2 -s SDL2_IMAGE_FORMATS='["png"]' --preload-file storage


.PHONY: all clean emulator prebuild release run

all: app

app:
	cp -R ../emulator/src ../emulator/include ../emulator/framework ../emulator/6502 ../emulator/storage . -R
	cp ../bin/osrom.bin storage
	cp ../applications/basic/build/basic.bin storage
	cp ../bin/basic.html .
	emcc $(SOURCES) -D EMSCRIPTEN -D LINUX -D NO_DEBUGGER $(FLAGS)  -o neo.html

server: app
	python -m http.server