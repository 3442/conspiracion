bin2rel_src = $(call require_core_objs,$(1),bin2rel_src)
bin2rel_obj = $(call require_core_objs,$(1),bin2rel_obj)

define hooks/bin2rel
  define obj_rules
    $$(call bin2rel_obj,$(1)): $$(call bin2rel_src,$(1)) $$(obj_deps)
		$$(call run,BIN2REL,$$@) \
			cd $$(dir $$<) && \
			$$(core_info/$(1)/cross)ld -r -b binary -o $$(src)/$$@.data $$(notdir $$<) && \
			cd - && \
			$$(core_info/$(1)/cross)objcopy \
				--rename-section .data=.rodata,alloc,load,readonly,data,contents \
				--set-section-alignment .data=16 \
				$$@.data $$@ && \
			rm -f $$@.data
  endef

  $$(eval $$(call add_obj_rules,$(1)))
endef
