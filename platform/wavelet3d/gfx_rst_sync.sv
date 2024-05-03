//FIXME: peligro
module gfx_rst_sync
(
	input  logic clk,
	             rst_n,

	output logic srst_n
);

	always_ff @(posedge clk or negedge rst_n)
		srst_n <= ~rst_n ? 0 : 1;

endmodule
