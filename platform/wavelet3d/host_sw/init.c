#define MOD_NAME "init"

#include <stdlib.h>

#include "gfx.h"
#include "init.h"
#include "log.h"

extern const unsigned char _binary_gfx_fw_bin_start[];
extern const unsigned char _binary_gfx_fw_bin_end;
extern const unsigned char _binary_gfx_fw_bin_size;

static void __attribute__((noreturn)) init_gfx_failed(void)
{
	log("fatal: probe of gfx device failed");
	abort();
}

static void init_gfx(int bootrom)
{
	switch (gfx_probe()) {
		case GFX_PROBE_FAILED:
			init_gfx_failed();
			break;

		case GFX_PROBE_BOOTROM:
			if (bootrom)
				log("gfx bootloader didn't handover to firmware");

			size_t fw_size = (size_t)&_binary_gfx_fw_bin_size;
			if (bootrom || gfx_fw_load(_binary_gfx_fw_bin_start, fw_size) < 0)
				init_gfx_failed();

			init_gfx(1);
			break;

		case GFX_PROBE_FIRMWARE:
			break;
	}
}

void init(void)
{
	log("host cpu is up");
	init_gfx(0);
}
