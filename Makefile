TOP       := conspiracion
VCD_DIR   := vcd
OBJ_DIR   := obj
RTL_DIR   := rtl
TB_DIR    := tb
VERILATOR := verilator

all: trace

clean:
	rm -rf $(OBJ_DIR) $(VCD_DIR)

trace: exe vcd
	cd $(VCD_DIR) && ../$(OBJ_DIR)/V$(TOP)

$(VCD_DIR):
	@mkdir $(VCD_DIR)

exe: $(OBJ_DIR)/V$(TOP)

$(OBJ_DIR)/V$(TOP): $(OBJ_DIR)/V$(TOP).mk
	$(MAKE) -C $(OBJ_DIR) -f V$(TOP).mk $(MAKEFLAGS)

$(OBJ_DIR)/V$(TOP).mk: $(wildcard $(RTL_DIR)/*.sv) $(wildcard $(TB_DIR)/*.cpp)
	$(VERILATOR) \
		--cc --exe --trace \
		-y $(RTL_DIR) --Mdir $(OBJ_DIR) \
		rtl/$(TOP).sv $(wildcard $(TB_DIR)/*.cpp)
