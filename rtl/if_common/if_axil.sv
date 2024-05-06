// AXI4-Lite, sin wstrb ni axprot
interface if_axil
#(int WIDTH = 32);

	logic              awvalid;
	logic              awready;
	logic[WIDTH - 1:0] awaddr;

	logic              wvalid;
	logic              wready;
	logic[WIDTH - 1:0] wdata;

	logic bvalid;
	logic bready;

	logic              arvalid;
	logic              arready;
	logic[WIDTH - 1:0] araddr;

	logic              rvalid;
	logic              rready;
	logic[WIDTH - 1:0] rdata;

	modport m
	(
		input  awready,
		       wready,
		       bvalid,
		       arready,
		       rvalid,
		       rdata,

		output awvalid,
		       awaddr,
		       wvalid,
		       wdata,
		       bready,
		       arvalid,
		       araddr,
		       rready
	);

	modport s
	(
		input  awvalid,
		       awaddr,
		       wvalid,
		       wdata,
		       bready,
		       arvalid,
		       araddr,
		       rready,

		output awready,
		       wready,
		       bvalid,
		       arready,
		       rvalid,
		       rdata
	);
endinterface
