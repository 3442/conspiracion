module gfx_bootrom
import gfx::*;
(
	input  logic     clk,
	                 rst_n,

	       if_axil.s axis
);

	localparam ROM_WORDS_LOG = 7;

	enum int unsigned
	{
		WAIT,
		READ,
		RDATA,
		READY
	} state;

	word read, rom[1 << ROM_WORDS_LOG];
	logic[ROM_WORDS_LOG - 1:0] read_addr;

	assign axis.bvalid = 0;
	assign axis.wready = 0;
	assign axis.awready = 0;

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			state <= WAIT;
			axis.rvalid <= 0;
			axis.arready <= 0;
		end else begin
			axis.arready <= 0;

			unique case (state)
				WAIT:
					if (axis.arvalid & ~axis.arready)
						state <= READ;

				READ:
					state <= RDATA;

				RDATA: begin
					state <= READY;
					axis.rvalid <= 1;
				end

				READY:
					if (axis.rready) begin
						state <= WAIT;
						axis.rvalid <= 0;
						axis.arready <= 1;
					end
			endcase
		end

	always_ff @(posedge clk) begin
		read <= rom[read_addr];
		read_addr <= axis.araddr[$bits(read_addr) + SUBWORD_BITS - 1:SUBWORD_BITS];
		axis.rdata <= read;
	end

	initial
		$readmemh("gfx_bootrom.hex", rom);

endmodule
