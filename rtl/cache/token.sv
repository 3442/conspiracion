`include "cache/defs.sv"

module cache_token
#(parameter TOKEN_AT_RESET=0)
(
	input  logic       clk,
	                   rst_n,

	input  addr_tag    core_tag,
	input  addr_index  core_index,

	input  ring_token  in_token,			// input del token
	input  logic       in_token_valid,		// se está recibiendo el token

	output ring_token  out_token,			// output del token
	output logic       out_token_valid,		// se está enviando el token

	input  logic       send,
	                   lock_line,
	                   unlock_line,
	output logic       locked,
	                   may_send
);

	logic may_send_if_token_held;

	// Solo se puede iniciar un request si se tiene el token y el token es
	// válido
	assign may_send = may_send_if_token_held && in_token_valid;
	assign may_send_if_token_held
	     = (!in_token.e2.valid || in_token.e2.index != core_index || in_token.e2.tag != core_tag)
	    && (!in_token.e1.valid || in_token.e1.index != core_index || in_token.e1.tag != core_tag)
	    && (!in_token.e0.valid || in_token.e0.index != core_index || in_token.e0.tag != core_tag);

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			out_token <= {($bits(out_token)){1'b0}};
			out_token_valid <= TOKEN_AT_RESET;

			locked <= 0;
		end else begin
			out_token.e0.tag <= core_tag;
			out_token.e0.index <= core_index;
			out_token.e0.valid <= may_send_if_token_held && (send || locked) && !unlock_line;

			out_token.e2 <= in_token.e1;
			out_token.e1 <= in_token.e0;
			out_token_valid <= in_token_valid;

			if (lock_line)
				locked <= 1;

			if (unlock_line)
				locked <= 0;
		end

endmodule
