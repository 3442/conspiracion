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
void read_line(char *vuf, unsigned size);

int cpus_ready(void);
void run_cpu(unsigned num);
void run_cpus(unsigned mask);
void halt_cpu(unsigned num);
void halt_cpus(unsigned mask);

int strcmp(const char *s1, const char *s2);
char *strtok_input(char **tokens);

int expect_end(char **tokens);

int parse_hex(char **tokens, unsigned *val);
int parse_ptr(char **tokens, void **ptr);
int parse_aligned(char **tokens, void **ptr);

int parse_cpu(char **tokens, unsigned *cpu);
int parse_cpu_mask(char **tokens, unsigned *mask);

void cache_debug(unsigned cpu, void *ptr);

#endif
