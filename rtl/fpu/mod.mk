cores := fp_unit fp_lzc

define core/fp_lzc
  $(this)/rtl_dirs := lzc
  $(this)/rtl_files := lzc/lzc_wire.sv
endef

define core/fp_unit
  $(this)/deps := fp_lzc

  $(this)/vl_main := empty.cpp
  $(this)/rtl_top := fp_unit
  $(this)/rtl_dirs := float
  $(this)/rtl_files := float/fp_wire.sv float/fp_unit.sv
endef
