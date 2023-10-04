#include <stddef.h>

#include "demo.h"

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
