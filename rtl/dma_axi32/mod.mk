define core
  $(this)/rtl_top := dma_axi32
  $(this)/rtl_files := $(call core_shell,cat filelist.txt)
  $(this)/rtl_include_dirs := .
endef
