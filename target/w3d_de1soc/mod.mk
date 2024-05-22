define core
  $(this)/deps := debounce axixbar wavelet3d

  $(this)/rtl_top := w3d_de1soc
  $(this)/rtl_files := w3d_de1soc.sv

  $(this)/sdc_files := timing.sdc
  $(this)/qip_files := $(patsubst %,../../ip/%.qip,dsp_mul ip_fp_add ip_fp_mul ip_fp_fix)
  $(this)/qsf_files := pins.tcl
  $(this)/qsys_platform := platform.qsys

  $(this)/obj_deps := gfx_bootrom.hex

  $(this)/altera_device := 5CSEMA5F31C6
  $(this)/altera_family := Cyclone V
endef
