#ifndef DEMO_H
#define DEMO_H

#define NUM_CPUS 4

struct __attribute__((aligned(16))) lock
{
	volatile unsigned val;
};

extern struct __attribute__((aligned(16))) cpu
{
	         unsigned           num;
	volatile unsigned long long mailbox;
} all_cpus[NUM_CPUS];

/* Esto viola la ABI, pero no importa porque no dependemos de bibliotecas
 * https://gcc.gnu.org/onlinedocs/gcc/Global-Register-Variables.html
 */
register struct cpu *this_cpu asm("r9");

void spin_init(struct lock *lock);
void spin_lock(struct lock *lock, unsigned *irq_save);
void spin_unlock(struct lock *lock, unsigned irq_save);

void console_init(void);
void print(const char *fmt, ...);
void read_line(char *buf, unsigned size);

void run_cpu(unsigned num);
void run_cpus(unsigned mask);
void halt_cpu(unsigned num);
void halt_cpus(unsigned mask);

int strcmp(const char *s1, const char *s2);
char *strtok_input(char **tokens);

int expect_end(char **tokens);
void unexpected_eof();

int parse_hex(char **tokens, unsigned *val);
int parse_ptr(char **tokens, void **ptr);
int parse_aligned(char **tokens, void **ptr);

int parse_cpu(char **tokens, unsigned *cpu);
int parse_cpu_mask(char **tokens, unsigned *mask);

void cache_debug(unsigned cpu, void *ptr);

void perf_show(unsigned cpu);
void perf_clear(unsigned cpu);

void do_read(void *ptr);
void do_write(void *ptr, unsigned val);
void remote_send(unsigned cpu, void *ptr, int write, unsigned val);
void remote_recv(void **ptr, int *write, unsigned *val);

int compare_exchange_64(volatile unsigned long long *p, unsigned long long *old, unsigned long long val);

#endif
