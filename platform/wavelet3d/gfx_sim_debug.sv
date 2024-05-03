module gfx_sim_debug
import gfx::*;
(
	input  logic      clk,
	                  rst_n,

	       gfx_axil.s axis
);

	enum int unsigned
	{
		INPUT,
		STALL
	} state;

	assign axis.rvalid = 0;
	assign axis.arready = 0;
	assign axis.awready = 1;

	always_comb
		unique case (state)
			INPUT: begin
				axis.wready = 1;
				axis.bvalid = axis.wvalid;
			end

			STALL: begin
				axis.wready = 0;
				axis.bvalid = 1;
			end
		endcase

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			state <= INPUT;
		else
			unique case (state)
				INPUT:
					if (axis.wvalid) begin
						$display("%c", axis.wdata[7:0]);
						if (~axis.bready)
							state <= STALL;
					end

				STALL:
					if (axis.bready)
						state <= INPUT;
			endcase

endmodule
