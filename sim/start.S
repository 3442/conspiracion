.section .interrupt_vector

__reset:
	b _start

__undefined:
	b undefined

__swi:
	b swi

__prefetch_abort:
	b prefetch_abort

__data_abort:
	b data_abort

__reserved:
	b .

__irq:
	b irq

__fiq:
	b .

.text

.global _start
_start:
	ldr sp, =_stack_end
	bl  reset
	b   .

.weak undefined, swi, data_abort, prefetch_abort, irq
.set swi, __swi
.set undefined, __undefined
.set data_abort, __data_abort
.set prefetch_abort, __prefetch_abort
.set irq, __irq
