define core
  $(this)/deps := gfx
  $(this)/targets := test

  $(this)/rtl_top := dut
  $(this)/rtl_files := dut.sv

  $(this)/cocotb_paths := .
  $(this)/cocotb_modules := testbench.main
endef
