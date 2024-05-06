// AXI4 full modulo prot, cache, lock, QoS, region
interface if_axib
#(int ADDR_WIDTH = 32,
  int DATA_WIDTH = 32,
  int ID_WIDTH   = 8);

	logic                   awvalid,
	                        awready;
	logic[ID_WIDTH - 1:0]   awid;
	logic[7:0]              awlen;
	logic[2:0]              awsize;
	logic[1:0]              awburst;
	logic[ADDR_WIDTH - 1:0] awaddr;

	logic                             wvalid;
	logic                             wready;
	logic[DATA_WIDTH - 1:0]           wdata;
	logic                             wlast;
	logic[(DATA_WIDTH + 7) / 8 - 1:0] wstrb;

	logic                 bvalid;
	logic                 bready;
	logic[ID_WIDTH - 1:0] bid;
	logic[1:0]            bresp;

	logic                   arvalid,
	                        arready;
	logic[ID_WIDTH - 1:0]   arid;
	logic[7:0]              arlen;
	logic[2:0]              arsize;
	logic[1:0]              arburst;
	logic[ADDR_WIDTH - 1:0] araddr;

	logic                   rvalid;
	logic                   rready;
	logic[ID_WIDTH - 1:0]   rid;
	logic[DATA_WIDTH - 1:0] rdata;
	logic[1:0]              rresp;
	logic                   rlast;

	modport m
	(
		input  awready,

		       wready,

		       bid,
		       bresp,
		       bvalid,

		       arready,

		       rid,
		       rdata,
		       rlast,
		       rresp,
		       rvalid,

		output awid,
		       awlen,
		       awaddr,
		       awsize,
		       awburst,
		       awvalid,

		       wdata,
		       wlast,
		       wstrb,
		       wvalid,

		       bready,

		       arid,
		       arlen,
		       araddr,
		       arsize,
		       arburst,
		       arvalid,

		       rready
	);

	modport s
	(
		input  awid,
		       awlen,
		       awaddr,
		       awsize,
		       awburst,
		       awvalid,

		       wdata,
		       wlast,
		       wstrb,
		       wvalid,

		       bready,

		       arid,
		       arlen,
		       araddr,
		       arsize,
		       arburst,
		       arvalid,

		       rready,

		output awready,

		       wready,

		       bid,
		       bresp,
		       bvalid,

		       arready,

		       rid,
		       rdata,
		       rlast,
		       rresp,
		       rvalid
	);

endinterface
