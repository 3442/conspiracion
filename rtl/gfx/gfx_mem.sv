`include "gfx/gfx_defs.sv"

module gfx_mem
(
	input  logic      clk,
	                  rst_n,

	input  logic      mem_waitrequest,
	                  mem_readdatavalid,
	input  mem_word   mem_readdata,
	output mem_addr   mem_address,
	output logic      mem_read,
	                  mem_write,
	output mem_word   mem_writedata,

	input  logic      rop_write,
	input  mem_word   rop_writedata,
	input  half_coord rop_address,
	output logic      rop_waitrequest,

	input  logic      fb_read,
	input  half_coord fb_address,
	output logic      fb_waitrequest,
	                  fb_readdatavalid,
	output mem_word   fb_readdata
);

	// Esto está mal, hay que reescribirlo totalmente

	logic lock, lock_rop, select_rop, wait_state;

	assign fb_readdata = mem_readdata;
	assign fb_readdatavalid = mem_readdatavalid;

	assign mem_writedata = rop_writedata;

	assign wait_state = (mem_read || mem_write) && mem_waitrequest;

	always_comb begin
		select_rop = !fb_read;

		if (lock)
			select_rop = lock_rop;

		mem_read = 0;
		mem_write = 0;
		fb_waitrequest = 1;
		rop_waitrequest = 1;

		if (select_rop) begin
			mem_write = rop_write;
			mem_address = {6'd0, rop_address};

			rop_waitrequest = mem_waitrequest;
		end else begin
			mem_read = fb_read;
			mem_address = {6'd0, fb_address};

			fb_waitrequest = mem_waitrequest;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		lock <= !rst_n ? 0 : wait_state;

	always_ff @(posedge clk)
		if (wait_state)
			lock_rop <= select_rop;

endmodule
