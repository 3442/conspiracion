here = $(if $(mod_path),$(mod_path)/)
mod_path :=
subdir_stack :=

unknown_core = $(error unknown core '$(1)')

all_cores :=
all_stamps :=

top_stamp = $(call core_stamp,$(rule_top))
core_stamp = $(obj)/deps/$(core_info/$(1)/path)/stamp

core_paths = \
  $(patsubst /%,%, \
    $(patsubst /,., \
      $(abspath \
        $(let prefix,$(core_info/$(1)/workdir), \
          $(addprefix /$(if $(prefix),$(prefix)/),$(core_info/$(1)/$(2)))))))

require_core_paths = \
  $(strip \
    $(let val,$(strip $(call core_paths,$(1),$(2))), \
      $(if $(val),$(val),$(error core '$(1)' must define '$(2)'))))

require_core_var = \
  $(strip \
    $(let val,$(core_info/$(1)/$(2)), \
      $(if $(val),$(val),$(error core '$(1)' must define '$(2)'))))

define add_core
  this := core_info/$(1)

  ifneq (,$$($$(this)/path))
    $$(error multiple definitions of core '$(1)': '$$($$(this)/path)' and '$(2)')
  else ifneq (,$$(core_path/$(2)))
    $$(error multiple cores under path '$(2)')
  endif

  $$(this)/path := $(2)
  $$(this)/mod_file := $$(mod_file)
  $$(this)/workdir := $$(mod_path)

  $$(eval $$(call $(3)))

  this :=
  all_cores += $(1)
  core_path/$(2) := $(1)
endef

define add_core_subdir
  core :=
  cores :=
  subdirs :=

  subdir_stack += $$(mod_path)
  mod_path := $$(here)$(1)
  mod_file := $$(here)mod.mk

  include $$(mod_file)

  $$(if $$(core), \
    $$(eval $$(call add_core,$(notdir $(1)),$$(mod_path),core)))

  $$(foreach core,$$(cores), \
    $$(eval $$(call add_core,$$(core),$$(here)$$(core),core/$$(core))))

  $$(foreach subdir,$$(subdirs), \
    $$(eval $$(call add_core_subdir,$$(subdir))))

  mod_path := $$(lastword $$(subdir_stack))
  subdir_stack := $$(filter-out $$(mod_path),$$(subdir_stack))
endef

define setup_dep_tree
  $$(foreach core,$$(all_cores), \
    $$(eval $$(call defer,dep_tree/$$(core),$$$$(call get_core_deps,$$(core)))))
endef

define setup_stamp_rules
  $$(foreach core,$$(all_cores), \
    $$(let stamp,$$(call core_stamp,$$(core)), \
      $$(stamp) \
      $$(eval $$(call add_core_stamp,$$(core),$$(stamp))))): $$(build_makefiles) | $$(obj)
endef

define add_core_stamp
  $(2): $$(core_info/$(1)/mod_file) \
        $$(foreach dep,$$(core_info/$(1)/deps),$$(call core_stamp,$$(dep)))

  all_stamps += $(2)
endef

define get_core_deps
  dep_tree/$(1) :=

  $$(foreach dep,$$(core_info/$(1)/deps), \
    $$(if $$(core_info/$$(dep)/path),,$$(call unknown_core,$$(dep))) \
    $$(eval dep_tree/$(1) := \
      $$(dep_tree/$$(dep)) $$(filter-out $$(dep_tree/$$(dep)),$$(dep_tree/$(1)))))

  dep_tree/$(1) := $$(strip $$(dep_tree/$(1)))
  dep_tree/$(1) += $(1)
endef

map_core_deps = \
  $(if $(findstring undefined,$(origin $(1)_deps/$(2))), \
    $(eval $(call merge_mapped_deps,$(1),$(2)))) \
  $($(1)_deps/$(2))

define merge_mapped_deps
  $(1)_deps/$(2) := $$(core_info/$(2)/$(1))

  $$(foreach dep,$$(core_info/$(2)/deps), \
    $$(eval $(1)_deps/$(2) := \
      $$(let mapped_dep,$$(call map_core_deps,$(1),$$(dep)), \
        $$(mapped_dep) $$(filter-out $$(mapped_dep),$$($(1)_deps/$(2))))))
endef

define finish_stamp_rules
  $$(all_stamps):
	@mkdir -p $$$$(dirname $$@) && touch $$@
endef
