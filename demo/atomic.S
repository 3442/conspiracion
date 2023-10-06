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
1:	ldrex   r2, [r0]				@ se carga el valor del lock
	teq     r2, #0					@ se revisa si el valor del lock, si es 1, se brinca al jump
	strexeq r2, r3, [r0]			@ trata de guardar r3 en r0, pero solo si el monitor se lo permite
	teqeq   r2, #0					@ revisa si en efecto se hizo el store o no
	bne     1b						@ regresa al inicio
	mov     pc, lr					@ retorna de la función
									@ 
									@ la implicación de esto es que si dos
									@  cores intentan hacer accesar al mismo
									@  recurso, el monitor solo va a dejar a uno
									@  de ellos hacerlo
.global spin_unlock
spin_unlock:
	mov     r2, #0
	str     r2, [r0]
	msr     cpsr_c, r1
	mov     pc, lr

.global compare_exchange_64
compare_exchange_64:
	push    {r4, r5, r6, r7, r8}
	ldr     r4, [r1]
	ldr     r5, [r1, #4]
	add     r8, r0, #4
	ldrex   r6, [r0]
	ldrex   r7, [r8]
	teq     r4, r6
	teqeq   r5, r7
	strexeq r4, r2, [r0]
	strexeq r4, r3, [r8]
	teqeq   r4, #0
	moveq   r0, #1
	movne   r0, #0
	strne   r6, [r1]
	strne   r7, [r1, #4]
	pop     {r4, r5, r6, r7, r8}
	mov     pc, lr
