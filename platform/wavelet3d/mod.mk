define core
  $(this)/deps :=

  $(this)/rtl_top := gfx_fpint_lane
  $(this)/rtl_dirs := .
  $(this)/rtl_files := gfx_pkg.sv gfx_fpint_lane.sv

  $(this)/vl_main := main.cpp
  $(this)/vl_pkgconfig := python3-embed
endef
