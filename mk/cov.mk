targets += cov

cov_cores = $(call per_target,cov_cores)

define target/cov/prepare
  enable_cov := 1
endef

define target/cov/setup
  $$(call target_var,cov_cores) := \
    $$(foreach dep,$$(dep_tree/$$(rule_top)), \
      $$(if $$(filter test,$$(core_info/$$(dep)/targets)), \
        $$(eval $$(call build_target_top,$$(dep),test)) \
        $$(dep)))
endef

define target/cov/rules
  .PHONY: $$(rule_top_path)/cov
  $$(rule_top_path)/cov: $$(obj)/html

  $$(obj)/html: $$(obj)/coverage.info | $$(obj)
	@rm -rf $$@
	$$(call run,GENHTML) $$(GENHTML) $$< --output-dir=$$@

  $$(obj)/coverage.info: $$(foreach core,$$(cov_cores),$$(obj/test/$$(core))/results.xml) | $$(obj)
	$$(call run,COVERAGE) $$(VERILATOR)_coverage -write-info $$@ \
		$$(wildcard $$(foreach core,$$(cov_cores),$$(obj/test/$$(core))/coverage.dat))

  $(call target_entrypoint,$(obj)/html)
endef
