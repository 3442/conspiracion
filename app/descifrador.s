		mov		r1, #0x100 ; r1 = 0x100
		mov		r2, #0xCA	; r2 = 5
		mov		r7, #0x0	; r7 = 0

@Guardar en memoria 6 veces el valor del pixel: #0xCA
@ a partir de la posicion #0x100 
loop
		str		r2, [r1] 	;
		add		r1, r1, #4
		add		r7, r7, #1
		cmp		r7, #6
		bne		loop

@Reiniciar contador y posicion de memoria	
		mov		r1, #0x100
		mov		r7, #0x0

@Recorrer la memoria desde #0x100 y hacer not al valor en cada posicion
@ y volverlo a guardar
loop1
		ldr		r3, [r1]
		mvn		r3, r3
		str		r3, [r1]
		add		r1, r1, #4
		add		r7, r7, #1
		cmp		r7, #6
		bne		loop1


;e3a01c01 e3a020ca e3a07000 
;e5812000 e2811004 e2877001 e3570006 1afffffa 
;e3a01c01 e3a07000 
;e5913000 ele03003 e5813000 e2811004 e2877001 e3570006 lafffff8 

