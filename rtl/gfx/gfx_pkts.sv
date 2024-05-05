interface gfx_pkts
#(parameter int WIDTH = $bits(gfx::word));

	import gfx::*;

	logic tlast;
	logic tready;
	logic tvalid;
	logic[WIDTH - 1:0] tdata;

	modport tx
	(
		input  tready,

		output tdata,
			   tlast,
			   tvalid
	);

	modport rx
	(
		input  tdata,
			   tlast,
			   tvalid,

		output tready
	);

endinterface
