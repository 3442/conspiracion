.section .interrupt_vector

__reset:
	b _start

__undefined:
	b __undefined

__swi:
	b __data_abort

__prefetch_abort:
	b __prefetch_abort

__data_abort:
	b __data_abort

__irq:
	b __irq

__fiq:
	b __fiq

.text

.global _start
_start:
	ldr sp, =_stack_end
	bl  reset
	b   .
