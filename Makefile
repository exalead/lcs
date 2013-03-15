# File: LCS Makefile
# Version: January 2013
# Maintainer: Xavier Roche <roche@exalead.com>

# Usage:
#	gmake
# or
#	gmake test

# OS
UNAME := $(shell uname)
RM = rm -f

# Compiler definitions
CC = gcc
CXX = g++
FLAGS = -fPIC -g -O3
ifeq ($(UNAME), Linux)
FLAGS := $(FLAGS) -fstack-protector
endif
CFLAGS = -c \
	$(FLAGS) \
	-W -Wall \
	-Wimplicit \
	-Wwrite-strings \
	-Wparentheses \
	-Wformat -Wformat-security \
	-Wsign-compare \
	-Wreturn-type \
	-Wno-unused-parameter -Wno-unused-function \
	-Werror \
	-D_REENTRANT -D_FORTIFY_SOURCE=2 \
	-D_ISOC99_SOURCE -D_POSIX_C_SOURCE=199506L -D_XOPEN_SOURCE=500 \
	-D__EXTENSIONS__ -D_BSD_SOURCE
CCFLAGS = $(CFLAGS) \
	-Wdeclaration-after-statement \
	-Wsequence-point
CXXFLAGS = $(CFLAGS)
SHCFLAGS = -shared $(FLAGS) -lpthread -lm
EXECFLAGS = $(FLAGS) -lpthread -lm
ifeq ($(UNAME), Linux)
SHCFLAGS := $(SHCFLAGS) -Wl,-z,relro -Wl,-z,now -Wl,-O1
EXECFLAGS := $(EXECFLAGS) -Wl,-z,relro -Wl,-z,now -Wl,-O1
endif

all: lib main

rebuild: clean all

lcs.o: lcs.c
	$(CC) $(CCFLAGS) lcs.c

nglib-compat.o: nglib-compat.c
	$(CC) $(CCFLAGS) nglib-compat.c

main.o: main.c
	$(CC) $(CCFLAGS) main.c

lib: liblcscompressor.so

liblcscompressor.so: lcs.o nglib-compat.o
	$(CC) $(SHCFLAGS) \
		-DLCS_DLL \
		lcs.o nglib-compat.o \
		-o liblcscompressor.so \
		-Wl,-soname=liblcscompressor.so

main:
#lcsmain

lcsmain: lib main.o
	$(CC) $(EXECFLAGS) \
		main.o \
		-o lcsmain \
		-llcscompressor \
		-L.

clean:
	$(RM) *.o *.so lcsmain

.PHONY : all rebuild lib main clean

