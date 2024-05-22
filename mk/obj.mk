define add_obj_rules
  core_info/$(1)/obj_rules := $$(core_info/$(1)/obj_rules)$$(newline)$$(value obj_rules)
endef

define hooks/obj
  obj_deps := $$(call core_objs,$(1),obj_deps) $$(top_stamp) | $$(obj)
  $$(eval $$(call core_info/$(1)/obj_rules))
endef
