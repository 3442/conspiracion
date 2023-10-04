#include "demo.h"

#define CACHE_DEBUG_BASE(n)    (0x30100000 | (0x10000 * (n)))
#define CACHE_DEBUG_WORD(n, i) (*(volatile unsigned *)(CACHE_DEBUG_BASE(n) + 16 + 4 * (i)))

#define CACHE_STATUS(n)          (*(volatile unsigned *)CACHE_DEBUG_BASE(n))
#define CACHE_STATUS_CACHED      (1 << 1)
#define CACHE_STATUS_STATE_MASK  0x0000000c
#define CACHE_STATUS_STATE_SHIFT 2
#define CACHE_STATUS_INDEX_MASK  0x0000fff0
#define CACHE_STATUS_INDEX_SHIFT 4
#define CACHE_STATUS_INDEX_BITS  12
#define CACHE_STATUS_TAG_MASK    0x1fff0000
#define CACHE_STATUS_TAG_SHIFT   16
#define CACHE_STATUS_TAG_BITS    13
#define CACHE_STATUS_STATE_I     0b00
#define CACHE_STATUS_STATE_S     0b01
#define CACHE_STATUS_STATE_E     0b10
#define CACHE_STATUS_STATE_M     0b11

void cache_debug(unsigned cpu, void *ptr)
{
	unsigned ptr_val = (unsigned)ptr;

	CACHE_STATUS(cpu) = (unsigned)ptr;
	unsigned status = CACHE_STATUS(cpu);

	int cached = status & CACHE_STATUS_CACHED;

	print("req_addr:     %p", ptr);
	print("cacheability: %s", cached ? "write-back" : "uncached (I/O)");

	if (!cached)
		return;

	unsigned index = (status & CACHE_STATUS_INDEX_MASK) >> CACHE_STATUS_INDEX_SHIFT;
	unsigned addr_tag = (ptr_val & CACHE_STATUS_TAG_MASK) >> CACHE_STATUS_TAG_SHIFT;
	unsigned cache_tag = (status & CACHE_STATUS_TAG_MASK) >> CACHE_STATUS_TAG_SHIFT;
	unsigned line_addr = status & (CACHE_STATUS_TAG_MASK | CACHE_STATUS_INDEX_MASK);

	print("index:        %r", index, CACHE_STATUS_INDEX_BITS);
	print("req_tag:      %r", addr_tag, CACHE_STATUS_TAG_BITS);
	print("cache_tag:    %r", cache_tag, CACHE_STATUS_TAG_BITS);
	print("req_line:     %p", ptr_val & (CACHE_STATUS_TAG_MASK | CACHE_STATUS_INDEX_MASK));
	print("cache_line:   %p", line_addr);

	int valid, dirty;
	const char *state;

	switch ((status & CACHE_STATUS_STATE_MASK) >> CACHE_STATUS_STATE_SHIFT) {
		case CACHE_STATUS_STATE_I:
			valid = 0;
			dirty = 0;
			state = "INVALID";
			break;

		case CACHE_STATUS_STATE_S:
			valid = 1;
			dirty = 0;
			state = "SHARED";
			break;

		case CACHE_STATUS_STATE_E:
			valid = 1;
			dirty = 0;
			state = "EXCLUSIVE";
			break;

		case CACHE_STATUS_STATE_M:
			valid = 1;
			dirty = 1;
			state = "MODIFIED";
			break;
	}

	print("valid=%d dirty=%d state=%s", valid, dirty, state);
	print("access is a %s on cpu%u", valid && addr_tag == cache_tag ? "hit" : "miss", cpu);

	for (unsigned i = 0; i < 4; ++i) {
		print("%p: %x", line_addr | i << CACHE_STATUS_STATE_SHIFT, CACHE_DEBUG_WORD(cpu, i));
	}
}
