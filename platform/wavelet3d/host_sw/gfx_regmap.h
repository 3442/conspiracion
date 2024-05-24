#ifndef GFX_REGMAP_H
#define GFX_REGMAP_H

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

#define GFX_VRAM_BASE ((void *)0x1c000000)

#endif
