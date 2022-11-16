`include "core/uarch.sv"

module core_control_ldst_sizes
(
	input  word       base,
	                  q_shifter,
	input  ldst_size  size,
	input  logic      sign_extend,

	output ptr        addr,
	output word       read,
	output logic[1:0] shift,
	output logic[3:0] byteenable,
	output logic      fault
);

	assign {addr, shift} = base;

	always_comb
		unique case(size)
			LDST_BYTE: begin
				read = {{24{q_shifter[7] && sign_extend}}, q_shifter[7:0]};
				fault = 0;

				unique case(shift)
					2'b00: byteenable = 4'b0001;
					2'b01: byteenable = 4'b0010;
					2'b10: byteenable = 4'b0100;
					2'b11: byteenable = 4'b1000;
				endcase
			end

			LDST_HALF: begin
				read = {{16{q_shifter[15] && sign_extend}}, q_shifter[15:0]};
				fault = shift[0];
				byteenable = shift[1] ? 4'b1100 : 4'b0011;
			end

			LDST_WORD: begin
				read = q_shifter;
				fault = shift[1] || shift[0];
				byteenable = 4'b1111;
			end
		endcase

endmodule
