DATA_DIR = data
CODE_DIR = code
HEADERS_DIR = headers
VPATH = ${DATA_DIR}:${CODE_DIR}:${HEADERS_DIR}
CXX = g++
CXXFLAGS = -std=c++17 -fopenmp
CPPFLAGS = -I ${HEADERS_DIR}

ED_data.csv: combine_data.py
	python $<

%.o: %.cpp %.h
	$(CXX) $(CXXFLAGS) $< -c

MCMC_SA: MCMC_SA.cpp Map.o statfuncs.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $^ -o $@ -lm

actual_H: actual_H.cpp Map.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $^ -o $@ -lm

.PHONY: clean
clean:
	rm -f MCMC_SA actual_H *.o
