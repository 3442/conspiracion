`include "cache/defs.sv"
`include "config.sv"

module perf_snoop
(
	input  logic       clk,
	                   rst_n,

	input  logic       in_left_valid,
	input  ring_req    in_left,
	output logic       in_left_ready,

	input  logic       out_left_ready,
	output ring_req    out_left,
	output logic       out_left_valid,

	input  logic       in_right_valid,
	input  ring_req    in_right,
	input  logic       in_right_ready,

	input  line_ptr    local_address,
	input  logic       local_read,
	                   local_write,
	input  line        local_writedata,
	input  line_be     local_byteenable,
	output logic       local_waitrequest,
	output line        local_readdata,

	input  logic       mem_waitrequest,
	input  line        mem_readdata,
	output word        mem_address,
	output logic       mem_read,
	                   mem_write,
	output line        mem_writedata,
	output line_be     mem_byteenable,

	output logic       snoop_left_ready,
	                   snoop_left_valid,
	                   snoop_right_ready,
	                   snoop_right_valid,
	                   snoop_read,
	                   snoop_write,
	                   snoop_waitrequest,
	output word        snoop_address,
	output perf_sample snoop_left,
	                   snoop_right
);

	word hold_address;
	logic hold_left_ready, hold_left_valid, hold_right_ready, hold_right_valid,
	      hold_read, hold_write, hold_waitrequest;

	perf_sample hold_left, hold_right;

	// out_right es driveado por las mismas líneas debido al anillo
	assign in_left_ready = out_left_ready;
	assign out_left = in_left;
	assign out_left_valid = in_left_valid;

	assign mem_read = local_read;
	assign mem_write = local_write;
	assign mem_address = {local_address, 4'b0000};
	assign mem_writedata = local_writedata;
	assign mem_byteenable = local_byteenable;
	assign local_readdata = mem_readdata;
	assign local_waitrequest = mem_waitrequest;

	generate
		if (`CONFIG_PERF_MONITOR) begin: enable
			always @(posedge clk or negedge rst_n)
				if (!rst_n) begin
					hold_read <= 0;
					hold_write <= 0;
					hold_waitrequest <= 0;

					hold_left_ready <= 0;
					hold_left_valid <= 0;
					hold_right_ready <= 0;
					hold_right_valid <= 0;

					snoop_read <= 0;
					snoop_write <= 0;
					snoop_waitrequest <= 0;

					snoop_left_ready <= 0;
					snoop_left_valid <= 0;
					snoop_right_ready <= 0;
					snoop_right_valid <= 0;
				end else begin
					/* La idea aquí es aligerar el trabajo del fitter, ya que perf_monitor
					 * muestrea el anillo completo, por lo que su span de área es
					 * potencialmente grande.
					 */

					hold_read <= mem_read;
					hold_write <= mem_write;
					hold_waitrequest <= mem_waitrequest;

					hold_left_ready <= in_left_ready;
					hold_left_valid <= in_left_valid;
					hold_right_ready <= in_right_ready;
					hold_right_valid <= in_right_valid;

					snoop_read <= hold_read;
					snoop_write <= hold_write;
					snoop_waitrequest <= hold_waitrequest;

					snoop_left_ready <= hold_left_ready;
					snoop_left_valid <= hold_left_valid;
					snoop_right_ready <= hold_right_ready;
					snoop_right_valid <= hold_right_valid;
				end

			always @(posedge clk) begin
				hold_left.ttl <= in_left.ttl;
				hold_left.read <= in_left.read;
				hold_left.inval <= in_left.inval;
				hold_left.reply <= in_left.reply;

				hold_right.ttl <= in_right.ttl;
				hold_right.read <= in_right.read;
				hold_right.inval <= in_right.inval;
				hold_right.reply <= in_right.reply;

				snoop_left <= hold_left;
				snoop_right <= hold_right;

				hold_address <= mem_address;
				snoop_address <= hold_address;
			end
		end
	endgenerate

endmodule
