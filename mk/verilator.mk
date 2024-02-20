targets += sim

vtop_dir = $(call per_target,vtop_dir)
vtop_exe = $(call per_target,vtop_exe)

vl_main = $(call per_target,vl_main)
vl_flags = $(call per_target,vl_flags)
vl_cflags = $(call per_target,vl_cflags)
vl_ldflags = $(call per_target,vl_ldflags)

define target/sim/prepare
  enable_opt := 1

  $(prepare_verilator_target)
endef

define target/sim/setup
  $(setup_verilator_target)

  $$(call target_var,vl_main) := $$(strip $$(call require_core_paths,$$(rule_top),vl_main))
endef

define target/sim/rules
  $(verilator_target_rules)

  .PHONY: $$(rule_top_path)/sim

  $$(rule_top_path)/sim: $$(vtop_exe)
	$$<
endef

define prepare_verilator_target
  flow/type := sim
endef

define setup_verilator_target
  $(call build_vars,$(addprefix enable_,rand threads trace cov opt lto prof))

  $(call target_var,vl_flags) = $(common_vl_flags)
  $(call target_var,vl_cflags) = $(common_vl_cflags)
  $(call target_var,vl_ldflags) = $(common_vl_ldflags)
endef

$(eval $(call defer,common_vl_flags,$$(set_verilator_common)))
$(eval $(call defer,common_vl_cflags,$$(set_verilator_common)))
$(eval $(call defer,common_vl_ldflags,$$(set_verilator_common)))

define set_verilator_common
  ifneq (,$$(enable_lto))
    enable_opt := 1
  endif

  x_mode := $$(if $$(enable_rand),unique,fast)

  static_flags := \
    --x-assign $$(x_mode) --x-initial $$(x_mode) \
    $$(if $$(enable_threads),--threads $$(call shell_checked,nproc)) \
    $$(if $$(enable_trace),--trace --trace-fst --trace-structs) \
    $$(if $$(enable_cov),--coverage) \
    $$(if $$(enable_opt),-O3) \
    $$(if $$(enable_prof),--prof-cfuncs) \
    --cc --exe --prefix Vtop --MMD --MP

  common_vl_flags := $$(static_flags) $$(core_info/$$(rule_top)/vl_flags)

  common_vl_cflags := \
    $$(if $$(enable_opt),-O3) \
    $$(if $$(enable_lto),-flto)

  common_vl_ldflags := \
    $$(if $$(enable_lto),-flto)
endef

define verilator_target_rules
  $(call target_var,vtop_dir) := $$(obj)/vl
  $(call target_var,vtop_exe) := $$(vtop_dir)/Vtop

  vtop_mk_file := $$(vtop_dir)/Vtop.mk
  vtop_mk_stamp := $$(vtop_dir)/stamp
  vtop_dep_file := $$(vtop_dir)/Vtop__ver.d

  -include $$(vtop_dep_file)
  $$(vtop_dep_file):

  $$(vtop_exe): export VPATH := $$(src)
  $$(vtop_exe): $$(vtop_mk_stamp)
	$$(call run_submake,BUILD) $$(if $$(V),,-s) -C $$(vtop_dir) -f Vtop.mk
	@touch -c $$@

  $$(vtop_mk_file):
	@rm -f $$@

  $$(vtop_mk_stamp): $$(top_stamp) $$(vtop_mk_file)
	$$(eval $$(final_vflags))
	$$(call run,VERILATE) $$(VERILATOR) $$(vl_flags) $$(verilator_src_args)
	@touch $$@

  $(call target_entrypoint,$$(vtop_exe))
endef

define final_vflags
  $(call find_with_pkgconfig, \
    $(call map_core_deps,vl_pkgconfig,$(rule_top)), \
    $(call target_var,vl_cflags), \
    $(call target_var,vl_ldflags))

  $$(call target_var,vl_flags) += --Mdir $$(vtop_dir)
  $$(call target_var,vl_cflags) := $$(strip $$(vl_cflags))
  $$(call target_var,vl_ldflags) := $$(strip $$(vl_ldflags))

  # Verilator's wrapper script can't handle `-CFLAGS ''` correctly
  ifneq (,$$(vl_cflags))
    $$(call target_var,vl_flags) += -CFLAGS '$$(vl_cflags)'
  endif

  ifneq (,$$(vl_ldflags))
    $$(call target_var,vl_flags) += -LDFLAGS '$$(vl_ldflags)'
  endif
endef

verilator_src_args = \
  $(strip \
    $(let rtl_top,$(call require_core_var,$(rule_top),rtl_top), \
      --top $(rtl_top) \
      $(foreach dep,$(dep_tree/$(rule_top)), \
        $(let prefix,$(core_info/$(dep)/workdir)/, \
          $(foreach rtl_dir,$(call core_paths,$(dep),rtl_dirs), \
            -y $(rtl_dir)) \
          $(foreach include_dir,$(call core_paths,$(dep),rtl_include_dirs), \
            -I$(include_dir)) \
          $(foreach src_file,$(call core_paths,$(dep),rtl_files) $(call core_paths,$(dep),vl_files), \
            $(src_file))))) \
    $(if $(vl_main),$(vl_main),$(error $$(vl_main) not defined by target '$(rule_target)')))
