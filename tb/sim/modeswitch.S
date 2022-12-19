.global reset
reset:
	ldr   r0, =0xfee1dead
	push  {sp-lr}
	push  {r0}
	@ NOTE: Esto genera una warning de gas debido a UNPREDICTABLE
	@ writeback of base register, podría ser un bug del ensamblador,
	@ pero también podría ser la interpretación correcta del manual
	ldmia sp!, {ip-lr}^
	mov   r6, lr
	msr   cpsr_c, #0xd3
	mrs   r0, cpsr
	udf
	mrs   r2, cpsr
	ldr   r3, =#0x16f
	bic   r3, r2, r3
	msr   cpsr_fxc, r3
	mrs   r4, cpsr
	cmp   r0, r0
	mrs   r5, spsr
	nop
	msr   cpsr_fxc, r0 
	msr   spsr_fxc, r0
	mov   pc, lr

.global undefined
undefined:
	mrs    r1, spsr
	mrs    r13, cpsr
	movs   pc, lr
