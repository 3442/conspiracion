.global reset
reset:
	# Copy code to page 3
	ldr  r0, =.virtual_start
	ldr  r1, =0x3000
	ldr  r2, =256
	.copy_virtual:
	ldr  r3, [r0], #4
	str  r3, [r1], #4
	subs r2, r2, #4
	bne  .copy_virtual

	# Translation tables
	mov  r0, #0x4000
	ldr  r1, =0x00005001
	str  r1, [r0]

	mov  r1, #0x5000
	ldr  r2, =0x00000002
	str  r2, [r1], #4
	str  r2, [r1], #4
	str  r2, [r1], #4
	str  r2, [r1], #4
	ldr  r2, =0x00003002
	str  r2, [r1], #4

	# Set translation base, domain control register and enable MMU
	mov  r1, #(1 << 0)
	mov  r2, #-1
	mcr  p15, 0, r2, c3, c0, 0
	mcr  p15, 0, r0, c2, c0, 0
	mcr  p15, 0, r1, c1, c0, 0

	# Self-relocate to 0x2000 (mirror of 0x0000)
	ldr  r1, =#(0x2000 - 4)
	add  pc, pc, r1

	# Jump to .virtual_start (phys: 0x3000, virt: 0x4000)
	ldr  r0, =0x01234567
	ldr  pc, =0x4000
	b    .

	.virtual_start:
	ldr  r1, =0x89abcdef
	and  r6, r1, #~0xf
	mov  r4, lr
	mov  r5, lr
	# This triggers a page fault
	ldr  r4, [r6]

.global data_abort
data_abort:
	mrc  p15, 0, r2, c6, c0, 0
	mrc  p15, 0, r3, c5, c0, 0
	# Domain field is invalid for section translation faults
	and  r3, r3, #0b1111
	# Results in a prefetch abort
	mov  pc, r2

.global prefetch_abort
prefetch_abort:
	mov  r6, lr
	mov  pc, r4
