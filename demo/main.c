#include "demo.h"

struct cpu all_cpus[NUM_CPUS];
struct cpu *__cpus[] = { &all_cpus[0], &all_cpus[1], &all_cpus[2], &all_cpus[3] };

static volatile unsigned boot_done;

static void unknown_command(const char *cmd)
{
	print("unknown command '%s'", cmd);
}

static void cmd_run(char **tokens)
{
	unsigned mask;
	if (parse_cpu_mask(tokens, &mask) < 0)
		return;

	run_cpus(mask);
}

static void cmd_halt(char **tokens)
{
	unsigned mask;
	if (parse_cpu_mask(tokens, &mask) < 0)
		return;

	halt_cpus(mask);
}

static void cmd_read(char **tokens)
{
	void *ptr;
	if (parse_aligned(tokens, &ptr) < 0 || expect_end(tokens) < 0)
		return;

	do_read(ptr);
}

static void cmd_write(char **tokens)
{
	void *ptr;
	unsigned val;

	if (parse_aligned(tokens, &ptr) < 0 || parse_hex(tokens, &val) < 0 || expect_end(tokens) < 0)
		return;

	do_write(ptr, val);
}

static void cmd_cache(char **tokens)
{
	void *ptr;
	unsigned cpu;

	if (parse_cpu(tokens, &cpu) < 0 || parse_ptr(tokens, &ptr) < 0)
		return;

	cache_debug(cpu, ptr);
}

static void cmd_perf(char **tokens)
{
	unsigned cpu;
	const char *cmd;

	if (parse_cpu(tokens, &cpu) < 0)
		return;
	else if (!(cmd = strtok_input(tokens))) {
		unexpected_eof();
		return;
	} else if (expect_end(tokens) < 0)
		return;

	if (!strcmp(cmd, "clear"))
		perf_clear(cpu);
	else if (!strcmp(cmd, "show"))
		perf_show(cpu);
	else
		unknown_command(cmd);
}

static void cmd_remote_read(char **tokens, unsigned cpu)
{
	void *ptr;
	if (parse_aligned(tokens, &ptr) < 0 || expect_end(tokens) < 0)
		return;

	remote_send(cpu, ptr, 0, 0);
}

static void cmd_remote_write(char **tokens, unsigned cpu)
{
	void *ptr;
	unsigned val;

	if (parse_aligned(tokens, &ptr) < 0 || parse_hex(tokens, &val) < 0 || expect_end(tokens) < 0)
		return;

	remote_send(cpu, ptr, 1, val);
}

static void cmd_remote(char **tokens)
{
	unsigned cpu;
	const char *cmd;

	if (parse_cpu(tokens, &cpu) < 0)
		return;
	else if (cpu == 0) {
		print("cannot send remote cmd to bsp");
		return;
	} else if (!(cmd = strtok_input(tokens))) {
		unexpected_eof();
		return;
	}

	if (!strcmp(cmd, "read"))
		cmd_remote_read(tokens, cpu);
	else if (!strcmp(cmd, "write"))
		cmd_remote_write(tokens, cpu);
	else
		unknown_command(cmd);
}

static void kick_cpus(void)
{
	for (unsigned i = this_cpu->num + 1; i < NUM_CPUS; ++i) {
		if (cpu_is_alive(i)) {
			run_cpu(i);
			return;
		}

		print("cpu%u is dead", i);
	}

	boot_done = 1;
}

static void bsp_main(void)
{
	for (struct cpu *cpu = all_cpus; cpu < all_cpus + NUM_CPUS; ++cpu)
		cpu->mailbox = 0;

	boot_done = 0;
	kick_cpus();

	while (!boot_done);
	print("booted %u cpus", NUM_CPUS);

	while (1) {
		char input[64];
		read_line(input, sizeof input);

		char *tokens = input;

		char *cmd = strtok_input(&tokens);
		if (!cmd)
			continue;

		if (!strcmp(cmd, "run"))
			cmd_run(&tokens);
		else if (!strcmp(cmd, "halt"))
			cmd_halt(&tokens);
		else if (!strcmp(cmd, "read"))
			cmd_read(&tokens);
		else if (!strcmp(cmd, "write"))
			cmd_write(&tokens);
		else if (!strcmp(cmd, "cache"))
			cmd_cache(&tokens);
		else if (!strcmp(cmd, "perf"))
			cmd_perf(&tokens);
		else if (!strcmp(cmd, "remote"))
			cmd_remote(&tokens);
		else
			unknown_command(cmd);
	}
}

static void ap_main(void)
{
	kick_cpus();
	halt_cpu(this_cpu->num);

	while (1) {
		int write;
		void *ptr;
		unsigned val;

		remote_recv(&ptr, &write, &val);

		if (write)
			do_write(ptr, val);
		else
			do_read(ptr);
	}
}

void reset(void)
{
	if (this_cpu->num == 0)
		console_init();

	print("exited reset");

	if (this_cpu->num == 0)
		bsp_main();
	else
		ap_main();
}
