interface gfx_wb;

	import gfx::*;

	word lanes[SHADER_LANES];
	logic ready, scalar, valid, writeback;
	group_id group;
	xgpr_num dest;

	modport tx
	(
		input  ready,

		output dest,
		       group,
		       lanes,
		       valid,
		       scalar,
		       writeback
	);

	modport rx
	(
		input  dest,
		       group,
		       lanes,
		       valid,
		       scalar,
		       writeback,

		output ready
	);


endinterface
