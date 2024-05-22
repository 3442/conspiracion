cores := w3d_host_flash w3d_host_sw w3d_picolibc

define core/w3d_host_sw
  $(this)/deps := w3d_picolibc
  $(this)/cross := riscv32-none-elf-
  $(this)/hooks := cc objcopy obj

  $(this)/obj_deps := picolibc/picolibc.specs

  $(this)/cc_files := main.c
  $(this)/cc_flags  = -g -march=rv32imafc -mabi=ilp32f --specs=$$(obj)/picolibc/picolibc.specs
  $(this)/ld_flags := --oslib=semihost
  $(this)/ld_binary := w3d_host_flash

  $(this)/objcopy_src := w3d_host_flash
  $(this)/objcopy_obj := w3d_host_flash.bin
endef

define core/w3d_picolibc
  $(this)/hooks := meson obj

  $(this)/obj_deps := /$(here)cross-riscv32-none-elf.txt

  $(this)/meson_src := picolibc
  $(this)/meson_objs := picolibc/picolibc.specs

  $(this)/meson_args = \
    -Dincludedir=include \
    -Dlibdir=lib \
    -Dspecsdir=. \
    -Dmultilib=false \
    -Dprefix=$$(src)/$$(obj)/picolibc \
    --cross-file $(here)cross-riscv32-none-elf.txt
endef
