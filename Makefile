TOP           := conspiracion
FST_DIR       := trace
OBJ_DIR       := obj
COV_DIR       := cov
RTL_DIR       := rtl
TB_DIR        := tb
SIM_DIR       := sim
DEMO_DIR      := demo
DIST_DIR      := dist
TB_SIM_DIR    := $(TB_DIR)/sim
SIM_OBJ_DIR   := $(OBJ_DIR)/$(TOP)/sim
DEMO_OBJ_DIR  := $(OBJ_DIR)/$(TOP)/demo
DIST_OBJ_DIR  := $(OBJ_DIR)/$(TOP)/dist
RBF_OUT_DIR   := output_files
VERILATOR     ?= verilator
COCOTB_CONFIG ?= cocotb-config
GENHTML       ?= genhtml
COCOTB_CONFIG ?= cocotb-config
CROSS_CC      := $(CROSS_COMPILE)gcc
CROSS_OBJCOPY := $(CROSS_COMPILE)objcopy
CROSS_CFLAGS  := -O3 -Wall -Wextra -Werror
CROSS_LDFLAGS :=

ifeq ($(shell which $(VERILATOR)),)
  $(error verilator not found)
endif

ifeq ($(shell which $(COCOTB_CONFIG)),)
  $(error cocotb not found)
endif

ifdef FASTER_IS_BETTER
	DISABLE_COV := 1
	DISABLE_RAND := 1
	DISABLE_TRACE := 1

	CXXFLAGS += -O3 -flto
	LDFLAGS += -O3 -flto
endif

CXXFLAGS += -iquote $(shell pwd)/$(TB_DIR)

export CXXFLAGS LDFLAGS

X_MODE := $(if $(DISABLE_RAND),fast,unique)

CC_CPU := -mcpu=arm810

VFLAGS ?= \
	--x-assign $(X_MODE) --x-initial $(X_MODE) \
	$(if $(ENABLE_THREADS),--threads $(shell nproc)) \
	$(if $(DISABLE_TRACE),,--trace --trace-fst --trace-structs) \
	$(if $(DISABLE_COV),,--coverage)

VFLAGS += -O3 --cc --exe -y $(RTL_DIR) --prefix Vtop

LIBPYTHON = $(shell $(COCOTB_CONFIG) --libpython)

COCOTB_LDFLAGS := $(LDFLAGS) \
  -Wl,-rpath,$(shell $(COCOTB_CONFIG) --lib-dir) \
  -L$(shell $(COCOTB_CONFIG) -config --lib-dir) \
  -Wl,-rpath,$(dir $(LIBPYTHON)) \
  -lcocotbvpi_verilator -lgpi -lcocotb -lgpilog -lcocotbutils

RTL_FILES := $(shell find $(RTL_DIR)/ ! -path '$(RTL_DIR)/top/*' -type f -name '*.sv')
RTL_FILES += $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.sv')
TB_FILES  := $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.cpp')

