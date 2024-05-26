cores := vdc_if

define core
  $(this)/deps := if_common vdc_if

  $(this)/rtl_top := vdc_top
  $(this)/rtl_dirs := .
  $(this)/rtl_files := vdc_pkg.sv vdc_top.sv
endef

define core/vdc_if
  $(this)/hooks := regblock

  $(this)/regblock_rdl := vdc_if.rdl
  $(this)/regblock_top := vdc_if
  $(this)/regblock_args := --default-reset arst_n
  $(this)/regblock_cpuif := axi4-lite
endef
