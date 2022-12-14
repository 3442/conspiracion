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
