define core
  $(this)/deps := axixbar if_common gfx

  $(this)/rtl_top := w3d_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := w3d_top.sv

  $(this)/vl_main := main.cpp remote_jtag.cpp
  $(this)/vl_pkgconfig := sdl2
endef
