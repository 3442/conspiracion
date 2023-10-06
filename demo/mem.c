#include "demo.h"

void do_read(void *ptr)
{
	print("%p -> %x", ptr, *(volatile unsigned *)ptr);
}

void do_write(void *ptr, unsigned val)
{
	*(volatile unsigned *)ptr = val;
	print("%p <- %x", ptr, val);
}

void remote_send(unsigned cpu, void *ptr, int write, unsigned val)
{
	unsigned long ptr_val = (unsigned)ptr & ~0b11;
	unsigned long long send_word = ((unsigned long long)ptr_val | (write & 1) << 1 | 1) << 32 | val;

	unsigned long long current = all_cpus[cpu].mailbox;
	while (!compare_exchange_64(&all_cpus[cpu].mailbox, &current, send_word));
}

void remote_recv(void **ptr, int *write, unsigned *val)
{
	unsigned long long current = this_cpu->mailbox;
	while (!compare_exchange_64(&this_cpu->mailbox, &current, 0) || !current);

	*val = (unsigned long)current;
	*ptr = (void *)((unsigned)((current >> 32) & ~0b11));
	*write = (current >> 33) & 1;
}
