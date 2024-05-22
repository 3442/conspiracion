makehex_src = $(call require_core_objs,$(1),makehex_src)
makehex_obj = $(call require_core_objs,$(1),makehex_obj)

define hooks/makehex
  define obj_rules
    $$(call makehex_obj,$(1)): $$(call makehex_src,$(1)) scripts/makehex.py $$(obj_deps)
		$$(call run,MAKEHEX,$$@) $$(PYTHON3) scripts/makehex.py <$$< >$$@
  endef

  $$(eval $$(call add_obj_rules,$(1)))
endef
