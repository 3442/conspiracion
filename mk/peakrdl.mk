regblock_out = $(obj)/regblock/$(regblock_core)
regblock_rdl = $(call require_core_paths,$(regblock_core),regblock_rdl)
regblock_top = $(call require_core_var,$(regblock_core),regblock_top)
regblock_cpuif = $(call require_core_var,$(regblock_core),regblock_cpuif)

define hooks/regblock
  regblock_core := $(1)
  regblock_rtl := $$(addprefix $$(regblock_out)/,$$(regblock_top)_pkg.sv $$(regblock_top).sv)

  core_info/$(1)/deps += peakrdl_intfs
  $$(eval $$(call add_core_dyn,$(1),rtl_files,$$(addprefix /,$$(regblock_rtl))))

  $$(regblock_rtl) &: $$(top_stamp) $$(regblock_rdl)
	$$(eval regblock_core := $(1))
	$$(call run,REGBLOCK,$$(core_info/$(1)/path)) $$(PEAKRDL) regblock $$(regblock_rdl) \
		-o $$(regblock_out) --cpuif=$$(regblock_cpuif) --rename=$$(regblock_top) \
		$$(core_info/$(1)/regblock_args)

  $(call target_entrypoint,$$(regblock_rtl))
endef
