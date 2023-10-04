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
	b _irq_entry

__fiq:
	b .

.text

.global _start
_start:
	ldr r0, =_boot_num
	ldr r1, [r0]
	add r2, r1, #1
	str r2, [r0]
	ldr r2, =__cpus
	lsl r3, r1, #2
	ldr r9, [r2, r3]
	str r1, [r9]
	ldr r2, =_stack_shift
	lsl r1, r1, r2
	ldr sp, =_stack_begin
	add sp, sp, r1
	mov lr, #0
	bl  reset
	b   .

_boot_num:
	.word 0

_irq_entry:
	ldr  sp, =_irq_stack
	push {r0-r11, lr}
	bl   irq
	pop  {r0-r11, lr}
	subs pc, lr, #4

.weak undefined, swi, data_abort, prefetch_abort
.set swi, __swi
.set undefined, __undefined
.set data_abort, __data_abort
.set prefetch_abort, __prefetch_abort
