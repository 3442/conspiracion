cores := gfx_shader_schedif

define core
  $(this)/deps := axixbar gfx_shader_schedif if_common picorv32

  $(this)/rtl_top := gfx_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := gfx_isa.sv gfx_pkg.sv
endef

define core/gfx_shader_schedif
  $(this)/hooks := regblock

  $(this)/regblock_rdl := gfx_shader_schedif.rdl
  $(this)/regblock_top := gfx_shader_schedif
  $(this)/regblock_args := --default-reset arst_n
  $(this)/regblock_cpuif := axi4-lite
endef
