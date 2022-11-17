.global reset
reset:

@ IO utilizado:
@  5 switches para la llave
@  1 switch de selección de algoritmo (xor o not)
@  1 botón de inicio

.equ START_BUTTON, 0x30050000 @ Dirección de memoria del botón
.equ KEY_SWITCHES, 0x30060000 @ Dirección de memoria de los switches
.equ START, 0x00010000 @ Dirección de memoria de los pixeles

@ Dirección inicial de lectura, contador y tamaño de la imagen
ldr r1, =START
mov  r7, #0x0
ldr r8, =307200

@Esperar botón
ldr r2, =START_BUTTON
ldr r3, =KEY_SWITCHES
  

idle:
  ldr r5, [r2]  @ Lee valor del botón
  ldr r6, [r3]  @ Lee valores de los switches 
  cmp r5, #1    @ Si el botón de inicio es 1, se salta a start
  bne  idle

@ Verificar el algoritmo seleccionado

  lsr r9, r6, #1			  @ Obtener la llave
  mov r0, r9, lsl #8		@ Mover llave para no afectar alpha
  orr r0, r0, r9, lsl #16 @ Replicar la llave en el siguiente byte
  orr r0, r0, r9, lsl #24 @ Replicar la llave en el siguiente byte

  and r6, r6, #1  @ Bit mask para seleccionar el primer bit de los switches
  cmp r6, #1    	@ Si el valor es 1, se salta a not, si es 0 a xor
  beq not
  cmp r6, #0
  beq  xor
  

@ Recorrer la memoria desde START y hacer not al valor en cada posicion
@ y volverlo a guardar
not:
  ldr  r4, [r1]  	@ Guarda en r4 el dato en la posición de memoria de start
  mvn  r4, r4    	@ Guarda en r4 el valor de r4 negado
  str  r4, [r1]  	@ Vuelve a guardar en memoria ya modificado
  add  r1, r1, #4  	@ Incrementa el valor de r4, para ir al siguiente pixel
  add  r7, r7, #1  	@ Incrementa contador de tamaño de la imagen
  cmp  r7, r8    	@ Compara contador con tamaño de la imagen 640 * 480
  bne  not
  b  halt

xor:
  ldr  r4, [r1]  	@ Guarda en r4 el dato en la posición de memoria de start
  eor  r4, r4, r0  	@ Hace XOR entre r4 y 46
  str  r4, [r4]   	@ Vuelve a guardar en memoria ya modificado
  add  r1, r1, #4  	@ Incrementa el valor de r4, para ir al siguiente pixel
  add  r7, r7, #1  	@ Incrementa contador de tamaño de la imagen
  cmp  r7, r8    	@ Compara contador con tamaño de la imagen 640 * 480
  bne  xor
  b  halt

halt:
  b halt