cores := ip_mul interconnect
subdirs := gfx_shader_bind top/conspiracion

define core/ip_mul
  $(this)/rtl_files := dsp_mul.sv
endef

define core/interconnect
  $(this)/rtl_files := mem_interconnect.sv
endef
