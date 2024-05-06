cores := axilemu_if

define core
  $(this)/deps := axilemu_if if_common

  $(this)/rtl_top := axilemu
  $(this)/rtl_dirs := .
  $(this)/rtl_files := axilemu.sv
endef

define core/axilemu_if
  $(this)/hooks := regblock

  $(this)/regblock_rdl := axilemu_if.rdl
  $(this)/regblock_top := axilemu_if
  $(this)/regblock_args := --default-reset arst_n
  $(this)/regblock_cpuif := axi4-lite
endef
