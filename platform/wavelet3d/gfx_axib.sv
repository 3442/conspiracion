// AXI4 con burst
interface gfx_axib;

	import gfx::word;

	logic      awvalid,
	           awready;
	logic[7:0] awlen;
	logic[1:0] awburst;
	word       awaddr;

	logic wlast;
	logic wvalid;
	logic wready;
	word  wdata;

	logic bvalid;
	logic bready;

	logic      arvalid,
	           arready;
	logic[7:0] arlen;
	logic[1:0] arburst;
	word       araddr;

	logic rlast;
	logic rvalid;
	logic rready;
	word  rdata;

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
