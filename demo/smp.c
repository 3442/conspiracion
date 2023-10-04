#include "demo.h"

#define SMP_CTRL_BASE 0x30140000
#define SMP_CTRL      (*(volatile unsigned *)SMP_CTRL_BASE)

int cpus_ready(void)
{
	return SMP_CTRL == 0;
}

void run_cpu(unsigned num)
{
	run_cpus(1 << num);
}

void run_cpus(unsigned mask)
{
	unsigned ctrl_word = 0;
	for (unsigned cpu = 0; cpu < NUM_CPUS; ++cpu)
		if (mask & (1 << cpu)) {
			print("run cpu%u", cpu);
			ctrl_word |= 0b001 << (cpu * 8);
		}

	SMP_CTRL = ctrl_word;
}

void halt_cpu(unsigned num)
{
	halt_cpu(1 << num);
}

void halt_cpus(unsigned mask)
{
	unsigned ctrl_word = 0;
	for (unsigned cpu = 0; cpu < NUM_CPUS; ++cpu)
		if (mask & (1 << cpu)) {
			print("halt cpu%u%s", cpu, cpu == this_cpu->num ? " (myself)" : "");
			ctrl_word |= 0b010 << (cpu * 8);
		}

	SMP_CTRL = ctrl_word;
}
