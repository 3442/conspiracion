interface gfx_wb;

	import gfx::*;

	word lanes[SHADER_LANES];
	logic mask_update, pc_inc, pc_update, ready, scalar, valid, writeback;
	group_id group;
	xgpr_num dest;
	lane_mask mask;
	pc_offset pc_add;

	modport tx
	(
		input  ready,

		output dest,
		       group,
		       lanes,
		       valid,
		       scalar,
		       writeback,

		       mask,
		       mask_update,

		       pc_add,
		       pc_inc,
		       pc_update
	);

	modport rx
	(
		input  dest,
		       group,
		       lanes,
		       valid,
		       scalar,
		       writeback,

		       mask,
		       mask_update,

		       pc_add,
		       pc_inc,
		       pc_update,

		output ready
	);


endinterface
