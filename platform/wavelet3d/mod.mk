define core
  $(this)/deps := dma_axi32 picorv32

  $(this)/rtl_top := gfx_float_lane
  $(this)/rtl_files := gfx_pkg.sv gfx_float_lane.sv gfx_fmul_lane.sv gfx_round_lane.sv

  $(this)/vl_main := main.cpp
  $(this)/vl_pkgconfig := python3-embed
endef
