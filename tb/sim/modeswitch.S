.global reset
reset:
	mrs  r0, cpsr
	udf
	mrs  r2, cpsr
	ldr  r3, =#0x16f
	bic  r3, r2, r3
	msr  cpsr_fxc, r3
	mrs  r4, cpsr
	cmp  r0, r0
	mrs  r5, spsr
	nop
	msr  cpsr_fxc, r0 
	msr  spsr_fxc, r0
	mov  pc, lr

.global undefined
undefined:
	mrs  r1, spsr
	mrs  r13, cpsr
	movs pc, lr
