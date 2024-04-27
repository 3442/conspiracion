define core
  $(this)/targets := sim test

  $(this)/rtl_top := axi_timer_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := axi_bus.sv axi_timer_top.sv

  $(this)/cocotb_paths := .
  $(this)/cocotb_modules := testbench
endef
