TOP           := conspiracion
VCD_DIR       := vcd
OBJ_DIR       := obj
COV_DIR       := cov
RTL_DIR       := rtl
TB_DIR        := tb
SIM_DIR       := sim
TB_SIM_DIR    := $(TB_DIR)/sim
SIM_OBJ_DIR   := $(OBJ_DIR)/$(TOP)/sim
VERILATOR     ?= verilator
GENHTML       ?= genhtml
CROSS_CC      := $(CROSS_COMPILE)gcc
CROSS_OBJCOPY := $(CROSS_COMPILE)objcopy
CROSS_CFLAGS  := -O3 -Wall -Wextra -Werror
CROSS_LDFLAGS :=

ifdef FASTER_IS_BETTER
	DISABLE_COV := 1
	DISABLE_RAND := 1
	DISABLE_TRACE := 1
endif

X_MODE := $(if $(DISABLE_RAND),fast,unique)

VFLAGS ?= \
	--x-assign $(X_MODE) --x-initial $(X_MODE) \
	$(if $(DISABLE_THREADS),,--threads $(shell nproc)) \
	$(if $(DISABLE_TRACE),,--trace) \
	$(if $(DISABLE_COV),,--coverage)

RTL_FILES  = $(shell find $(RTL_DIR)/ ! -path '$(RTL_DIR)/top/*' -type f -name '*.sv')
RTL_FILES += $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.sv')
TB_FILES   = $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.cpp')

SIMS := $(patsubst $(TB_SIM_DIR)/%.py,%,$(wildcard $(TB_SIM_DIR)/*.py))

all: sim

clean:
	rm -rf $(OBJ_DIR) $(VCD_DIR) $(COV_DIR)

trace: trace/$(TOP)

trace/%: exe/% $(VCD_DIR)/%
	cd $(VCD_DIR)/$* && ../../$(OBJ_DIR)/$*/V$*

$(VCD_DIR)/%:
	mkdir -p $@

sim: $(addprefix sim/,$(SIMS))

sim/%: $(SIM_DIR)/sim.py $(TB_SIM_DIR)/%.py exe/$(TOP) $(SIM_OBJ_DIR)/%.bin
	@$< $(TB_SIM_DIR)/$*.py $(OBJ_DIR)/$(TOP)/V$(TOP) \
		$(SIM_OBJ_DIR)/$*.bin \
		$(if $(DISABLE_COV),,$(SIM_OBJ_DIR)/$*.cov)

vmlaunch: $(SIM_DIR)/sim.py $(SIM_DIR)/gdbstub.py exe/$(TOP)
	@$< $(SIM_DIR)/gdbstub.py $(OBJ_DIR)/$(TOP)/V$(TOP) build/u-boot.bin

ifndef DISABLE_COV
$(COV_DIR): $(OBJ_DIR)/$(TOP)/cov.info
	@rm -rf $@
	$(GENHTML) $< --output-dir=$@

$(COV_DIR)/%: $(SIM_OBJ_DIR)/%.cov

$(SIM_OBJ_DIR)/%.cov: sim/%

$(OBJ_DIR)/$(TOP)/cov.info: $(patsubst %,$(SIM_OBJ_DIR)/%.cov,$(SIMS))
	$(VERILATOR)_coverage -write-info $@ $(SIM_OBJ_DIR)/*.cov
endif

$(SIM_OBJ_DIR)/%.bin: $(SIM_OBJ_DIR)/%
	$(CROSS_OBJCOPY) -O binary --only-section=._img $< $@

$(SIM_OBJ_DIR)/%: $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/start.o
	$(CROSS_CC) $(CROSS_LDFLAGS) -o $@ -g -T $(SIM_DIR)/link.ld -nostartfiles -nostdlib $^

$(SIM_OBJ_DIR)/%.o: $(TB_SIM_DIR)/%.c
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $< -mcpu=arm810

$(SIM_OBJ_DIR)/%.o: $(TB_SIM_DIR)/%.S
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $<

$(SIM_OBJ_DIR)/%.o: $(SIM_DIR)/%.S
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $<

exe: exe/$(TOP)

exe/%: $(OBJ_DIR)/%/V%.mk
	$(MAKE) -C $(OBJ_DIR)/$* -f V$*.mk

.PRECIOUS: $(SIM_OBJ_DIR)/% $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/%.bin $(SIM_OBJ_DIR)/%.cov
.SECONDEXPANSION:

$(OBJ_DIR)/%.mk: \
  $(RTL_DIR)/top/$$(word 1,$$(subst /, ,$$*)).sv \
  $$(shell find $(RTL_DIR)/top/$$(dir $$*) -type f -name '*.sv' 2>/dev/null) \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f -name '*.sv' 2>/dev/null) \
  $(RTL_FILES) $(TB_FILES) $(TB_DIR)/top/$$(word 1,$$(subst /, ,$$*)).cpp \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f -name '*.cpp' 2>/dev/null)

	mkdir -p $(dir $@)
	$(VERILATOR) \
		-O3 --cc --exe -y $(RTL_DIR) --Mdir $(dir $@) \
		--top $(word 1,$(subst /, ,$*)) $(patsubst tb/%,../tb/%,$^) \
		$(VFLAGS)
