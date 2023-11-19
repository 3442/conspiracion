`include "gfx/gfx_defs.sv"

module gfx_mem
(
	input  logic          clk,
	                      rst_n,

	input  logic          mem_waitrequest,
	                      mem_readdatavalid,
	input  vram_word      mem_readdata,
	output vram_byte_addr mem_address,
	output logic          mem_read,
	                      mem_write,
	output vram_word      mem_writedata,

	input  logic          rop_write,
	input  vram_word      rop_writedata,
	input  half_coord     rop_address,
	output logic          rop_waitrequest,

	input  logic          fb_read,
	input  half_coord     fb_address,
	output logic          fb_waitrequest,
	                      fb_readdatavalid,
	output vram_word      fb_readdata
);

	// Esto está mal, hay que reescribirlo totalmente

	logic mem_rw, trans_in_stall, trans_out_stall, in_ready, skid_in_valid, out_ready;

	struct packed
	{
		vram_addr address;
		logic     write;
		vram_word writedata;
	} trans_in, trans_out, trans_in_skid, trans_out_skid;

	/* Cerrar timing aquí no es tan fácil, debido al enrutamiento al el que
	 * necesariamente está sujeto este módulo (eg, VRAM y DAC están en
	 * posiciones fijas en los bordes de la FPGA y no pueden reacomodarse).
	 */

	gfx_skid_buf #(.WIDTH($bits(trans_in))) in_skid
	(
		.in(trans_in),
		.out(trans_in_skid),
		.stall(trans_in_stall),
		.*
	);

	gfx_skid_flow in_flow
	(
		.stall(trans_in_stall),
		.in_ready(in_ready),
		.in_valid(rop_write || fb_read),
		.out_ready(out_ready),
		.out_valid(skid_in_valid),
		.*
	);

	gfx_pipes #(.WIDTH($bits(trans_out)), .DEPTH(`GFX_MEM_TRANS_DEPTH)) out_pipes
	(
		.in(trans_in_skid),
		.out(trans_out),
		.stall(trans_out_stall),
		.*
	);

	gfx_skid_buf #(.WIDTH($bits(trans_out))) out_skid
	(
		.in(trans_out),
		.out(trans_out_skid),
		.stall(trans_out_stall),
		.*
	);

	gfx_pipeline_flow #(.STAGES(`GFX_MEM_TRANS_DEPTH)) out_flow
	(
		.stall(trans_out_stall),
		.in_ready(out_ready),
		.in_valid(skid_in_valid),
		.out_ready(!mem_waitrequest),
		.out_valid(mem_rw),
		.*
	);

	gfx_pipes #(.WIDTH($bits(vram_word)), .DEPTH(`GFX_MEM_FIFO_DEPTH)) readdata_pipes
	(
		.in(mem_readdata),
		.out(fb_readdata),
		.stall(0),
		.*
	);

	gfx_pipeline_flow #(.STAGES(`GFX_MEM_FIFO_DEPTH)) readdata_flow
	(
		.stall(),
		.in_ready(),
		.in_valid(mem_readdatavalid),
		.out_ready(1),
		.out_valid(fb_readdatavalid),
		.*
	);

	assign mem_read = mem_rw && !trans_out_skid.write;
	assign mem_write = mem_rw && trans_out_skid.write;
	assign mem_address = {trans_out_skid.address, {`GFX_MEM_SUBWORD_BITS{1'b0}}};
	assign mem_writedata = trans_out_skid.writedata;

	always_comb begin
		fb_waitrequest = 1;
		rop_waitrequest = 1;

		trans_in.writedata = rop_writedata;

		if (fb_read) begin
			fb_waitrequest = !in_ready;
			trans_in.write = 0;
			trans_in.address = {5'd0, fb_address};
		end else begin
			rop_waitrequest = !in_ready;
			trans_in.write = 1;
			trans_in.address = {5'd0, rop_address};
		end
	end

endmodule
