#define MOD_NAME "vdc"

#include "log.h"
#include "vdc.h"

struct vdc_ctrl
{
	unsigned dacen      : 1;
	unsigned dacon      : 1;
	unsigned doublebuff : 1;
	unsigned rsvd3      : 29;
};

struct vdc_geometry
{
	unsigned lines  : 16;
	unsigned length : 16;
};

struct vdc_stream
{
	unsigned hstride : 16;
	unsigned rsvd16  : 16;
};

struct vdc_fb
{
	unsigned rsvd0 : 2;
	unsigned addr  : 30;
};

#define VDC_BASE     0x24000000
#define VDC_CTRL     (*(volatile struct vdc_ctrl *)    (VDC_BASE + 0x00))
#define VDC_GEOMETRY (*(volatile struct vdc_geometry *)(VDC_BASE + 0x04))
#define VDC_STREAM   (*(volatile struct vdc_stream *)  (VDC_BASE + 0x08))
#define VDC_FRONT    (*(volatile struct vdc_fb *)      (VDC_BASE + 0x0c))
#define VDC_BACK     (*(volatile struct vdc_fb *)      (VDC_BASE + 0x10))
#define VDC_RETIRE   (*(volatile struct vdc_fb *)      (VDC_BASE + 0x14))

#define FB_BASE ((void *)0x1d000000)

void vdc_init(void)
{
	log("fb init, vdc_on=%u", VDC_CTRL.dacon);

	log("fb done");

	VDC_FRONT = (struct vdc_fb){ .addr = (unsigned)FB_BASE >> 2, .rsvd0 = 0, };
	VDC_STREAM = (struct vdc_stream){ .hstride = 512, .rsvd16 = 0, };
	VDC_GEOMETRY = (struct vdc_geometry){ .length = 479, .lines = 479, };
	VDC_CTRL = (struct vdc_ctrl){ .dacen = 1, .dacon = 0, .doublebuff = 0, };

	log("init done, vdc_on=%u", VDC_CTRL.dacon);
}
