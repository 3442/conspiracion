#ifndef CTRL_MAP_H
#define CTRL_MAP_H

#define CTRL_OFFSET_MAGIC     0x00
#define CTRL_OFFSET_HW_ID     0x01
#define CTRL_OFFSET_FW_ID     0x02
#define CTRL_OFFSET_HOSTIF_ID 0x03

union ctrl_rdata
{
	unsigned word;

	struct
	{
		unsigned value;
	} magic;

	struct
	{
		unsigned patch  : 8;
		unsigned minor  : 8;
		unsigned major  : 8;
		unsigned rsvd24 : 8;
	} hw_id;

	struct
	{
		unsigned build  : 10;
		unsigned day    : 5;
		unsigned month  : 4;
		unsigned year   : 12;
		unsigned rsvd31 : 1;
	} fw_id;

	struct
	{
		enum
		{
			HOSTIF_REV_BOOT,
			HOSTIF_REV_V1,
		} rev;
	} hostif_id;
};

union ctrl_wdata
{
	unsigned word;
};

#endif
