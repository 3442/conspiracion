.section .text.init.enter
.global _start

_start:
	li    t0, 0x4a7a7b0c
	beq   a0, t0, _magic_ok
	ret

_magic_ok:
	lui  t0, %hi(__img_start)
	addi t0, t0, %lo(__img_start)
	la   t1, __img_start
	la   t2, _early_copy_end
	sub  t2, t2, t1

_early_copy_loop:
	lw   t3, 0(t1)
	sw   t3, 0(t0)
	addi t0, t0, 4
	addi t1, t1, 4
	addi t2, t2, -4
	bgtz  t2, _early_copy_loop

	lui  t2, %hi(_running_on_ram)
	addi t2, t2, %lo(_running_on_ram)
	jr   t2

_running_on_ram:
	la   t2, __img_end
	sub  t2, t2, t0

_full_copy_loop:
	lw   t3, 0(t1)
	lw   t4, 4(t1)
	lw   t5, 8(t1)
	lw   t6, 12(t1)
	sw   t3, 0(t0)
	sw   t4, 4(t0)
	sw   t5, 8(t0)
	sw   t6, 12(t0)
	addi t0, t0, 16
	addi t1, t1, 16
	addi t2, t2, -16
	bgtz t2, _full_copy_loop

.balign 4
_early_copy_end:
	la   t0, __bss_start
	la   t2, __bss_end
	sub  t2, t2, t0

_clear_bss_loop:
	sw   zero, 0(t0)
	sw   zero, 4(t0)
	sw   zero, 8(t0)
	sw   zero, 12(t0)
	addi t0, t0, 16
	addi t2, t2, -16
	bgtz t2, _clear_bss_loop

_start_done:
	la   sp, __stack
	call main
	j    .
