cores := gfx_bootrom

define core/gfx_bootrom
  $(this)/cross := riscv32-none-elf-
  $(this)/hooks := cc objcopy makehex obj

  $(this)/cc_files := gfx_bootrom.S
  $(this)/cc_flags  = -g -march=rv32imc -mabi=ilp32
  $(this)/ld_flags := -nostartfiles -nostdlib
  $(this)/ld_binary := gfx_bootrom

  $(this)/objcopy_src := gfx_bootrom
  $(this)/objcopy_obj := gfx_bootrom.bin

  $(this)/makehex_src := gfx_bootrom.bin
  $(this)/makehex_obj := gfx_bootrom.hex
endef
