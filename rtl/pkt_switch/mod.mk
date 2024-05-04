define core
  $(this)/targets := test

  $(this)/rtl_top := pkt_switch
  $(this)/rtl_files := pkt_switch.v

  $(this)/cocotb_paths := .
  $(this)/cocotb_modules := testbench
endef
