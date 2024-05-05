define core
  $(this)/deps := gfx

  $(this)/rtl_top := w3d_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := w3d_top.sv

  $(this)/vl_main := main.cpp
  $(this)/vl_pkgconfig := sdl2
endef
