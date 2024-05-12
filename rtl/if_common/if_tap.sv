interface if_tap;

	logic tck, tms, tdi, tdo;

	modport m
	(
		input  tdo,

		output tck,
		       tms,
		       tdi
	);

	modport s
	(
		input  tck,
		       tms,
		       tdi,

		output tdo
	);

endinterface
