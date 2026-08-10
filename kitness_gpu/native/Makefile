BUILD_DIR := build
INCLUDE_DIR := include
SRC_DIR := src
SHADER_DIR := shaders
TEST_DIR := tests

CXX := xcrun --sdk macosx clang++
METAL := xcrun --sdk macosx metal
METALLIB := xcrun --sdk macosx metallib
CXXFLAGS := -std=c++17 -Wall -Wextra -Werror -fobjc-arc -I$(INCLUDE_DIR)
FRAMEWORKS := -framework Foundation -framework Metal

LIBRARY := $(BUILD_DIR)/libkitness_metal.dylib
METAL_LIBRARY := $(BUILD_DIR)/kitness.metallib
TEST_BINARY := $(BUILD_DIR)/test_metal_bridge

.PHONY: all clean test

all: $(LIBRARY) $(METAL_LIBRARY)

test: $(TEST_BINARY) $(METAL_LIBRARY)
	$(TEST_BINARY) $(abspath $(METAL_LIBRARY))

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/vector_add.air: $(SHADER_DIR)/vector_add.metal | $(BUILD_DIR)
	$(METAL) -c $< -o $@

$(METAL_LIBRARY): $(BUILD_DIR)/vector_add.air
	$(METALLIB) $< -o $@

$(LIBRARY): $(SRC_DIR)/kitness_metal.mm $(INCLUDE_DIR)/kitness_metal.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -dynamiclib $< -o $@ \
		-install_name @rpath/libkitness_metal.dylib $(FRAMEWORKS)

$(TEST_BINARY): $(TEST_DIR)/test_metal_bridge.cpp $(INCLUDE_DIR)/kitness_metal.h $(LIBRARY)
	$(CXX) $(CXXFLAGS) $< -L$(BUILD_DIR) -lkitness_metal \
		-Wl,-rpath,@loader_path -o $@

clean:
	rm -rf $(BUILD_DIR)