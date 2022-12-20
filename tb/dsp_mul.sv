module dsp_mul
(
	output logic [63:0] result,  //  result.result
	input  logic [31:0] dataa_0, // dataa_0.dataa_0
	input  logic [31:0] datab_0, // datab_0.datab_0
	input  logic        signa,   //   signa.signa
	input  logic        signb,   //   signb.signb
	input  logic        clock0,  //  clock0.clock0
	input  logic        ena0,    //    ena0.ena0
	input  logic        aclr0,   //   aclr0.aclr0
	input  logic [63:0] chainin  // chainin.chainin
);

	logic[31:0] hold_a, hold_b;
	logic[63:0] hold_chainin, ext_a, ext_b, product;
	logic hold_signa, hold_signb;

	assign ext_a = {{32{hold_signa && hold_a[31]}}, hold_a};
	assign ext_b = {{32{hold_signb && hold_b[31]}}, hold_b};

	always_comb
		unique case({hold_signa, hold_signb})
			2'b00: product = ext_a * ext_b;
			2'b01: product = ext_a * $signed(ext_b);
			2'b10: product = $signed(ext_a) * ext_b;
			2'b11: product = $signed(ext_a) * $signed(ext_b);
		endcase

	always @(posedge clock0 or posedge aclr0)
		if(aclr0) begin
			result <= {64{1'bx}};
			hold_a <= {32{1'bx}};
			hold_b <= {32{1'bx}};
			hold_signa <= 1'bx;
			hold_signb <= 1'bx;
		end else if(ena0) begin
			hold_a <= dataa_0;
			hold_b <= datab_0;
			hold_chainin <= chainin;
			hold_signa <= signa;
			hold_signb <= signb;
			result <= hold_chainin + product;
		end

endmodule
