cores := conspiracion test_fb test_fifo test_ring test_smp

define core/conspiracion
  $(this)/targets   := sim
  $(this)/deps      := conspiracion/tb
  $(this)/rtl_files := conspiracion.sv
  $(this)/rtl_top   := conspiracion
  $(this)/vl_main   := ../../tb/top/conspiracion/conspiracion.cpp
  $(this)/vl_runner := run_conspiracion
endef

define core/test_fb
  $(this)/targets        := test
  $(this)/deps           := gfx
  $(this)/rtl_files      := test_fb.sv
  $(this)/rtl_top        := test_fb
  $(this)/cocotb_paths   := ../../..
  $(this)/cocotb_modules := tb.top.test_fb
endef

define core/test_fifo
  $(this)/targets        := test
  $(this)/deps           := gfx
  $(this)/rtl_files      := test_fifo.sv
  $(this)/rtl_top        := test_fifo
  $(this)/cocotb_paths   := ../../..
  $(this)/cocotb_modules := tb.top.test_fifo
endef

define core/test_ring
  $(this)/targets        := test
  $(this)/deps           := cache
  $(this)/rtl_files      := test_ring.sv
  $(this)/rtl_top        := test_ring
  $(this)/cocotb_paths   := ../../..
  $(this)/cocotb_modules := tb.top.test_ring
endef

define core/test_smp
  $(this)/targets        := test
  $(this)/deps           := smp test_fifo test_ring
  $(this)/rtl_files      := test_smp.sv
  $(this)/rtl_top        := test_smp
  $(this)/cocotb_paths   := ../../..
  $(this)/cocotb_modules := tb.top.test_smp
endef
