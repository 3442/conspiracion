O := build
src := $(abspath .)

obj = $(O)/$(rule_top)/$(rule_target)-$(build_id)
build_id = $(call per_target,build_id)

build_vars = $(foreach var,$(1),$(call add_build_var,$(var))$(newline))
add_build_var = \
  $(call target_var,build_id_text) += $$(let val,$$($(1)),$$(if $$(val),$(1)="$$(strip $$(val))"))

build_makefiles := $(wildcard mk/*.mk)
$(build_makefiles):

build_makefiles += Makefile
build_stack :=

define enter_build
  build_stack += $$(rule_target);$$(rule_top)

  rule_top := $(1)
  rule_target := $(if $(2),$(2),$(target))
  $$(call target_var,build_id_text) =
endef

define exit_build
  last_build := $$(lastword $$(build_stack))
  build_stack := $$(filter-out $$(last_build),$$(build_stack))
  last_build := $$(subst ;,$(space),$$(last_build))

  rule_top := $$(lastword $$(last_build))
  rule_target := $$(firstword $$(last_build))
endef

define setup_obj
  export build_id_text := $$(strip $$(call per_target,build_id_text))
  $$(call target_var,build_id) := $$(shell echo -n "$$$$build_id_text" | sha1sum | head -c8)
  unexport build_id_text

  $$(obj): export CONTENTS := $$(build_id_text)
  $$(obj):
	@mkdir -p $$@ && echo -n "$$$$CONTENTS" >$$@/build-vars && ln -Tsf ../../../ $$@/src
endef

define find_command_lazy
  $(2)_cmdline := $$($(2))
  override $(call defer,$(2),$$(call find_command,$(1),$(2)))
endef

define find_command
  override $(2) := $$($(2)_cmdline)
  ifeq (,$$($(2)))
    override $(2) := $(1)
  endif

  which_out := $$(shell which $$($(2)) 2>/dev/null)

  ifneq (0,$$(.SHELLSTATUS))
    which_out :=
  endif

  ifeq (,$$(which_out))
    $$(error $(1) ($$($2)) not found)
  endif
endef

shell_defer = $(call defer,$(1),$(1) := $$(call shell_checked,$(2)))
shell_checked = $(shell $(1))$(if $(filter-out 0,$(.SHELLSTATUS)),$(error Command failed: $(1)))

define find_with_pkgconfig
  pkgs := $(strip $(1))

  ifneq (,$$(pkgs))
    ifeq (undefined,$$(origin pkgconfig_cflags/$$(pkgs)))
      $$(eval $$(run_pkgconfig))
    endif

    $(2) += $$(pkgconfig_cflags/$$(pkgs))
    $(3) += $$(pkgconfig_libs/$$(pkgs))
  endif
endef

define run_pkgconfig
  pkgconfig_cflags/$$(pkgs) := $$(shell $$(PKG_CONFIG) --cflags $$(pkgs))
  ifeq (0,$$(.SHELLSTATUS))
    pkgconfig_libs/$$(pkgs) := $$(shell $$(PKG_CONFIG) --libs $$(pkgs))
  endif

  ifneq (0,$$(.SHELLSTATUS))
    $$(error pkg-config failed for package list: $$(pkgs))
  endif
endef
