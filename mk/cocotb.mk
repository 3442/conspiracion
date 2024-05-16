targets += test

target/test/prepare = $(prepare_verilator_target)

cocotb_modules = $(call per_target,cocotb_modules)

define target/test/setup
  $(setup_verilator_target)

  $$(call target_var,cocotb_modules) := $$(strip $$(core_info/$$(rule_top)/cocotb_modules))

  ifeq (,$$(cocotb_modules))
    $$(error core '$$(rule_top)' has no cocotb test modules)
  endif

  $$(call target_var,vl_main) = $$(cocotb_share)/lib/verilator/verilator.cpp
  $$(call target_var,vl_flags) += --vpi --public-flat-rw
  $$(call target_var,vl_ldflags) += \
    -Wl,-rpath,$$(cocotb_libdir),-rpath,$$(dir $$(cocotb_libpython)) -L$$(cocotb_libdir) \
    -lcocotbvpi_verilator -lgpi -lcocotb -lgpilog -lcocotbutils $$(cocotb_libpython)
endef

define target/test/rules
  $(verilator_target_rules)

  .PHONY: $$(rule_top_path)/test

  $$(rule_top_path)/test &: $$(vtop_exe) | $$(obj)
	$$(call run_no_err,COCOTB) cd $$(obj) && rm -f log.txt results.xml && \
		LIBPYTHON_LOC=$$(cocotb_libpython) COCOTB_RESULTS_FILE=results.xml \
		PYTHONPATH="$$(subst $$(space),:,$$(strip $$(cocotb_pythonpath) $$$$PYTHONPATH))" \
		MODULE=$$(subst $$(space),$$(comma),$$(cocotb_modules)) \
		$$(src)/$$< | tee log.txt

  $(call target_entrypoint,$$(rule_top_path)/test)
endef

cocotb_pythonpath = \
  $(addprefix $(src)/, \
    $(foreach dep,$(dep_tree/$(rule_top)), \
      $(call core_paths,$(dep),cocotb_paths)))
