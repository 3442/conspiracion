#ifndef GFX_H
#define GFX_H

enum gfx_probe_result
{
	GFX_PROBE_BOOTROM,
	GFX_PROBE_FIRMWARE,
	GFX_PROBE_FAILED,
};

enum gfx_probe_result gfx_probe(void);
int                   gfx_fw_load(const void *image, size_t image_len);

#endif
