interface gfx_regfile_io;

	import gfx::*;

	struct
	{
		group_id    group;
		sgpr_num    a_sgpr,
		            b_sgpr;
		vgpr_num    a_vgpr,
		            b_vgpr;
		logic[12:0] b_imm;
		logic       a_scalar,
		            b_scalar,
		            b_is_imm,
		            b_is_const,
		            scalar_rev;
	} op;

	struct
	{
		logic    write;
		group_id group;
		sgpr_num sgpr;
		word     data;
	} sgpr_write;

	struct
	{
		lane_mask mask;
		group_id  group;
		vgpr_num  vgpr;
		word      data[SHADER_LANES];
	} vgpr_write;

	word a[SHADER_LANES], b[SHADER_LANES], sgpr_write_data, vgpr_write_data[SHADER_LANES];
	logic mask_wb_write, pc_wb_write;
	word_ptr pc_back, pc_front, pc_wb;
	group_id mask_back_group, mask_wb_group, pc_back_group, pc_front_group, pc_wb_group;
	lane_mask mask_back, mask_wb;

	modport ab
	(
		input  a,
		       b
	);

	modport read
	(
		output op
	);

	modport bind_
	(
		input  pc_front,

		output pc_front_group
	);

	modport wb
	(
		input  pc_back,
		       mask_back,

		output sgpr_write,
		       vgpr_write,

		       pc_back_group,
		       mask_back_group,

		       pc_wb,
		       pc_wb_group,
		       pc_wb_write,

		       mask_wb,
		       mask_wb_group,
		       mask_wb_write
	);

	modport regs
	(
		input  op,
		       sgpr_write,
		       vgpr_write,

		       pc_back_group,
		       pc_front_group,
		       mask_back_group,

		       pc_wb,
		       pc_wb_group,
		       pc_wb_write,

		       mask_wb,
		       mask_wb_group,
		       mask_wb_write,

		output a,
		       b,

		       pc_back,
		       pc_front,
		       mask_back
	);

endinterface
