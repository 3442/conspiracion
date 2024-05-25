#include "ctrl_map.h"
#include "hostif.h"

unsigned boot_magic;
unsigned boot_hw_rev;

void host_read(struct hostif_ctrl *ctrl)
{
	struct hostif_ar ar;
	if (!(ar = HOSTIF_AR).valid)
		return;

	union ctrl_rdata rdata;
	rdata.word = 0xffffffff;

	switch (ar.addr & 0xff) {
		case CTRL_OFFSET_MAGIC:
			rdata.magic.value = boot_magic;
			break;

		case CTRL_OFFSET_HW_ID:
			rdata.word = boot_hw_rev;
			break;

		case CTRL_OFFSET_FW_ID: {
			rdata.fw_id.year = 0;
			for (unsigned i = 7; i <= 10; ++i) {
				rdata.fw_id.year *= 10;
				rdata.fw_id.year += (unsigned)(__DATE__[i] - '0');
			}

			rdata.fw_id.day = __DATE__[4] != ' ' ? (unsigned)(__DATE__[4] - '0') : 0;
			rdata.fw_id.day += (unsigned)(__DATE__[5] - '0');

			const char months[12][3] = {
				"Jan",
				"Feb",
				"Mar",
				"Apr",
				"May",
				"Jun",
				"Jul",
				"Aug",
				"Sep",
				"Oct",
				"Nov",
				"Dec",
			};

			rdata.fw_id.month = 0;
			for (unsigned i = 0; i < sizeof months / sizeof months[0]; ++i)
				if (__DATE__[0] == months[i][0]
				 && __DATE__[1] == months[i][1]
				 && __DATE__[2] == months[i][2]) {
					rdata.fw_id.month = i + 1;
					break;
				}

			rdata.fw_id.build = 1;
			rdata.fw_id.rsvd31 = 0;
			break;
		}

		case CTRL_OFFSET_HOSTIF_ID:
			rdata.hostif_id.rev = HOSTIF_REV_V1;
			break;
	}

	HOSTIF_R.data = rdata.word;
	while (!(*ctrl = HOSTIF_CTRL).rdone);
}

void host_write(struct hostif_ctrl *ctrl)
{
	struct hostif_aw aw;
	if (!(aw = HOSTIF_AW).valid)
		return;

	union ctrl_wdata wdata;
	wdata.word = HOSTIF_W.data;

	switch (aw.addr & 0xff) {
	}

	HOSTIF_B = (struct hostif_b){ .valid = 1, .rsvd1 = 0 };
	while (!(*ctrl = HOSTIF_CTRL).bdone);
}

int main(unsigned magic, unsigned hw_rev)
{
	boot_magic = magic;
	boot_hw_rev = hw_rev;

	while (1) {
		struct hostif_ctrl ctrl = HOSTIF_CTRL;

		if (ctrl.arvalid)
			host_read(&ctrl);

		if (ctrl.awvalid && ctrl.wvalid)
			host_write(&ctrl);
	}
}
