module hps_sdram_test
(
	input  wire        clk_clk,
	output wire [12:0] memory_mem_a,
	output wire [2:0]  memory_mem_ba,
	output wire        memory_mem_ck,
	output wire        memory_mem_ck_n,
	output wire        memory_mem_cke,
	output wire        memory_mem_cs_n,
	output wire        memory_mem_ras_n,
	output wire        memory_mem_cas_n,
	output wire        memory_mem_we_n,
	output wire        memory_mem_reset_n,
	inout  wire [7:0]  memory_mem_dq,
	inout  wire        memory_mem_dqs,
	inout  wire        memory_mem_dqs_n,
	output wire        memory_mem_odt,
	output wire        memory_mem_dm,
	input  wire        memory_oct_rzqin,
	/*input  wire        reset_reset_n,*/

	input logic dir, clr, mov, add, io,
	output logic[7:0] out,
	output logic done
);

	wire reset_reset_n;
	assign reset_reset_n = 1'b1;

	enum {
		IDLE,
		IO,
		RELEASE
	} state;

	logic[29:0] addr;
	logic[31:0] data_rd, data_wr;
	logic ready, write, start;

	logic [7:0] leds;

	platform plat
	(
		.master_0_core_addr(addr),
		.master_0_core_data_rd(data_rd),
		.master_0_core_data_wr(data_wr),
		.master_0_core_ready(ready),
		.master_0_core_write(write),
		.master_0_core_start(start),
		.*
	);

	initial begin
		addr = 0;
		start = 0;
		state = IDLE;
		done = 0;
	end

	assign data_wr[7:0] = out;
	assign write = dir;

	always_ff @(posedge clk_clk) unique case(state)
		IDLE: begin
			state <= RELEASE;

			if(~clr)
				out <= 0;
			else if(~mov)
				addr <= dir ? addr + 1 : addr - 1;
			else if(~add)
				out <= dir ? out + 1 : out - 1;
			else if(~io) begin
				start <= 1;
				state <= IO;
			end
		end

		IO: begin
			done <= 1;
			start <= 0;
			if(ready) begin
				if(~dir) out <= data_rd[7:0];
				state <= RELEASE;
			end
		end

		RELEASE: begin
			done <= ~io;
			if(clr & mov & add & io) state <= IDLE;
		end
	endcase
endmodule
