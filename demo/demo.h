#ifndef DEMO_H
#define DEMO_H

#define NUM_CPUS 4

struct lock
{
	volatile unsigned val;
};

struct cpu
{
	unsigned num;
};

/* R12 está reservado por la ABI
 * https://gcc.gnu.org/onlinedocs/gcc/Global-Register-Variables.html
 */
register struct cpu *this_cpu asm("ip");

void spin_init(struct lock *lock);
void spin_lock(struct lock *lock, unsigned *irq_save);
void spin_unlock(struct lock *lock, unsigned irq_save);

void console_init(void);
void print(const char *fmt, ...);

int cpus_ready(void);
void run_cpu(unsigned num);
void run_cpus(unsigned mask);
void halt_cpu(unsigned num);
void halt_cpus(unsigned mask);

#endif
