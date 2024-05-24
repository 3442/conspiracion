#define MOD_NAME "gfx"

#include <stdio.h>

#include "gfx.h"
#include "gfx_regmap.h"
#include "log.h"
#include "sgdma.h"

enum gfx_probe_result gfx_probe(void)
{
	log("probing 0x%08x", GFX_CTRL_BASE);

	unsigned magic = GFX_CTRL_MAGIC;
	log("magic=0x%08x", magic);

	if (magic != GFX_MAGIC_ID) {
		log("bad magic");
		return GFX_PROBE_FAILED;
	}
	
	log("magic ok");

	struct gfx_hw_id hw_id = GFX_CTRL_HW_ID;
	struct gfx_fw_id fw_id = GFX_CTRL_FW_ID;
	unsigned hostif_rev = GFX_CTRL_HOSTIF_REV;

	log
	(
		"3D graphics accelerator IP core v%u.%u.%u",
		hw_id.major, hw_id.minor, hw_id.patch
	);

	log
	(
		"%s rev %u.%u.%02u #%02u",
		hostif_rev ? "firmware" : "bootloader",
		fw_id.year, fw_id.month, fw_id.day, fw_id.build
	);

	switch (hostif_rev) {
		case 0:
			log("scheduler is in bootloader rom");
			return GFX_PROBE_BOOTROM;

		case 1:
			log("found regmap revision %u", hostif_rev);
			return GFX_PROBE_FIRMWARE;

		default:
			log("unknown regmap revision %u", hostif_rev);
			return GFX_PROBE_FAILED;
	}
}

int gfx_fw_load(const void *image, size_t image_len)
{
	log("uploading fw image (len=%zu)", image_len);

	sgdma_memcpy(GFX_VRAM_BASE, image, image_len);
	sgdma_barrier();

	*(void *volatile *)&GFX_CTRL_FW_ID = GFX_VRAM_BASE;
	return 0;
}
