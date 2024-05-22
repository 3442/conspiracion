.PHONY: .force .no_default

.no_target:
	$(error no default target defined in top Makefile)

.force:

empty :=
space := $(empty) $(empty)
comma := ,

# Both empty lines are required
define newline


endef

newline := $(newline)

defer = $(1) = $$(eval $(2))$$($(1))

ifeq (,$(top))
  $(error $$(top) is not defined)
endif

$(foreach flag,$(subst $(comma),$(space),$(enable)),$(eval override enable_$(flag) := 1))
$(foreach flag,$(subst $(comma),$(space),$(disable)),$(eval override enable_$(flag) :=))

include mk/build.mk
include mk/cocotb.mk
include mk/cores.mk
include mk/cov.mk
include mk/obj.mk
include mk/output.mk
include mk/peakrdl.mk
include mk/quartus.mk
include mk/target.mk
include mk/tools.mk
include mk/verilator.mk

$(eval $(check_target))
$(eval $(find_tools_lazy))

ifneq (,$(target))
  $(eval $(target/$(target)/prepare))
endif

$(foreach top_dir,mk/builtin $(core_dirs), \
  $(eval $(call add_core_subdir,$(top_dir))))

top_path := $(core_info/$(top)/path)

ifeq (,$(top_path))
  $(call unknown_core,$(top))
endif

$(eval $(setup_dep_tree))

define build_target_top
  ifeq (,$$(obj/$(if $(2),$(2),$(target))/$(1)))
    $$(eval $$(call enter_build,$(1),$(2)))
    $$(eval $$(call build_vars,rule_target rule_top core_info/$$(rule_top)/build))

    $$(eval $$(target/$$(rule_target)/setup))

    $$(eval $$(setup_obj))
    $$(eval $$(setup_stamp_rules))

    $$(foreach core,$$(all_cores), \
     $$(foreach hook,$$(core_info/$$(core)/hooks), \
        $$(eval $$(call hooks/$$(hook),$$(core)))))

    $$(eval $$(target/$$(rule_target)/rules))

    obj/$$(rule_target)/$$(rule_top) := $$(obj)
    $$(eval $$(exit_build))
  endif
endef

ifneq (,$(target))
  $(eval $(call build_target_top,$(top)))
endif

$(eval $(setup_submake_rules))
$(eval $(finish_stamp_rules))
