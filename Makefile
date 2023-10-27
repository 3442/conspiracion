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

ROOT := $(shell pwd)

CXXFLAGS += -iquote $(ROOT)/$(TB_DIR)

export CXXFLAGS LDFLAGS

X_MODE := $(if $(DISABLE_RAND),fast,unique)

CC_CPU := -mcpu=arm810

VFLAGS ?= \
	--x-assign $(X_MODE) --x-initial $(X_MODE) \
	$(if $(ENABLE_THREADS),--threads $(shell nproc)) \
	$(if $(DISABLE_TRACE),,--trace --trace-fst --trace-structs) \
	$(if $(DISABLE_COV),,--coverage)

VFLAGS += -O3 --cc --exe -y $(RTL_DIR) --prefix Vtop

LIBPYTHON := $(shell $(COCOTB_CONFIG) --libpython)

COCOTB_LDFLAGS := $(LDFLAGS) \
	-Wl,-rpath,$(shell $(COCOTB_CONFIG) --lib-dir) \
	-L$(shell $(COCOTB_CONFIG) -config --lib-dir) \
	-Wl,-rpath,$(dir $(LIBPYTHON)) \
	-lcocotbvpi_verilator -lgpi -lcocotb -lgpilog -lcocotbutils

RTL_FILES := $(shell find $(RTL_DIR)/ ! -path '$(RTL_DIR)/top/*' -type f -name '*.sv')
RTL_FILES += $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.sv')
TB_FILES  := $(shell find $(TB_DIR)/ ! -path '$(TB_DIR)/top/*' -type f -name '*.cpp')

