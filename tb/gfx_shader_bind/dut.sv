module dut
import gfx::*;
(
	input  logic      clk,
	                  rst_n,

	output logic      mem_AWVALID,
	input  logic      mem_AWREADY,
	output logic[7:0] mem_AWID,
	output logic[7:0] mem_AWLEN,
	output logic[2:0] mem_AWSIZE,
	output logic[2:0] mem_AWPROT,
	output logic[1:0] mem_AWBURST,
	output word       mem_AWADDR,

	output logic      mem_WVALID,
	input  logic      mem_WREADY,
	output word       mem_WDATA,
	output logic      mem_WLAST,
	output logic[3:0] mem_WSTRB,

	input  logic      mem_BVALID,
	output logic      mem_BREADY,
	input  logic[7:0] mem_BID,
	input  logic[1:0] mem_BRESP,

	output logic      mem_ARVALID,
	input  logic      mem_ARREADY,
	output logic[7:0] mem_ARID,
	output logic[7:0] mem_ARLEN,
	output logic[2:0] mem_ARSIZE,
	output logic[2:0] mem_ARPROT,
	output logic[1:0] mem_ARBURST,
	output word       mem_ARADDR,

	input  logic      mem_RVALID,
	output logic      mem_RREADY,
	input  logic[7:0] mem_RID,
	input  word       mem_RDATA,
	input  logic[1:0] mem_RRESP,
	input  logic      mem_RLAST,

	input  logic      icache_flush,

	input  logic      loop_valid,
	input  group_id   loop_group,

	input  word_ptr   pc_front_pc,
	output group_id   pc_front_group,

	output logic      wave_valid,
	                  wave_retry,
	output group_id   wave_group,
	output word       wave_insn,

	output logic      runnable_in_ready,
	                  runnable_out_valid,
	output group_id   runnable_out_data
);

	if_axib mem();
	gfx_front_back front_back();
	gfx_regfile_io regfile();

	assign mem_AWID = mem.s.awid;
	assign mem_AWLEN = mem.s.awlen;
	assign mem_AWADDR = mem.s.awaddr;
	assign mem_AWSIZE = mem.s.awsize;
	assign mem_AWBURST = mem.s.awburst;
	assign mem_AWVALID = mem.s.awvalid;
	assign mem.s.awready = mem_AWREADY;

	assign mem_WDATA = mem.s.wdata;
	assign mem_WLAST = mem.s.wlast;
	assign mem_WSTRB = mem.s.wstrb;
	assign mem_WVALID = mem.s.wvalid;
	assign mem.s.wready = mem_WREADY;

	assign mem_BREADY = mem.s.bready;
	assign mem.s.bid = mem_BID;
	assign mem.s.bresp = mem_BRESP;
	assign mem.s.bvalid = mem_BVALID;

	assign mem_ARID = mem.s.arid;
	assign mem_ARLEN = mem.s.arlen;
	assign mem_ARADDR = mem.s.araddr;
	assign mem_ARSIZE = mem.s.arsize;
	assign mem_ARBURST = mem.s.arburst;
	assign mem_ARVALID = mem.s.arvalid;
	assign mem.s.arready = mem_ARREADY;

	assign mem_RREADY = mem.s.rready;
	assign mem.s.rid = mem_RID;
	assign mem.s.rdata = mem_RDATA;
	assign mem.s.rresp = mem_RRESP;
	assign mem.s.rlast = mem_RLAST;
	assign mem.s.rvalid = mem_RVALID;

	assign mem_AWID = mem.s.awid;
	assign mem_AWLEN = mem.s.awlen;
	assign mem_AWADDR = mem.s.awaddr;
	assign mem_AWSIZE = mem.s.awsize;
	assign mem_AWBURST = mem.s.awburst;
	assign mem_AWVALID = mem.s.awvalid;
	assign mem.s.awready = mem_AWREADY;

	assign mem_WDATA = mem.s.wdata;
	assign mem_WLAST = mem.s.wlast;
	assign mem_WSTRB = mem.s.wstrb;
	assign mem_WVALID = mem.s.wvalid;
	assign mem.s.wready = mem_WREADY;

	assign pc_front_group = regfile.regs.pc_front_group;
	assign regfile.regs.pc_front = pc_front_pc;

	assign front_back.back.loop.group = loop_group;
	assign front_back.back.loop.valid = loop_valid;

	assign wave_insn = front.bind_.wave.insn;
	assign wave_group = front.bind_.wave.group;
	assign wave_retry = front.bind_.wave.retry;
	assign wave_valid = front.bind_.wave.valid;

	assign runnable_in_ready = front.bind_.runnable_in.tx.ready;
	assign runnable_out_data = front.bind_.runnable_out.rx.data;
	assign runnable_out_valid = front.bind_.runnable_out.rx.valid;

	gfx_shader_front front
	(
		.clk,
		.rst_n,
		.front(front_back.front),
		.reg_read(regfile.read), // Únicamente para que verilator esté feliz
		.reg_bind(regfile.bind_),
		.fetch_mem(mem.m),
		.icache_flush
	);

endmodule
