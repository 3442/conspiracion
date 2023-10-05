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
	teq     r2, #0					@ se revisa si el valor del lock, si es 1, se bringa al jump
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
