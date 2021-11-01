
LLVM_BIN = /usr/local/opt/llvm/bin
LLVM_CONFIG = $(LLVM_BIN)/llvm-config

CC = gcc
CXX = g++

CFLAGS = -Wall -I.
CXXFLAGS = $(CCFLAGS)

CFLAGS += $(shell $(LLVM_CONFIG) --cflags)
CXXFLAGS += $(shell $(LLVM_CONFIG) --cxxflags)

LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags --libs --system-libs --link-shared)

LLVM_INCLUDE_DIR = $(shell $(LLVM_CONFIG) --includedir)

OBJS = llvm-cxxapi.o CxxApiWriterPass.o

all: llvm-cxxapi

%.o: %.cpp
	$(CXX) -g -c $(CXXFLAGS) -o $@ $<

clean:
	rm -rf test llvm-cxxapi *.o *.d

llvm-cxxapi: $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

test: llvm-cxxapi
	@echo "int test(int a) { return (((a ^ 4) * 3) ^ 2) + 1;}" > test.c
	$(LLVM_BIN)/clang -emit-llvm -S -O3 test.c
	./llvm-cxxapi test.ll -o test.ll.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o test test.ll.cpp
