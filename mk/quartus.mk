# Based on github:alexforencich/verilog-ethernet:example/DE2-115/fpga/common/quartus.mk

targets += syn

quartus_qsf = $(obj)/$(quartus_top).qsf
quartus_qpf = $(obj)/$(quartus_top).qpf
quartus_run = cd $(obj) && $(QUARTUS)

quartus_top = $(call per_target,quartus_top)
quartus_device = $(call per_target,quartus_device)
quartus_family = "$(call per_target,quartus_family)"

quartus_rtl = $(call per_target,quartus_rtl)
quartus_sdc = $(call per_target,quartus_sdc)
quartus_tcl = $(call per_target,quartus_tcl)
quartus_qip = $(call per_target,quartus_qip)
quartus_qsys = $(call per_target,quartus_qsys)
quartus_rtl_include = $(call per_target,quartus_rtl_include)

quartus_platforms = $(call per_target,quartus_platforms)
quartus_src_files = $(quartus_rtl) $(quartus_sdc) $(quartus_qip) $(quartus_qsys) $(quartus_tcl)

quartus_plat_qip = $(foreach plat,$(quartus_platforms),$(call quartus_plat_path,$(plat)))
quartus_plat_path = qsys/$(1)/synthesis/$(basename $(notdir $(core_info/$(1)/qsys_platform))).qip

define target/syn/prepare
  flow/type := syn
endef

define target/syn/setup
  $(call target_var,quartus_top) := $$(call require_core_var,$$(rule_top),rtl_top)
  $(call target_var,quartus_device) := $$(call require_core_var,$$(rule_top),altera_device)
  $(call target_var,quartus_family) := $$(call require_core_var,$$(rule_top),altera_family)
endef

define target/syn/rules
  deps := $$(dep_tree/$$(rule_top))

  explicit_rtl := $$(foreach dep,$$(deps),$$(call core_paths,$$(dep),rtl_files))

  $(call target_var,quartus_rtl) := \
    $$(explicit_rtl) \
    $$(filter-out $$(explicit_rtl), \
      $$(foreach rtl_dir,$$(foreach dep,$$(deps),$$(call core_paths,$$(dep),rtl_dirs)), \
        $$(filter %.v %.sv %.vhd,$$(wildcard $$(rtl_dir)/*))))

  $(call target_var,quartus_rtl_include) := \
    $$(foreach dep,$$(deps),$$(call core_paths,$$(dep),rtl_include_dirs))

  $(call target_var,quartus_sdc) := \
    $$(foreach dep,$$(deps),$$(call core_paths,$$(dep),sdc_files))

  $(call target_var,quartus_qip) := \
    $$(foreach dep,$$(deps),$$(call core_paths,$$(dep),qip_files))

  $(call target_var,quartus_tcl) := \
    $$(foreach dep,$$(deps),$$(call core_paths,$$(dep),qsf_files))

  $(call target_var,quartus_platforms) := \
    $$(foreach dep,$$(deps),$$(if $$(core_info/$$(dep)/qsys_platform),$$(dep)))

  $(call target_var,quartus_qsys) := \
	$$(foreach dep,$$(quartus_platforms),$$(call core_paths,$$(dep),qsys_platform))

  .PHONY: $$(rule_top_path)/syn

  $$(rule_top_path)/syn: $$(obj)/asm.stamp
	$$(if $$(enable_gui),$$(call run,GUI) $$(quartus_run) $$(quartus_top).qpf)

  $$(obj)/asm.stamp: $$(obj)/sta.stamp
	$$(call run,ASM) $$(quartus_run)_asm $$(quartus_top)
	@touch $$@

  $$(obj)/sta.stamp: $$(obj)/fit.stamp
	$$(call run,STA) $$(quartus_run)_sta $$(quartus_top)
	@touch $$@

  $$(obj)/fit.stamp: $$(obj)/map.stamp
	$$(call run,FIT) $$(quartus_run)_fit --part=$$(quartus_device) $$(quartus_top)
	@touch $$@

  $$(obj)/map.stamp: $$(quartus_qpf) $$(call core_objs,$$(rule_top),obj_deps)
	$$(call run,MAP) $$(quartus_run)_map --family=$(quartus_family) $$(quartus_top)
	@touch $$@

  $$(quartus_qsf) $$(quartus_qpf) &: \
    $$(top_stamp) $$(quartus_src_files) \
    $$(addprefix $$(obj)/,$$(quartus_plat_qip))
	$$(call run,QSF) \
	rm -f $$(quartus_qsf) $$(quartus_qpf) && \
	cd $$(obj) && \
	$$(QUARTUS)_sh \
		--prepare -f $$(quartus_family) -d $$(quartus_device) \
		-t $$(quartus_top) $$(quartus_top) && \
	exec >>$$(quartus_top).qsf && \
	echo -e "\n\n# Source files" && \
	assignment() { echo set_global_assignment -name $$$$1 $$$$2; } && \
	assignment_list() { \
		title="$$$$1"; \
		name="$$$$2"; \
		shift 2; \
		echo -e "\n# $$$$title" && \
		for x in $$$$@; do assignment "$$$${name}" "$$$$x"; done \
	} && \
	for x in $$(quartus_rtl); do \
		case $$$${x##*.} in \
			[Vv])         name=VERILOG_FILE ;; \
			[Ss][Vv])     name=SYSTEMVERILOG_FILE ;; \
			[Vv][Hh][Dd]) name=VHDL_FILE ;; \
			*)            name=SOURCE_FILE ;; \
		esac; \
		assignment "$$$$name" "src/$$$$x"; \
	done && \
	assignment_list "Search paths" SEARCH_PATH $$(addprefix src/,$$(quartus_rtl_include)) && \
	assignment_list "Constraint files" SDC_FILE $$(addprefix src/,$$(quartus_sdc)) && \
	assignment_list "IPs" QIP_FILE $$(addprefix src/,$$(quartus_qip)) && \
	assignment_list "Platform IPs" QIP_FILE $$(quartus_plat_qip) && \
	assignment_list "Platforms" QSYS_FILE $$(addprefix src/,$$(quartus_qsys)) && \
	for x in $$(quartus_tcl); do printf "\n#\n# TCL file %s\n#\n" "$$$$x"; cat "src/$$$$x"; done

  $(call target_entrypoint,$(patsubst %,$$(obj)/%.stamp,map fit sta asm))

  $$(foreach plat,$$(quartus_platforms),$$(eval $$(call quartus_qsys_rules,$$(plat))))
endef

define quartus_qsys_rules
  qip_file := $$(obj)/$$(call quartus_plat_path,$(1))
  qsys_file := $$(call core_paths,$(1),qsys_platform)

  $$(qip_file): qsys_file := $$(qsys_file)
  $$(qip_file): $$(call core_stamp,$(1)) $$(qsys_file)
	$$(call run,QSYS,$$(qsys_file)) $$(QSYS_GENERATE) \
		-syn --part=$$(quartus_device) --output-directory=$$(obj)/qsys/$(1) $$(qsys_file)
endef
