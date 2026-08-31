# cothrom top-level orchestration.
#
#   make container   build the Singularity image (cothrom.sif) from cothrom.def
#   make ED_data     grab/build the public data set using the container
#                    (depends on the container being built first)
#   make cpp         configure + compile the C++ code with CMake into build/
#   make all         container + cpp
#   make clean       remove the build directory, the image, and generated data

# --- container -------------------------------------------------------------
SIF        = cothrom.sif
DEF        = cothrom.def
SINGULARITY = singularity
# bind the repo so scripts in the container can read/write ./data
RUN         = $(SINGULARITY) exec --bind $(CURDIR) $(SIF)

# --- C++ / CMake -----------------------------------------------------------
BUILD_DIR  = build
# override the compiler the standard CMake way, e.g.
#   make cpp CXX=CC          (LUMI Cray wrapper)
#   make cpp CXX=clang++
CMAKE_FLAGS =
ifdef CXX
CMAKE_FLAGS += -DCMAKE_CXX_COMPILER=$(CXX)
endif

.PHONY: all container ED_data cpp clean

all: container cpp

# --- a) build the container ------------------------------------------------
container: $(SIF)

$(SIF): $(DEF) requirements.txt
	# unprivileged proot build (no --fakeroot, no root)
	$(SINGULARITY) build $(SIF) $(DEF)

# --- b) python initialisation (needs the container) ------------------------
ED_data: data/ED_data.csv

data/ED_data.csv: $(SIF) code/combine_data.py
	$(RUN) python code/combine_data.py

# --- c) C++ build via CMake in build/ --------------------------------------
cpp:
	cmake -S . -B $(BUILD_DIR) $(CMAKE_FLAGS)
	cmake --build $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(SIF) data/ED_data.csv data/Constituency_data.csv
