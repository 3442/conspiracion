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

	input  vram_addr      host_address,
	input  logic          host_read,
	                      host_write,
	input  vram_word      host_writedata,
	output logic          host_waitrequest,
	                      host_readdatavalid,
	output vram_word      host_readdata,

	input  logic          rop_write,
	input  vram_word      rop_writedata,
	input  half_coord     rop_address,
	output logic          rop_waitrequest,

	input  logic          fb_read,
	input  half_coord     fb_address,
	output logic          fb_waitrequest,
	                      fb_readdatavalid,
	output vram_word      fb_readdata,

	input  logic          batch_read,
	input  vram_addr      batch_address,
	output logic          batch_waitrequest,
	                      batch_readdatavalid,
	output vram_word      batch_readdata,

	input  logic          fetch_read,
	input  vram_addr      fetch_address,
	output logic          fetch_waitrequest,
	                      fetch_readdatavalid,
	output vram_word      fetch_readdata
);

	// Este módulo es inaceptable, hay que reescribirlo

	logic mem_rw, trans_in_stall, trans_out_stall, in_ready, in_valid, skid_in_valid, out_ready,
	      any_readdatavalid, readdatavalid, dispatch_full, dispatch_put, mem_ready;

	vram_word any_readdata, readdata;
	logic[$clog2(`GFX_MEM_DISPATCH_DEPTH) - 1:0] next_put_ptr, pop_ptr, put_ptr;

	struct packed
	{
		logic fb,
		      host,
		      batch,
		      fetch;
	} dispatch_in, dispatch_out, dispatch_buf[`GFX_MEM_DISPATCH_DEPTH];

	struct packed
	{
		vram_addr address;
		logic     write,
		          fb_waitrequest,
		          host_waitrequest,
		          batch_waitrequest,
		          fetch_waitrequest;
		vram_word writedata;
	} trans_in, trans_out, trans_in_skid, trans_out_skid;

	assign mem_read = mem_rw && !trans_out_skid.write && !dispatch_full;
	assign mem_write = mem_rw && trans_out_skid.write;
	assign mem_address = {trans_out_skid.address, {`GFX_MEM_SUBWORD_BITS{1'b0}}};
	assign mem_writedata = trans_out_skid.writedata;

	assign fb_readdata = any_readdata;
	assign host_readdata = any_readdata;
	assign batch_readdata = any_readdata;
	assign fetch_readdata = any_readdata;

	assign fb_readdatavalid = any_readdatavalid && dispatch_out.fb;
	assign host_readdatavalid = any_readdatavalid && dispatch_out.host;
	assign batch_readdatavalid = any_readdatavalid && dispatch_out.batch;
	assign fetch_readdatavalid = any_readdatavalid && dispatch_out.fetch;

	assign dispatch_in.fb = !trans_out_skid.fb_waitrequest;
	assign dispatch_in.host = !trans_out_skid.host_waitrequest;
	assign dispatch_in.batch = !trans_out_skid.batch_waitrequest;
	assign dispatch_in.fetch = !trans_out_skid.fetch_waitrequest;

	assign in_valid = rop_write || fb_read || batch_read || fetch_read || host_read || host_write;
	assign mem_ready = !mem_waitrequest && (!dispatch_full || trans_out_skid.write);
	assign next_put_ptr = put_ptr + 1;
	assign dispatch_put = mem_ready && mem_rw && !trans_out_skid.write;
	assign dispatch_full = next_put_ptr == pop_ptr;

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
		.out_ready(mem_ready),
		.out_valid(mem_rw),
		.*
	);

	gfx_pipes #(.WIDTH($bits(vram_word)), .DEPTH(`GFX_MEM_RESPONSE_DEPTH)) readdata_pipes
	(
		.in(mem_readdata),
		.out(readdata),
		.stall(0),
		.*
	);

	gfx_pipeline_flow #(.STAGES(`GFX_MEM_RESPONSE_DEPTH)) readdata_flow
	(
		.stall(),
		.in_ready(),
		.in_valid(mem_readdatavalid),
		.out_ready(1),
		.out_valid(readdatavalid),
		.*
	);

	always_comb begin
		fb_waitrequest = 1;
		rop_waitrequest = 1;
		host_waitrequest = 1;
		batch_waitrequest = 1;
		fetch_waitrequest = 1;

		trans_in.write = 0;
		trans_in.writedata = {($bits(trans_in.writedata)){1'bx}};

		if (fb_read) begin
			fb_waitrequest = !in_ready;
			trans_in.address = {5'd0, fb_address};
		end else if (batch_read) begin
			batch_waitrequest = !in_ready;
			trans_in.address = batch_address;
		end else if (rop_write) begin
			rop_waitrequest = !in_ready;

			trans_in.write = 1;
			trans_in.address = {5'd0, rop_address};
			trans_in.writedata = rop_writedata;
		end else if (fetch_read) begin
			fetch_waitrequest = !in_ready;
			trans_in.address = fetch_address;
		end else begin
			host_waitrequest = !in_ready;

			trans_in.write = host_write;
			trans_in.address = host_address;
			trans_in.writedata = host_writedata;
		end

		trans_in.fb_waitrequest = fb_waitrequest;
		trans_in.host_waitrequest = host_waitrequest;
		trans_in.batch_waitrequest = batch_waitrequest;
		trans_in.fetch_waitrequest = fetch_waitrequest;
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			pop_ptr <= 0;
			put_ptr <= 0;
		end else begin
			if (readdatavalid)
				pop_ptr <= pop_ptr + 1;

			if (dispatch_put)
				put_ptr <= next_put_ptr;
		end


	always_ff @(posedge clk) begin
		any_readdata <= readdata;
		any_readdatavalid <= readdatavalid;

		dispatch_out <= dispatch_buf[pop_ptr];

		if (dispatch_put)
			dispatch_buf[put_ptr] <= dispatch_in;
	end

endmodule
