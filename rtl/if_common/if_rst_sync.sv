//FIXME: peligro
module if_rst_sync
(
	input  logic clk,
	             rst_n,

	output logic srst_n
);

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			srst_n <= 0;
		else
			srst_n <= 1;

endmodule
