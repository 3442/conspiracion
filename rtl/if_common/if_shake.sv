interface if_shake;

	logic ready;
	logic valid;

	modport tx
	(
		input  ready,
		output valid
	);

	modport rx
	(
		input  valid,
		output ready
	);

	modport peek
	(
		input  ready,
		       valid
	);

endinterface
