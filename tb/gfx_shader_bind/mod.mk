define core
  $(this)/deps := gfx
  $(this)/targets := pydoc test

  $(this)/rtl_top := dut
  $(this)/rtl_files := dut.sv

  $(this)/cocotb_paths := .
  $(this)/cocotb_modules := testbench.main

  $(this)/pdoc_modules := testbench
endef
