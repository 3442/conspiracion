// AXI4 con burst
interface if_axib
#(int WIDTH = 32);

	logic              awvalid,
	                   awready;
	logic[7:0]         awlen;
	logic[1:0]         awburst;
	logic[WIDTH - 1:0] awaddr;

	logic              wlast;
	logic              wvalid;
	logic              wready;
	logic[WIDTH - 1:0] wdata;

	logic bvalid;
	logic bready;

	logic              arvalid,
	                   arready;
	logic[7:0]         arlen;
	logic[1:0]         arburst;
	logic[WIDTH - 1:0] araddr;

	logic              rlast;
	logic              rvalid;
	logic              rready;
	logic[WIDTH - 1:0] rdata;

	modport m
	(
		input  awready,
		       wready,
		       bvalid,
		       arready,
		       rlast,
		       rvalid,
		       rdata,

		output awlen,
		       awburst,
		       awvalid,
		       awaddr,
		       wlast,
		       wvalid,
		       wdata,
		       bready,
		       arlen,
		       arburst,
		       arvalid,
		       araddr,
		       rready
	);

	modport s
	(
		input  awlen,
		       awburst,
		       awvalid,
		       awaddr,
		       wlast,
		       wvalid,
		       wdata,
		       bready,
		       arlen,
		       arburst,
		       arvalid,
		       araddr,
		       rready,

		output awready,
		       wready,
		       bvalid,
		       arready,
		       rlast,
		       rvalid,
		       rdata
	);

endinterface
