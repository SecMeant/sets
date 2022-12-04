CXX ?= g++
CXXFLAGS ?= -O2 -fno-exceptions -std=c++20 -Wall -Wextra
CXXDEFINES := -DPCRE2_CODE_UNIT_WIDTH=8

all: discovervms

discovervms: discovervms.o Makefile
	$(CXX) $< -o $@ $(CXXFLAGS) -lpcre2-8

%.o: %.cc Makefile
	$(CXX) $< -c -o $@ $(CXXFLAGS) $(CXXDEFINES)

clean:
	rm -f discovervms.o discovervms

.PHONY: clean
