cores := axixbar

define core
  $(this)/rtl_dirs := .
endef

define core/axixbar
  $(this)/deps := wb2axip
  $(this)/rtl_top := axixbar
endef
