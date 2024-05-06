module gfx_sched
import gfx::*;
(
	input  logic     clk,
	                 rst_n,
	                 srst_n,

	       if_axil.m axim,

	input  irq_lines irq
);

	// verilator tracing_off

	logic axi_ready, axi_valid, bram_ready, bram_read, bram_write, bram_write_next,
	      mem_instr, mem_la_read, mem_la_write, mem_ready, mem_valid, select_bram;

	word bram[SCHED_BRAM_WORDS];
	word axi_rdata, bram_rdata, mem_addr, mem_la_addr, mem_rdata, mem_wdata;
	logic[$bits(word) / $bits(byte) - 1:0] mem_wstrb;

	logic[$clog2(SCHED_BRAM_WORDS) - 1:0] bram_addr;

	assign bram_addr = mem_addr[$bits(bram_addr) + SUBWORD_BITS - 1:SUBWORD_BITS];
	assign mem_ready = (axi_valid & axi_ready) | bram_ready;
	assign mem_rdata = bram_ready ? bram_rdata : axi_rdata;
	assign select_bram = ~|mem_la_addr[$bits(mem_la_addr) - 1:$bits(bram_addr) + SUBWORD_BITS];
	assign bram_write_next = mem_la_write & select_bram;

	defparam core.ENABLE_COUNTERS   = 0;
	defparam core.ENABLE_COUNTERS64 = 0;
	defparam core.BARREL_SHIFTER    = 1;
	defparam core.COMPRESSED_ISA    = 1;
	defparam core.CATCH_MISALIGN    = 0;
	defparam core.CATCH_ILLINSN     = 0;
	defparam core.ENABLE_MUL        = 1;
	defparam core.ENABLE_DIV        = 1;
	defparam core.ENABLE_IRQ        = 1;
	defparam core.ENABLE_IRQ_QREGS  = 0;
	defparam core.ENABLE_IRQ_TIMER  = 0;
	defparam core.PROGADDR_RESET    = BOOTROM_BASE;

	picorv32 core
	(
		.clk,
		.resetn(srst_n),
		.trap(),

		.mem_valid,
		.mem_instr,
		.mem_ready,

		.mem_addr,
		.mem_wdata,
		.mem_wstrb,
		.mem_rdata,

		.mem_la_read,
		.mem_la_write,
		.mem_la_addr,
		.mem_la_wdata(),
		.mem_la_wstrb(),

		.pcpi_valid(),
		.pcpi_insn(),
		.pcpi_rs1(),
		.pcpi_rs2(),
		.pcpi_wr(),
		.pcpi_rd(),
		.pcpi_wait(0),
		.pcpi_ready(0),

		.irq,
		.eoi(),

		.trace_valid(),
		.trace_data()
	);

	picorv32_axi_adapter axi
	(
		.clk,
		.resetn(srst_n),

		.mem_axi_awvalid(axim.awvalid),
		.mem_axi_awready(axim.awready),
		.mem_axi_awaddr(axim.awaddr),
		.mem_axi_awprot(),

		.mem_axi_wvalid(axim.wvalid),
		.mem_axi_wready(axim.wready),
		.mem_axi_wdata(axim.wdata),
		.mem_axi_wstrb(), // Potenciales sorpresas

		.mem_axi_bvalid(axim.bvalid),
		.mem_axi_bready(axim.bready),

		.mem_axi_arvalid(axim.arvalid),
		.mem_axi_arready(axim.arready),
		.mem_axi_araddr(axim.araddr),
		.mem_axi_arprot(),

		.mem_axi_rvalid(axim.rvalid),
		.mem_axi_rready(axim.rready),
		.mem_axi_rdata(axim.rdata),

		.mem_valid(mem_valid & axi_valid),
		.mem_instr,
		.mem_ready(axi_ready),
		.mem_addr,
		.mem_wdata,
		.mem_wstrb,
		.mem_rdata(axi_rdata)
	);

	always_ff @(posedge clk) begin
		if (bram_write) begin
			for (int i = 0; i < $bits(mem_wstrb); ++i)
				if (mem_wstrb[i])
					bram[bram_addr][i] <= mem_wdata[i];

			bram_rdata <= 'x;
		end else
			bram_rdata <= bram[bram_addr];
	end


	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			axi_valid <= 0;
			bram_read <= 0;
			bram_ready <= 0;
			bram_write <= 0;
		end else begin
			axi_valid <= ~select_bram | (axi_valid & ~axi_ready);
			bram_read <= mem_la_read & select_bram;
			bram_write <= bram_write_next;
			bram_ready <= bram_read | bram_write_next;
		end

endmodule
