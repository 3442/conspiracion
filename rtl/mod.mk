cores   := config debounce intc
subdirs := cache core gfx perf picorv32 smp top

define core/config
  $(this)/rtl_include_dirs := .
endef

define core/debounce
  $(this)/rtl_files := debounce.sv
  $(this)/rtl_top   := debounce
endef

define core/intc
  $(this)/rtl_files := intc.sv
  $(this)/rtl_top   := intc
endef
