#include "custom_ops.S"

.text

.global _start
_start:

	li   a0, 0x00300000       # HOST_CTRL_BASE
	li   a1, 1 << 1 | 1 << 0  # ARINT | AWINT
	li   a2, 1 << 0           # B.VALID = 1
	li   a3, 0x8              # Firmware handover word
	la   a4, .read_data
	li   a5, 1 << 11 | 1 << 9 # CTRL.WVALID | CTRL.AWVALID
	li   a6, 1 << 12          # CTRL.BDONE, doesn't fit in andi

	sw   a1, 0(a0)

.wait_axi:
	picorv32_waitirq_insn(zero)

	lw   t0, 0(a0)
	andi t1, t0, 1 << 8 # ARVALID
	bne  t1, zero, .read
	and  t0, t0, a5
	beq  t0, a5, .write
	j    .wait_axi

.read:
	lw   t0, 4(a0)
	andi t1, t0, 1 << 0 # AW.VALID
	beq  t1, zero, .wait_axi
	andi t0, t0, 0b11 << 2
	add  t0, a4, t0
	lw   t0, 0(t0)
	sw   t0, 12(a0) # R.DATA

.read_done:
	lw   t0, 0(a0)
	andi t0, t0, 1 << 10 # CTRL.RDONE
	beq  t0, zero, .read_done
	j    .wait_axi

.write:
	lw   t0, 8(a0)
	andi t1, t0, 1 << 0 # AW.VALID
	beq  t1, zero, .wait_axi
	lw   t1, 16(a0)
	sw   a2, 20(a0)

.write_done:
	lw   t2, 0(a0)
	and  t2, t2, a6
	beq  t2, zero, .write_done

	andi t0, t0, ~0b11
	bne  t0, a3, .wait_axi
	sw   zero, 0(a0)
	# Pass magic & hardware version
	lw   a0, 0(a4)
	lw   a1, 4(a4)
	jalr t1
	j    .

.balign 4

.read_data:
	# Magic
	.word 0x4a7a7b0c
	# Hardware major.minor.patch
	.word 1 << 16 | 0 << 8 | 0 << 0
	# Firmware yyyy.mm.dd.build
	.word 2024 << 19 | 5 << 15 | 12 << 10 | 1 << 0
	# Register map version, rev 0 means this is the bootrom firmware
	.word 0

.balign 4
