// AXI4-Lite, sin wstrb ni axprot
interface gfx_axil;
	import gfx::*;

	logic awvalid;
	logic awready;
	word  awaddr;

	logic wvalid;
	logic wready;
	word  wdata;

	logic bvalid;
	logic bready;

	logic arvalid;
	logic arready;
	word  araddr;

	logic rvalid;
	logic rready;
	word  rdata;

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
