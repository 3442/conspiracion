struct hostif_ctrl
{
	unsigned arint   : 1;
	unsigned awint   : 1;
	unsigned rsvd2   : 6;
	unsigned arvalid : 1;
	unsigned awvalid : 1;
	unsigned rdone   : 1;
	unsigned wvalid  : 1;
	unsigned bdone   : 1;
	unsigned rsvd13  : 19;
};

struct hostif_ar
{
	unsigned valid : 1;
	unsigned rsvd1 : 1;
	unsigned addr  : 30;
};

struct hostif_aw
{
	unsigned valid : 1;
	unsigned rsvd1 : 1;
	unsigned addr  : 30;
};

struct hostif_r
{
	unsigned data : 32;
};

struct hostif_w
{
	unsigned data : 32;
};

struct hostif_b0
{
	unsigned valid : 1;
	unsigned rsvd1 : 31;
};

#define HOSTIF_BASE 0x00300000
#define HOSTIF_CTRL (*(volatile struct hostif_ctrl *)(HOSTIF_BASE + 0x00))
#define HOSTIF_AR   (*(volatile struct hostif_ar *)  (HOSTIF_BASE + 0x04))
#define HOSTIF_AW   (*(volatile struct hostif_aw *)  (HOSTIF_BASE + 0x08))
#define HOSTIF_R    (*(volatile struct hostif_r *)   (HOSTIF_BASE + 0x0c))
#define HOSTIF_W    (*(volatile struct hostif_w *)   (HOSTIF_BASE + 0x10))
#define HOSTIF_B    (*(volatile struct hostif_b *)   (HOSTIF_BASE + 0x14))

int main(unsigned magic, unsigned hw_rev)
{
	while (1) {
		struct hostif_ar ar;
		while (!(ar = HOSTIF_AR).valid);

		switch (ar.addr & 3) {
			case 0b00:
				HOSTIF_R.data = magic;
				break;

			case 0b01:
				HOSTIF_R.data = hw_rev;
				break;

			case 0b10:
				HOSTIF_R.data = hw_rev;
				break;

			case 0b11:
				HOSTIF_R.data = 1;
				break;
		}

		while (!HOSTIF_CTRL.rdone);
	}
}
