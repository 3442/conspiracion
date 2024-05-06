interface if_beats
#(int WIDTH = 32);

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
