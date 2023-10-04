.global spin_init
spin_init:
	mov     r1, #0
	str     r1, [r0]
	mov     pc, lr

.global spin_lock
spin_lock:
	mrs     r2, cpsr
	str     r2, [r1]
	orr     r2, r2, #0xc0 @ Levanta I, F
	msr     cpsr_c, r2
	mov     r3, #1
1:	ldrex   r2, [r0]
	teq     r2, #0
	strexeq r2, r3, [r0]
	teqeq   r2, #0
	bne     1b
	mov     pc, lr

.global spin_unlock
spin_unlock:
	mov     r2, #0
	str     r2, [r0]
	msr     cpsr_c, r1
	mov     pc, lr
