MEMORY
{
  HPS_SDRAM (rwx) : ORIGIN = 0x00000000, LENGTH = 512M
}

SECTIONS
{
  ._img :
  {
    KEEP(*(.interrupt_vector))
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(.data)
    *(.data*)
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
  } > HPS_SDRAM

  _stack_shift = 13;
  _stack_size = (1 << _stack_shift) * (4 + 1); # Hay un stack extra para irq
  _stack_end = ORIGIN(HPS_SDRAM) + LENGTH(HPS_SDRAM);
  _irq_stack = _stack_end;
  _stack_begin = (_stack_end - _stack_size) + (1 << _stack_shift);
  
  . = _stack_begin;
  ._stack :
  {
    . = . + _stack_size;
  } > HPS_SDRAM
}
