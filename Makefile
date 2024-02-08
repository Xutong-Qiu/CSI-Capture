# Compiler settings - Can be customized.
CXX = g++ 
CXXFLAGS = -std=c++11 -I/opt/homebrew/include
LDFLAGS = -L/opt/homebrew/lib
LDLIBS = -lssh

# Targets
all: read_output a.out

read_output: read_output.cpp
	$(CXX) $(CXXFLAGS) -o read_output read_output.cpp $(LDFLAGS) $(LDLIBS)

a.out: ssh_test.cpp
	$(CXX) $(CXXFLAGS) -o a.out ssh_test.cpp $(LDFLAGS) $(LDLIBS)

.PHONY: clean

clean:
	rm -f read_output a.out
