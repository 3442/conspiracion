define core
  $(this)/deps := axixbar picorv32

  $(this)/rtl_top := gfx_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := gfx_pkg.sv gfx_top.sv

  $(this)/vl_main := main.cpp
  $(this)/vl_pkgconfig := python3-embed
endef
