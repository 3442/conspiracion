define core
  $(this)/deps     := config
  $(this)/rtl_dirs := .
  $(this)/rtl_top  := core

  ifeq (sim,$(flow/type))
    $(this)/deps += ip_mul
  endif
endef
