objcopy_src = $(call require_core_objs,$(1),objcopy_src)
objcopy_obj = $(call require_core_objs,$(1),objcopy_obj)

define hooks/objcopy
  define obj_rules
    $$(call objcopy_obj,$(1)): $$(call objcopy_src,$(1)) $$(obj_deps)
		$$(call run,OBJCOPY,$$@) $$(core_info/$(1)/cross)objcopy -O binary $$< $$@
  endef

  $$(eval $$(call add_obj_rules,$(1)))
endef
