#ifndef LOG_H
#define LOG_H

#include <stdio.h>

#ifdef MOD_NAME
	#define log(fmt, ...) printf(MOD_NAME ": " fmt "\n", ##__VA_ARGS__)
#else
	#define log(fmt, ...) printf(fmt "\n", ##__VA_ARGS__)
#endif

#endif
