define core
  $(this)/deps := picorv32
  $(this)/rtl_top := picorv32
  $(this)/vl_main := main.cpp
  $(this)/vl_pkgconfig := python3-embed
endef
