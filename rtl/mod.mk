cores   := config debounce intc
subdirs := cache core dma_axi32 fpu gfx perf picorv32 smp top wb2axip

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
