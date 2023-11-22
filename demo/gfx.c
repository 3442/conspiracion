#include <stdarg.h>
#include <stddef.h>

#include "demo.h"
#include "float16.h"

#define GFX_VRAM_BASE 0x38000000
#define GFX_CMD_BASE  0x3c000000

#define GFX_CMD_SCAN        (*(volatile unsigned *)(GFX_CMD_BASE + 4))
#define GFX_CMD_HEADER_BASE (*(volatile unsigned *)(GFX_CMD_BASE + 8))
#define GFX_CMD_HEADER_SIZE (*(volatile unsigned *)(GFX_CMD_BASE + 12))
#define GFX_CMD_FB_BASE_A   (*(volatile unsigned *)(GFX_CMD_BASE + 16))
#define GFX_CMD_FB_BASE_B   (*(volatile unsigned *)(GFX_CMD_BASE + 20))

#define FB_BASE_A   0x000000
#define FB_BASE_B   0x200000
#define HEADER_BASE 0x400000
#define HEADER_SIZE (1 - 1)
#define CODE_BASE   0x500000
#define DATA_BASE   0x600000

#define VRAM_HEADER_CODE_BASE ((unsigned *)(GFX_VRAM_BASE + HEADER_BASE + 0))
#define VRAM_HEADER_CODE_SIZE ((unsigned *)(GFX_VRAM_BASE + HEADER_BASE + 4))
#define VRAM_HEADER_DATA_BASE ((unsigned *)(GFX_VRAM_BASE + HEADER_BASE + 8))
#define VRAM_HEADER_DATA_SIZE ((unsigned *)(GFX_VRAM_BASE + HEADER_BASE + 12))

#define VRAM_CODE ((unsigned *)(GFX_VRAM_BASE + CODE_BASE))
#define VRAM_DATA ((short *)(GFX_VRAM_BASE + DATA_BASE))

static int swap_buffers;
static unsigned clear_color;
static unsigned data_size;

extern const unsigned char _binary_obj_conspiracion_demo_gfx_rom_bin_end[];
extern const unsigned char _binary_obj_conspiracion_demo_gfx_rom_bin_start[];

static void gfx_write_scan(int do_clear)
{
	unsigned word = 0x02000000;

	word |= clear_color;
	if (swap_buffers)
		word |= 0x01000000;

	if (do_clear)
		word |= 0x04000000;

	GFX_CMD_SCAN = word;
}

void gfx_init(void)
{
	data_size = 0;
	clear_color = 0;
	swap_buffers = 0;
	gfx_write_scan(1);

	GFX_CMD_FB_BASE_A = FB_BASE_A;
	GFX_CMD_FB_BASE_B = FB_BASE_B;
	GFX_CMD_HEADER_BASE = HEADER_BASE;

	const unsigned char *start = _binary_obj_conspiracion_demo_gfx_rom_bin_start;
	unsigned length = (unsigned)&_binary_obj_conspiracion_demo_gfx_rom_bin_end[0] - (unsigned)start;

	print("gfx: loading %u bytes program at %p", length, start);
	for (unsigned i = 0; i < length / 4; ++i) {
		unsigned word
			= (unsigned)start[4 * i]
			| (unsigned)start[4 * i + 1] << 8
			| (unsigned)start[4 * i + 2] << 16
			| (unsigned)start[4 * i + 3] << 24;

		VRAM_CODE[i] = word;
	}

	*VRAM_HEADER_CODE_BASE = CODE_BASE;
	*VRAM_HEADER_CODE_SIZE = length / 4 - 1;
	*VRAM_HEADER_DATA_BASE = DATA_BASE;
	*VRAM_HEADER_DATA_SIZE = 0;
}

void gfx_clear(void)
{
	data_size = 0;
	*VRAM_HEADER_DATA_SIZE = 0;
	gfx_write_scan(1);
}

void gfx_swap(void)
{
	swap_buffers = !swap_buffers;
	gfx_write_scan(0);
}

void gfx_draw(void)
{
	GFX_CMD_HEADER_SIZE = HEADER_SIZE;
}

void gfx_bg(unsigned color)
{
	clear_color = color;
	gfx_write_scan(0);
}

void gfx_data(unsigned block, unsigned lane, short data[static 4])
{
	unsigned vec_num = block << 2 | lane;
	for (unsigned i = 0; i < 4; ++i)
		VRAM_DATA[vec_num << 2 | i] = data[i];

	if (vec_num + 1 > data_size) {
		data_size = vec_num + 1;
		*VRAM_HEADER_DATA_SIZE = data_size;
	}
}
