interface if_pkts
#(int WIDTH = 32);

	logic              tlast;
	logic              tready;
	logic              tvalid;
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
