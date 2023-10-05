#include <stddef.h>

#include "demo.h"

static void bad_input(void)
{
	print("bad input");
}

static int parse_cpu_token(const char *token, unsigned *cpu)
{
	if (token[0] != 'c' || token[1] != 'p' || token[2] != 'u'
	|| !('0' <= token[3] && token[3] < '0' + NUM_CPUS) || token[4]) {
		bad_input();
		return -1;
	}

	*cpu = token[3] - '0';
	return 0;
}

void unexpected_eof(void)
{
	print("unexpected end-of-input");
}

int strcmp(const char *s1, const char *s2)
{
    while (*s1 && *s1 == *s2)
        s1++, s2++;

    return (int)*(const unsigned char *)s1 - (int)*(const unsigned char *)s2;
}

char *strtok_input(char **tokens)
{
	char *start = *tokens;
	while (*start && *start == ' ')
		++start;

	if (!*start) {
		*tokens = start;
		return NULL;
	}

	char *end = start + 1;
	while (*end && *end != ' ')
		++end;

	*tokens = *end ? end + 1 : end;
	*end = '\0';

	return start;
}

int parse_cpu(char **tokens, unsigned *cpu)
{
	char *token = strtok_input(tokens);
	if (!token) {
		unexpected_eof();
		return -1;
	}

	return parse_cpu_token(token, cpu);
}

int parse_cpu_mask(char **tokens, unsigned *mask)
{
	*mask = 0;

	char *token;
	while ((token = strtok_input(tokens))) {
		unsigned cpu;
		if (parse_cpu_token(token, &cpu) < 0)
			return -1;

		*mask |= 1 << cpu;
	}

	if (!*mask) {
		print("must specify at least one cpu");
		return -1;
	}

	return 0;
}

int parse_hex(char **tokens, unsigned *val)
{
	char *token = strtok_input(tokens);
	if (!token) {
		unexpected_eof();
		return -1;
	} else if (token[0] != '0' || token[1] != 'x') {
		bad_input();
		return -1;
	}

	*val = 0;

	char *c = &token[2];
	unsigned nibbles = 0;

	while (*c) {
		*val <<= 4;

		if ('0' <= *c && *c <= '9')
			*val |= *c - '0';
		else if ('a' <= *c && *c <= 'f')
			*val |= *c - 'a' + 10;
		else if ('A' <= *c && *c <= 'F')
			*val |= *c - 'A' + 10;

		++c;
		++nibbles;
	}

	if (!nibbles || nibbles > 8) {
		bad_input();
		return -1;
	}

	return 0;
}

int parse_ptr(char **tokens, void **ptr)
{
	unsigned ptr_val;
	if (parse_hex(tokens, &ptr_val) < 0)
		return -1;

	*ptr = (void *)ptr_val;
	return 0;
}

int parse_aligned(char **tokens, void **ptr)
{
	if (parse_ptr(tokens, ptr) < 0)
		return -1;
	else if ((unsigned)*ptr & 0b11) {
		print("unaligned address: %p", *ptr);
		return -1;
	}

	return 0;
}

int expect_end(char **tokens)
{
	char *token = strtok_input(tokens);
	if (token) {
		print("too many arguments starting from '%s'", token);
		return -1;
	}

	return 0;
}
