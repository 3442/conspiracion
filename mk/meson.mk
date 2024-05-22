ninja_dir = $(obj)/ninja/$(1)

define hooks/meson
  define obj_rules
    meson_stamp := $$(call ninja_dir,$(1))/meson.stamp
    ninja_stamp := $$(call ninja_dir,$(1))/ninja.stamp

    $$(call require_core_objs,$(1),meson_objs): $$(ninja_stamp)

    $$(ninja_stamp): $$(meson_stamp)
		$$(call run,NINJA,$(1)) $$(NINJA) -C $$(call ninja_dir,$(1)) install
		@touch $$@

    $$(meson_stamp): | $$(obj)
    $$(meson_stamp): $$(call meson_src,$(1)) $$(obj_deps)
		$$(call run,MESON,$(1)) $$(MESON) setup \
			$$(call require_core_paths,$(1),meson_src) $$(call ninja_dir,$(1)) \
			$$(core_info/$(1)/meson_args)
		@touch $$@
  endef

  $$(eval $$(call add_obj_rules,$(1)))
endef
