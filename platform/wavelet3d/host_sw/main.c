#include <stdio.h>

struct gfx_hw_id
{
	unsigned patch : 8;
	unsigned minor : 8;
	unsigned major : 8;
	unsigned rsvd  : 8;
};

struct gfx_fw_id
{
	unsigned build : 10;
	unsigned day   : 5;
	unsigned month : 4;
	unsigned year  : 12;
	unsigned rsvd  : 1;
};

#define GFX_CTRL_BASE       0x20000000
#define GFX_CTRL_MAGIC      (*(volatile unsigned *)(GFX_CTRL_BASE + 0x00))
#define GFX_CTRL_HW_ID      (*(volatile struct gfx_hw_id *)(GFX_CTRL_BASE + 0x04))
#define GFX_CTRL_FW_ID      (*(volatile struct gfx_fw_id *)(GFX_CTRL_BASE + 0x08))
#define GFX_CTRL_HOSTIF_REV (*(volatile unsigned *)(GFX_CTRL_BASE + 0x0c))

#define GFX_MAGIC_ID 0x4a7a7b0c

int main()
{
	printf("gfx: probing 0x%08x\n", GFX_CTRL_BASE);

	unsigned magic = GFX_CTRL_MAGIC;
	printf("gfx: magic=0x%08x\n", magic);

	if (magic != GFX_MAGIC_ID)
		printf("gfx: bad magic, probe failed\n");
	
	printf("gfx: magic ok\n");

	struct gfx_hw_id hw_id = GFX_CTRL_HW_ID;
	struct gfx_fw_id fw_id = GFX_CTRL_FW_ID;
	unsigned hostif_rev = GFX_CTRL_HOSTIF_REV;

	printf
	(
		"gfx: 3D graphics accelerator IP core v%u.%u.%u\n",
		hw_id.major, hw_id.minor, hw_id.patch
	);

	switch (hostif_rev) {
		case 0:
			printf("gfx: scheduler is in bootloader rom\n");
			break;

		case 1:
			printf("gfx: detected regmap revision %u\n", hostif_rev);
			break;

		default:
			printf("gfx: unknown regmap revision %u\n", hostif_rev);
			break;
	}

	printf
	(
		"gfx: %s rev %u.%u.%02u #%02u\n",
		hostif_rev ? "firmware" : "bootloader",
		fw_id.year, fw_id.month, fw_id.day, fw_id.build
	);

	return 0;
}
