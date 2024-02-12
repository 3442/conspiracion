target_var = $(1)/$(rule_target)/$(rule_top)
per_target = $($(call target_var,$(1)))

rule_top_path = $(core_info/$(rule_top)/path)

define target_entrypoint
  $(1): rule_top := $$(rule_top)
  $(1): rule_target := $$(rule_target)
endef

define check_target
  ifneq ($$(target),$$(findstring $$(target),$$(targets)))
    $$(error bad target '$$(target)')
  endif
endef

define setup_submake_rules
  .PHONY: $$(targets)

  other_targets := $$(filter-out $$(target),$$(targets))

  $$(foreach t,$$(targets),$$(eval $$(call top_rule,$$(t))))

  ifeq (,$$(target))
    $$(foreach other,$$(other_targets), \
      $$(foreach core,$$(all_cores), \
        $$(eval $$(call submake_rule,$$(other),$$(core)))))
  else
    $$(foreach core,$$(filter-out $$(top),$$(all_cores)), \
      $$(eval $$(call submake_rule,$$(target),$$(core))))
  endif
endef

define top_rule
  $(1): $$(top_path)/$(1)
endef

define submake_rule
  path := $$(core_info/$(2)/path)/$(1)

  .PHONY: $$(path)

  $$(path):
	+$$(MAKE) --no-print-directory target=$(1) top=$(2) $$@
endef
