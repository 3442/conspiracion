define core
  $(this)/sdc_files := timing.sdc
  $(this)/qip_files := $(patsubst %,../../ip/%.qip,dsp_mul ip_fp_add ip_fp_mul ip_fp_fix)
  $(this)/qsf_files := pins.tcl
  $(this)/qsys_platform := platform.qsys
endef
