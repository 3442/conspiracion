cores := gfx_bootrom gfx_firmware

define core/gfx_bootrom
  $(this)/cross := riscv32-none-elf-
  $(this)/hooks := cc objcopy makehex obj

  $(this)/cc_files := bootrom.S
  $(this)/cc_flags  = -g -march=rv32imc -mabi=ilp32
  $(this)/ld_flags := -nostartfiles -nostdlib
  $(this)/ld_binary := gfx_bootrom

  $(this)/objcopy_src := gfx_bootrom
  $(this)/objcopy_obj := gfx_bootrom.bin

  $(this)/makehex_src := gfx_bootrom.bin
  $(this)/makehex_obj := gfx_bootrom.hex
endef

define core/gfx_firmware
  $(this)/cross := riscv32-none-elf-
  $(this)/hooks := cc objcopy bin2rel obj

  $(this)/obj_deps := /$(here)link.ld

  $(this)/cc_files := start.S main.c
  $(this)/cc_flags  = -g -O3 -march=rv32imc -mabi=ilp32
  $(this)/ld_flags := -nostartfiles -nostdlib -T$(here)link.ld
  $(this)/ld_binary := gfx_fw

  $(this)/objcopy_src := gfx_fw
  $(this)/objcopy_obj := gfx_fw.bin

  $(this)/bin2rel_src := gfx_fw.bin
  $(this)/bin2rel_obj := gfx_fw_payload.o
endef
