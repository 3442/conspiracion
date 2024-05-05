interface gfx_beats
#(int WIDTH = $bits(gfx::word));

	logic[WIDTH - 1:0] data;
	logic              ready;
	logic              valid;

	modport tx
	(
		input  ready,
		output data,
		       valid
	);

	modport rx
	(
		input  data,
		       valid,
		output ready
	);

	modport peek
	(
		input  data,
		       ready,
		       valid
	);

endinterface
