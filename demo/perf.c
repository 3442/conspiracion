#include "demo.h"

#define PERF_BASE(n)             (0x30150000 | (0x40 * (n)))
#define PERF_CLEAR(n)            (*(volatile unsigned *)PERF_BASE(n))
#define PERF_MEM_READS(n)        (*(const volatile unsigned *)PERF_BASE(n))
#define PERF_MEM_WRITES(n)       (*(const volatile unsigned *)(PERF_BASE(n) + 4))
#define PERF_MEM_READ_CYCLES(n)  (*(const volatile unsigned *)(PERF_BASE(n) + 8))
#define PERF_MEM_WRITE_CYCLES(n) (*(const volatile unsigned *)(PERF_BASE(n) + 12))
#define PERF_RING_READS(n)       (*(const volatile unsigned *)(PERF_BASE(n) + 16))
#define PERF_RING_INVALS(n)      (*(const volatile unsigned *)(PERF_BASE(n) + 20))
#define PERF_RING_READ_INVALS(n) (*(const volatile unsigned *)(PERF_BASE(n) + 24))
#define PERF_RING_REPLIES(n)     (*(const volatile unsigned *)(PERF_BASE(n) + 28))
#define PERF_RING_FORWARDS(n)    (*(const volatile unsigned *)(PERF_BASE(n) + 32))
#define PERF_RING_CYCLES(n)      (*(const volatile unsigned *)(PERF_BASE(n) + 36))
#define PERF_IO_READS(n)         (*(const volatile unsigned *)(PERF_BASE(n) + 40))
#define PERF_IO_WRITES(n)        (*(const volatile unsigned *)(PERF_BASE(n) + 44))

#define PERF_MIN_MASK  0x0000ffff
#define PERF_MAX_MASK  0xffff0000
#define PERF_MAX_SHIFT 16

void perf_show(unsigned cpu)
{
	print("dumping performance counters for cpu%u", cpu);

	unsigned mem_reads = PERF_MEM_READS(cpu);
	unsigned mem_writes = PERF_MEM_WRITES(cpu);
	unsigned read_cycles = PERF_MEM_READ_CYCLES(cpu);
	unsigned write_cycles = PERF_MEM_WRITE_CYCLES(cpu);
	unsigned ring_reads = PERF_RING_READS(cpu);
	unsigned ring_invals = PERF_RING_INVALS(cpu);
	unsigned ring_read_invals = PERF_RING_READ_INVALS(cpu);
	unsigned ring_replies = PERF_RING_REPLIES(cpu);
	unsigned ring_forwards = PERF_RING_FORWARDS(cpu);
	unsigned ring_cycles = PERF_RING_CYCLES(cpu);
	unsigned io_reads = PERF_IO_READS(cpu);
	unsigned io_writes = PERF_IO_WRITES(cpu);

	unsigned min_ring_cycles = ring_cycles & PERF_MIN_MASK;
	unsigned max_ring_cycles = (ring_cycles & PERF_MAX_MASK) >> PERF_MAX_SHIFT;
	unsigned min_read_cycles = read_cycles & PERF_MIN_MASK;
	unsigned max_read_cycles = (read_cycles & PERF_MAX_MASK) >> PERF_MAX_SHIFT;
	unsigned min_write_cycles = write_cycles & PERF_MIN_MASK;
	unsigned max_write_cycles = (write_cycles & PERF_MAX_MASK) >> PERF_MAX_SHIFT;
	unsigned ring_sends = ring_reads + ring_invals + ring_read_invals;

	print("requests:         sends=%u forwards=%u replies=%u", ring_sends, ring_forwards, ring_replies);
	print("requests sent:    read=%u inval=%u read_inval=%u", ring_reads, ring_invals, ring_read_invals);
	print("memory:           misses=%u writebacks=%u", mem_reads, mem_writes);
	print("uncached i/o:     reads=%u writes=%u", io_reads, io_writes);
	print("ring cycles:      min=%u max=%u", min_ring_cycles, max_ring_cycles);
	print("mem read cycles:  min=%u max=%u", min_read_cycles, max_read_cycles);
	print("mem write cycles: min=%u max=%u", min_write_cycles, max_write_cycles);
}

void perf_clear(unsigned cpu)
{
	PERF_CLEAR(cpu) = 0;
	print("cleared performance counters for cpu%u", cpu);
}