SIMS := \
	$(patsubst $(TB_SIM_DIR)/%.py,%,$(wildcard $(TB_SIM_DIR)/*.py)) \
	$(patsubst $(TB_DIR)/top/%.py,%,$(wildcard $(TB_DIR)/top/*.py))

GIT_REV := $(shell if [ -d .git ]; then echo -$$(git rev-parse --short HEAD); fi)

all: sim

clean:
	rm -rf $(DIST_DIR) $(OBJ_DIR) $(FST_DIR) $(COV_DIR)

dist: $(if $(DISABLE_COV),,cov)
	@mkdir -p $(DIST_DIR)
	@rm -rf $(DIST_OBJ_DIR) && mkdir -p $(DIST_OBJ_DIR)/{bin,bitstream,doc,results,src}
	@git ls-files | xargs cp --parents -rvt $(DIST_OBJ_DIR)/src
	@mv -vt $(DIST_OBJ_DIR) $(DIST_OBJ_DIR)/src/README.md
	@$(if $(DISABLE_COV),,cp -rvt $(DIST_OBJ_DIR)/results $(COV_DIR))
	@$(if $(DISABLE_TRACE),,cp -rvt $(DIST_OBJ_DIR)/results $(FST_DIR))
	@[ -f $(RBF_OUT_DIR)/$(TOP).rbf ] \
		&& cp -vt $(DIST_OBJ_DIR)/bitstream $(RBF_OUT_DIR)/$(TOP).rbf \
		|| echo "Warning: missing bitstream at $(RBF_OUT_DIR)/$(TOP).rbf" >&2
	cd $(DIST_OBJ_DIR) && zip -qr \
		$(shell pwd)/$(DIST_DIR)/$(TOP)$(GIT_REV)-$(shell date +'%Y%m%d-%H%M%S').zip *

sim: $(addprefix sim/,$(SIMS))

sim/%: $(SIM_DIR)/sim.py $(TB_SIM_DIR)/%.py exe/$(TOP) $(SIM_OBJ_DIR)/%.bin $(FST_DIR)/%
	@$< $(TB_SIM_DIR)/$*.py $(OBJ_DIR)/$(TOP)/Vtop \
		$(SIM_OBJ_DIR)/$*.bin \
		$(if $(DISABLE_COV),,--coverage $(SIM_OBJ_DIR)/$*.cov) \
		$(if $(DISABLE_TRACE),,--trace $(FST_DIR)/$*/trace$(GIT_REV).fst)

sim/%: $(TB_DIR)/top/%.py exe/% $(FST_DIR)/%
	@LIBPYTHON_LOC=$(LIBPYTHON) MODULE=tb.top.$* \
		$(if $(SIM_SEED),RANDOM_SEED=$(SIM_SEED)) \
		$(OBJ_DIR)/$*/Vtop

$(FST_DIR)/%:
	@mkdir -p $@

vmlaunch: $(SIM_DIR)/sim.py $(SIM_DIR)/gdbstub.py exe/$(TOP)
	@ENABLE_VIDEO=1 $< $(SIM_DIR)/gdbstub.py $(OBJ_DIR)/$(TOP)/Vtop build/u-boot.bin

demo: $(SIM_DIR)/sim.py $(SIM_DIR)/gdbstub.py exe/$(TOP) $(DEMO_OBJ_DIR)/demo.bin
	@START_HALTED=0 $< $(SIM_DIR)/gdbstub.py $(OBJ_DIR)/$(TOP)/Vtop $(DEMO_OBJ_DIR)/demo.bin

ifndef DISABLE_COV
$(COV_DIR): $(OBJ_DIR)/$(TOP)/cov.info
	@rm -rf $@
	$(GENHTML) $< --output-dir=$@

$(COV_DIR)/%: $(SIM_OBJ_DIR)/%.cov

$(SIM_OBJ_DIR)/%.cov: sim/%

$(OBJ_DIR)/$(TOP)/cov.info: $(patsubst %,sim/%,$(SIMS))
	$(VERILATOR)_coverage -write-info $@ $(SIM_OBJ_DIR)/*.cov
endif

%.bin: %
	$(CROSS_OBJCOPY) -O binary --only-section=._img $< $@

$(SIM_OBJ_DIR)/%: $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/start.o
	$(CROSS_CC) $(CROSS_LDFLAGS) -o $@ -g -T $(SIM_DIR)/link.ld -nostartfiles -nostdlib $^

$(OBJ_DIR)/%.bin: $(SIM_OBJ_DIR)/%
	$(CROSS_OBJCOPY) -O binary --only-section=._img $< $@

$(DEMO_OBJ_DIR)/demo: $(DEMO_DIR)/link.ld $(patsubst $(DEMO_DIR)/%,$(DEMO_OBJ_DIR)/%.o,\
                      $(basename $(wildcard $(DEMO_DIR)/*.c) $(wildcard $(DEMO_DIR)/*.S)))
	$(CROSS_CC) $(CROSS_LDFLAGS) -o $@ -g -nostartfiles -nostdlib -T $^

$(DEMO_OBJ_DIR)/%.o: $(DEMO_DIR)/%.c $(wildcard $(DEMO_DIR)/*.h)
	@mkdir -p $(DEMO_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $< $(CC_CPU)

$(DEMO_OBJ_DIR)/%.o: $(DEMO_DIR)/%.S
	@mkdir -p $(DEMO_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $<

$(SIM_OBJ_DIR)/%.o: $(TB_SIM_DIR)/%.c
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $< $(CC_CPU)

$(SIM_OBJ_DIR)/%.o: $(TB_SIM_DIR)/%.S
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $<

$(SIM_OBJ_DIR)/%.o: $(SIM_DIR)/%.S
	@mkdir -p $(SIM_OBJ_DIR)
	$(CROSS_CC) $(CROSS_CFLAGS) -o $@ -g -c $<

exe: exe/$(TOP)

exe/%: $(OBJ_DIR)/%/Vtop.mk
	@CXXFLAGS="$(CXXFLAGS) -iquote $(shell pwd)/$(TB_DIR)/top/$*" \
		$(MAKE) -C $(OBJ_DIR)/$* -f Vtop.mk

.PRECIOUS: $(OBJ_DIR)/%.mk $(SIM_OBJ_DIR)/% $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/%.cov %.bin
.PHONY: all clean dist demo sim

.SECONDEXPANSION:

$(OBJ_DIR)/%.mk: \
  $(RTL_DIR)/top/$$(word 1,$$(subst /, ,$$*)).sv \
  $$(shell find $(RTL_DIR)/top/$$(dir $$*) -type f 2>/dev/null) \
  $(RTL_FILES) $(TB_FILES) $(TB_DIR)/top/$$(word 1,$$(subst /, ,$$*)).cpp \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f 2>/dev/null)

	mkdir -p $(dir $@)
	$(VERILATOR) $(VFLAGS) \
		--Mdir $(dir $@) --top $(word 1,$(subst /, ,$*)) \
		$(filter %.sv %.cpp,$(patsubst tb/%,../tb/%,$^)) \
		$(if $(filter $(TOP),$(word 1,$(subst /, ,$*))),, \
			--vpi --public-flat-rw -LDFLAGS "$(COCOTB_LDFLAGS) $(LIBPYTHON)" \
			$(shell $(COCOTB_CONFIG) --share)/lib/verilator/verilator.cpp)
