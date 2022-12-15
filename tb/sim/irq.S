.global reset
reset:
	# Stop and reset timer
	ldr  r2, =0x30020000
	mov  r1, #(1 << 3)
	str  r1, [r2, #4]
	mov  r1, #0
	str  r1, [r2, #0]

	# Enable timer interrupts
	ldr  r3, =0x30070000
	ldr  r1, =(1 << 0)
	str  r1, [r3, #4]

	# Enable IRQs
	mov  r0, #0
	mrs  r1, cpsr
	and  r1, #~(1 << 7)
	msr  cpsr_c, r1

	# Program timer with timeout value of 128 cycles
	mov  r1, #4
	str  r1, [r2, #8]
	mov  r1, #0
	str  r1, [r2, #12]

	# Start timer
	mov  r1, #(1 << 0 | 1 << 2)
	str  r1, [r2, #4]

	.wfi:
	# Una secuencia de load-stores intensos como esta se encuentra en el
	# código de calibración de delay loop del kernel. Antes del commit
	# con título 'Fix register corruption when interrupting a load-store',
	# una IRQ justo aquí provcaba que el core entrara en un estado indefinido.
	# En el caso de Linux, eso resultaba en kernel panics indepurables.
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	ldr  r10, [r2]
	tst  r0, r0
	beq  .wfi

	mov  r2, #2
	mov  pc, lr

.global irq
irq:
	mov  r0, #1
	ldr  r1, [r2, #0]
	mov  r4, #0
	str  r4, [r2, #0]
	subs pc, lr, #4
