#define MOD_NAME "dma"

#include <stddef.h>

#include "log.h"
#include "sgdma.h"

struct sgdma_ctrl
{
	unsigned start_busy : 1;
	unsigned interrupt  : 1;
	unsigned int_en     : 1;
	unsigned abort      : 1;
	unsigned err        : 1;
	unsigned reserved   : 27;
};

struct sgdma_entry
{
	unsigned src_lo;
	unsigned src_hi   : 30;
	unsigned flags    : 2;
	unsigned dst_lo;
	unsigned dst_hi   : 30;
	unsigned mbz      : 1;
	unsigned int_en   : 1;
	unsigned length;
};

// axisgfsm.v, la lista de axisgdma.v está mala
enum sgdma_entry_flags
{
	SGDMA_ENTRY_CONT = 0b00,
	SGDMA_ENTRY_LAST = 0b01,
	SGDMA_ENTRY_SKIP = 0b10,
	SGDMA_ENTRY_JUMP = 0b11,
};

#define SGDMA_BASE  0x28000000
#define SGDMA_CTRL  (*(volatile struct sgdma_ctrl *)(SGDMA_BASE + 0x00))
#define SGDMA_TBLLO (*(volatile unsigned *)         (SGDMA_BASE + 0x08))
#define SGDMA_TBLHI (*(volatile unsigned *)         (SGDMA_BASE + 0x0c))

int sgdma_done(void)
{
	return !SGDMA_CTRL.start_busy;
}

void sgdma_barrier(void)
{
	while (!sgdma_done()); //FIXME
}

void sgdma_memcpy(void *dest, const void *src, size_t len)
{
	struct sgdma_entry entry = {
		.src_lo = (unsigned)src,
		.src_hi = 0,
		.flags  = SGDMA_ENTRY_LAST,
		.dst_lo = (unsigned)dest,
		.dst_hi = 0,
		.mbz    = 0,
		.int_en = 0,
		.length = (unsigned)len,
	};

	SGDMA_TBLLO = (unsigned)&entry;
	SGDMA_TBLHI = 0;

	struct sgdma_ctrl ctrl = {
		.start_busy = 1,
		.interrupt  = 0,
		.int_en     = 0,
		.abort      = 0,
		.err        = 0,
		.reserved   = 0,
	};

	SGDMA_CTRL = ctrl;

	sgdma_barrier(); //TODO, sin esto sgdma lee entry corrupto
}
