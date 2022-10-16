TOP           := conspiracion
VCD_DIR       := vcd
OBJ_DIR       := obj
RTL_DIR       := rtl
TB_DIR        := tb
SIM_DIR       := $(TB_DIR)/sim
SIM_OBJ_DIR   := $(OBJ_DIR)/$(TOP)/sim
VERILATOR     := verilator
CROSS_CC      := arm-none-eabi-gcc
CROSS_OBJCOPY := arm-none-eabi-objcopy
CROSS_CFLAGS  := -O3 -Wall -Wextra -Werror
CROSS_LDFLAGS :=

RTL_FILES  = $(shell find $(RTL_DIR)/ ! -path '$(RTL_DIR)/top/*' -type f -name '*.sv')
RTL_FILES += $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.sv')
TB_FILES   = $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.cpp')

all: sim

clean:
	rm -rf $(OBJ_DIR) $(VCD_DIR)

trace: trace/$(TOP)

trace/%: exe/% $(VCD_DIR)/%
	cd $(VCD_DIR)/$* && ../../$(OBJ_DIR)/$*/V$*

$(VCD_DIR)/%:
	mkdir -p $@

sim: $(patsubst $(SIM_DIR)/%.py,sim/%,$(filter-out $(SIM_DIR)/sim.py,$(wildcard $(SIM_DIR)/*.py)))

sim/%: $(SIM_DIR)/sim.py $(SIM_DIR)/%.py exe/$(TOP) $(SIM_OBJ_DIR)/%.bin
	$< $(SIM_DIR)/$*.py $(OBJ_DIR)/$(TOP)/V$(TOP) $(SIM_OBJ_DIR)/$*.bin

$(SIM_OBJ_DIR)/%.bin: $(SIM_OBJ_DIR)/%
	$(CROSS_OBJCOPY) -O binary --only-section=._img $< $@

$(SIM_OBJ_DIR)/%: $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/start.o
	$(CROSS_CC) $(CROSS_LDFLAGS) -o $@ -T $(SIM_DIR)/link.ld -nostartfiles -nostdlib $^

$(SIM_OBJ_DIR)/%.o: $(SIM_DIR)/%.c
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -c $< -mcpu=arm810

$(SIM_OBJ_DIR)/%.o: $(SIM_DIR)/%.S
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -c $<

exe: exe/$(TOP)

exe/%: $(OBJ_DIR)/%/V%.mk
	$(MAKE) -C $(OBJ_DIR)/$* -f V$*.mk

.PRECIOUS: $(SIM_OBJ_DIR)/% $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/%.bin
.SECONDEXPANSION:

$(OBJ_DIR)/%.mk: \
  $(RTL_DIR)/top/$$(word 1,$$(subst /, ,$$*)).sv \
  $$(shell find $(RTL_DIR)/top/$$(dir $$*) -type f -name '*.sv' 2>/dev/null) \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f -name '*.sv' 2>/dev/null) \
  $(RTL_FILES) $(TB_FILES) $(TB_DIR)/top/$$(word 1,$$(subst /, ,$$*)).cpp \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f -name '*.cpp' 2>/dev/null)

	mkdir -p $(dir $@)
	$(VERILATOR) --cc --exe --trace -y $(RTL_DIR) --Mdir $(dir $@) --top $(word 1,$(subst /, ,$*)) $(patsubst tb/%,../tb/%,$^)