SYS_SIMS  := $(patsubst $(TB_SIM_DIR)/%.py,%,$(wildcard $(TB_SIM_DIR)/*.py))
COCO_SIMS := $(filter-out __init__,$(patsubst $(TB_DIR)/top/%.py,%,$(wildcard $(TB_DIR)/top/*.py)))
SIMS      := $(SYS_SIMS) $(COCO_SIMS)

GIT_REV := $(shell if [ -d .git ]; then echo -$$(git rev-parse --short HEAD); fi)

all: sim

clean:
	rm -rf $(DIST_DIR) $(OBJ_DIR) $(FST_DIR) $(COV_DIR)

dist: $(DEMO_OBJ_DIR)/demo.bin $(if $(DISABLE_COV),sim,cov)
	@mkdir -p $(DIST_DIR)
	@rm -rf $(DIST_OBJ_DIR) && mkdir -pv $(DIST_OBJ_DIR)/{bin,bitstream,doc,results/flow,src}
	@git ls-files | xargs cp --parents -rvt $(DIST_OBJ_DIR)/src
	@mv -vt $(DIST_OBJ_DIR) $(DIST_OBJ_DIR)/src/README.md
	@cp -vt $(DIST_OBJ_DIR)/bin $(DEMO_OBJ_DIR)/demo
	@cp -v $(DEMO_OBJ_DIR)/demo.bin $(DIST_OBJ_DIR)/bin/boot.bin
	@if [ -d doc_out ]; then cp -vrt $(DIST_OBJ_DIR)/doc doc_out/*; fi
	@$(if $(DISABLE_COV),,cp -rv $(COV_DIR) $(DIST_OBJ_DIR)/results/coverage)
	@for SIM in $(SYS_SIMS); do \
		mkdir -pv $(DIST_OBJ_DIR)/results/system/$$SIM; \
		if [ -f $(SIM_OBJ_DIR)/$$SIM.fst ]; then \
			cp -v $(SIM_OBJ_DIR)/$$SIM.fst $(DIST_OBJ_DIR)/results/system/$$SIM/trace.fst; \
		fi; done
	@for SIM in $(COCO_SIMS); do \
		mkdir -pv $(DIST_OBJ_DIR)/results/block/$$SIM; \
		cp -vt $(DIST_OBJ_DIR)/results/block/$$SIM $(OBJ_DIR)/$$SIM/{results.xml,sim.log}; \
		$(if $(DISABLE_TRACE),, \
			cp -v $(OBJ_DIR)/$$SIM/dump.fst $(DIST_OBJ_DIR)/results/block/$$SIM/trace.fst); \
		done
	@cp -vt $(DIST_OBJ_DIR)/results/flow $(RBF_OUT_DIR)/*.rpt
	@[ -f $(RBF_OUT_DIR)/$(TOP).rbf ] \
		&& cp -vt $(DIST_OBJ_DIR)/bitstream $(RBF_OUT_DIR)/$(TOP).rbf \
		|| echo "Warning: missing bitstream at $(RBF_OUT_DIR)/$(TOP).rbf" >&2
	cd $(DIST_OBJ_DIR) && zip -qr \
		$(ROOT)/$(DIST_DIR)/$(TOP)$(GIT_REV)-$(shell date +'%Y%m%d-%H%M%S').zip *

sim: $(addprefix sim/,$(SIMS))

sim/%: $(SIM_DIR)/sim.py $(TB_SIM_DIR)/%.py exe/$(TOP) $(SIM_OBJ_DIR)/%.bin $(FST_DIR)/%
	@$< $(TB_SIM_DIR)/$*.py $(OBJ_DIR)/$(TOP)/Vtop \
		$(SIM_OBJ_DIR)/$*.bin \
		$(if $(DISABLE_COV),,--coverage $(SIM_OBJ_DIR)/$*.cov) \
		$(if $(DISABLE_TRACE),,--trace $(SIM_OBJ_DIR)/$*.fst)
	@$(if $(DISABLE_TRACE),,cp $(SIM_OBJ_DIR)/$*.fst $(FST_DIR)/$*/trace$(GIT_REV).fst)

sim/%: $(TB_DIR)/top/%.py exe/% $(FST_DIR)/%
	@cd $(OBJ_DIR)/$* && \
		LIBPYTHON_LOC=$(LIBPYTHON) PYTHONPATH="$$PYTHONPATH:$(ROOT)" MODULE=tb.top.$* \
		$(if $(SIM_SEED),RANDOM_SEED=$(SIM_SEED)) \
		./Vtop | tee sim.log
	@$(if $(DISABLE_TRACE),,cp $(OBJ_DIR)/$*/dump.fst $(FST_DIR)/$*/trace$(GIT_REV).fst)

$(FST_DIR)/%:
	@mkdir -p $@

vmlaunch: $(SIM_DIR)/sim.py $(SIM_DIR)/gdbstub.py exe/$(TOP)
	@ENABLE_VIDEO=1 $< $(SIM_DIR)/gdbstub.py $(OBJ_DIR)/$(TOP)/Vtop build/u-boot.bin

demo: $(SIM_DIR)/sim.py $(SIM_DIR)/gdbstub.py exe/$(TOP) $(DEMO_OBJ_DIR)/demo.bin
	@START_HALTED=0 $< $(SIM_DIR)/gdbstub.py $(OBJ_DIR)/$(TOP)/Vtop $(DEMO_OBJ_DIR)/demo.bin

demo.bin: $(DEMO_OBJ_DIR)/demo.bin
	@echo $<

ifndef DISABLE_COV
cov: $(OBJ_DIR)/$(TOP)/cov.info
	@rm -rf $(COV_DIR)
	$(GENHTML) $< --output-dir=$(COV_DIR)

cov/%: $(SIM_OBJ_DIR)/%.cov

$(SIM_OBJ_DIR)/%.cov: sim/%

$(OBJ_DIR)/$(TOP)/cov.info: $(patsubst %,sim/%,$(SIMS))
	$(VERILATOR)_coverage -write-info $@ \
		$(SIM_OBJ_DIR)/*.cov $(patsubst %,$(OBJ_DIR)/%/coverage.dat,$(COCO_SIMS))
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
	@CXXFLAGS="$(CXXFLAGS) -iquote $(ROOT)/$(TB_DIR)/top/$*" \
		$(MAKE) -C $(OBJ_DIR)/$* -f Vtop.mk

.PRECIOUS: $(OBJ_DIR)/%.mk $(SIM_OBJ_DIR)/% $(SIM_OBJ_DIR)/%.o $(SIM_OBJ_DIR)/%.cov %.bin $(FST_DIR)/%
.PHONY: all clean dist demo sim

.SECONDEXPANSION:

$(OBJ_DIR)/%.mk: \
  $(RTL_DIR)/top/$$(word 1,$$(subst /, ,$$*)).sv \
  $$(shell find $(RTL_DIR)/top/$$(dir $$*) -type f 2>/dev/null) \
  $(RTL_FILES) $(TB_FILES) \
  $$(shell find $(TB_DIR)/top/$$(word 1,$$(subst /, ,$$*)).cpp -type f 2>/dev/null) \
  $$(shell find $(TB_DIR)/top/$$(dir $$*) -type f 2>/dev/null)

	mkdir -p $(dir $@)
	$(VERILATOR) $(VFLAGS) \
		--Mdir $(dir $@) --top $(word 1,$(subst /, ,$*)) -FI $(ROOT)/$(TB_DIR)/verilator.hpp \
		$(filter %.sv %.cpp,$(patsubst tb/%,../tb/%,$^)) \
		$(if $(filter $(TOP),$(word 1,$(subst /, ,$*))),, \
			--vpi --public-flat-rw -LDFLAGS "$(COCOTB_LDFLAGS) $(LIBPYTHON)" \
			$(shell $(COCOTB_CONFIG) --share)/lib/verilator/verilator.cpp)
