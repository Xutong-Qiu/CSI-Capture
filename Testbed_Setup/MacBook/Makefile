# Compiler settings - Can be customized.
CXX = g++ 
CXXFLAGS = -std=c++11 -I/opt/homebrew/include
LDFLAGS = -L/opt/homebrew/lib
LDLIBS = -lssh

# Targets
all: read_output ssh_execute

read_output: read_output.cpp constants.h
	$(CXX) $(CXXFLAGS) -o read_output read_output.cpp $(LDFLAGS) $(LDLIBS)

a.out: ssh_execute.cpp constants.h
	$(CXX) $(CXXFLAGS) -o ssh_execute ssh_execute.cpp $(LDFLAGS) $(LDLIBS)

.PHONY: clean

clean:
	rm -f read_output ssh_execute
