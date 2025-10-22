BSC_INSTALL_DIR = /home/prawns/bsc/inst
BSC = $(BSC_INSTALL_DIR)/bin/bsc
BUILD_DIR = build
SYNTH_DIR = synth
BSC_FLAGS = -keep-fires
BSC_PATH = -p fpga:+

# Environment setup
export BLUESPECDIR=$(BSC_INSTALL_DIR)/lib
export PATH:=$(BSC_INSTALL_DIR)/bin:$(PATH)

.PHONY: all sim clean synth test

all: sim

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(SYNTH_DIR):
	mkdir -p $(SYNTH_DIR)

# Simulation targets
sim: $(BUILD_DIR)
	# Compile everything recursively with -u
	$(BSC) -sim $(BSC_FLAGS) -cpp -bdir $(BUILD_DIR) $(BSC_PATH) -g mkTest -u fpga/fir_tb.bsv
	# Link into executable
	$(BSC) -sim $(BSC_FLAGS) -cpp -bdir $(BUILD_DIR) -o $(BUILD_DIR)/fir_sim -e mkTest
	@echo "Run simulation with: $(BUILD_DIR)/fir_sim"

# Synthesis targets (Verilog generation)
synth: $(SYNTH_DIR)
	$(BSC) -verilog $(BSC_FLAGS) -g mkFIR -u $(BSC_PATH) fpga/FIR.bsv
	@mv mkFIR.v $(SYNTH_DIR)/ # Move generated Verilog to synth directory
	@echo "Verilog generated in $(SYNTH_DIR)/"

# Run simulation and save output
test: sim
	cd $(BUILD_DIR) && LD_LIBRARY_PATH=$(BUILD_DIR) ./fir_sim.so > sim_output.txt
	@echo "Simulation output saved to build/sim_output.txt"

clean:
	rm -rf $(BUILD_DIR) $(SYNTH_DIR)
	rm -f *.bo *.ba
	rm -f fpga/*.{bo,ba,cxx,h,o}
	rm -rf fpga/build
	rm -f fpga/mk*.{ba,bo,cxx,h,o}
	rm -f fpga/model_*.{cxx,h,o}
	# remove generated root-level artifacts
	rm -f a.out a.out.so
	rm -f mk*.{cxx,o,h}
	rm -f model_*.{cxx,h,o}