.section .interrupt_vector

__reset:
	b _start

__undefined:
	b undefined

__swi:
	b .

__prefetch_abort:
	b .

__data_abort:
	b data_abort

__irq:
	b .

__fiq:
	b .

.text

.global _start
_start:
	ldr sp, =_stack_end
	bl  reset

.global halt
halt:
exc_default:
	b   .

.weak undefined, data_abort
.set undefined, exc_default
.set data_abort, exc_default
