$(V).SILENT:

run = \
  $(call run_common,$(1),$(2),$(3)) \
  $(if $(V),$(newline)$(3),; trap 'echo "Exited with code $$?: $$BASH_COMMAND" >&2' ERR;)

run_no_err = $(call run_common,$(1),$(2),$(3))$(newline)$(3)

run_common = \
  $(3)@printf '%s %-7s %-9s %s\n' '$(build_id)' '($(rule_target))' '$(1)' '$(if $(2),$(2),$(rule_top_path))'

run_submake = $(call run_no_err,$(1),$(2),+)$(MAKE)
