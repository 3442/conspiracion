cc_srcs = $(call require_core_paths,$(1),cc_files)
ld_objs = $(call cc_srcs_to_objs,$(1),$(call cc_srcs,$(1))) $(call core_objs,$(1),ld_extra)
cc_srcs_to_objs = $(addsuffix .o,$(addprefix $(obj)/cc/$(1)/,$(basename $(notdir $(2)))))

define hooks/cc
  define obj_rules
    cc_binary := $$(call require_core_objs,$(1),ld_binary)

    $$(cc_binary): | $$(obj)/cc/$(1)
    $$(cc_binary): $$(call ld_objs,$(1)) $$(obj_deps)
		$$(call run,LD,$$@) $$(core_info/$(1)/cross)gcc \
			$$(core_info/$(1)/cc_flags) $$(core_info/$(1)/ld_flags) \
			$$(call ld_objs,$(1)) -o $$@

    $$(obj)/cc/$(1): $$(obj)
		@mkdir -p $$@
  endef

  $$(eval $$(call add_obj_rules,$(1)))

  $$(foreach src,$$(call cc_srcs,$(1)), \
    $$(eval $$(call cc_unit_rule,$(1),$$(src),$$(call cc_srcs_to_objs,$(1),$$(src)))))
endef

define cc_unit_rule
  define obj_rules
    $(3): | $$(obj)/cc/$(1)
    $(3): $(2) $$(obj_deps)
		$$(call run,CC,$$<) $(core_info/$(1)/cross)gcc $(core_info/$(1)/cc_flags) -MMD -c $$< -o $$@
  endef

  $$(eval $$(call add_obj_rules,$(1)))

  -include $$(patsubst %.o,%.d,$(3))
endef
