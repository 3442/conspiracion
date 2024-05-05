interface gfx_shader_setup
import gfx::*;;

	struct
	{
		group_id  group;
		word_ptr  pc;
		xgpr_num  gpr;
		word      gpr_value;
		lane_mask mask;
		logic     pc_set,
		          gpr_set,
		          mask_set;
	} write;

	struct
	{
		logic gpr,
		      mask,
		      submit;
	} set_done;

	modport core
	(
		input  write,

		output set_done
	);

	modport sched
	(
		input  set_done,

		output write
	);

endinterface
