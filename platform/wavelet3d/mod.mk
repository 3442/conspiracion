subdirs := host_sw

define core
  $(this)/deps := axixbar if_common gfx w3d_host_sw

  $(this)/rtl_top := w3d_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := w3d_top.sv

  $(this)/obj_deps := gfx_bootrom.hex w3d_host_flash.bin

  $(this)/vl_main := main.cpp remote_jtag.cpp
  $(this)/vl_pkgconfig := sdl2
endef
