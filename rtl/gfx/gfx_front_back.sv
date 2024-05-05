interface gfx_front_back
import gfx::*;;

	struct
	{
		wave_exec wave;
		fpint_op  p0;
		mem_op    p1;
		sfu_op    p2;
		group_op  p3;
	} execute;

	struct
	{
		logic    valid;
		group_id group;
	} loop;

	shader_dispatch dispatch;

	modport front
	(
		input  loop,

		output execute,
		       dispatch
	);

	modport back
	(
		input  execute,
		       dispatch,

		output loop
	);

endinterface
