`include "cache/defs.sv"

module cache_ring
(
	input  logic       clk,
	                   rst_n,

	input  addr_tag    core_tag,
	input  addr_index  core_index,

	input  ring_req    in_data,				// lo que se recibe
	input  logic       in_data_valid,		// este caché está recibiendo
	                   in_data_ready,

	input  logic       out_data_ready,		// este caché está listo para enviar
	output ring_req    out_data,			// lo que se envía
	output logic       out_data_valid,		// este caché está enviando datos

	input  line        data_rd,		// datos de la línea

	input  logic       send,
	                   send_read,
	                   send_inval,
	                   set_reply,
	output logic       out_stall,
	                   in_hold_valid,
	                   last_hop,
	output ring_req    in_hold
);

	// in_hold: el paquete actual
	ring_req send_data, fwd_data, stall_data, out_data_next;

	assign last_hop = in_hold.ttl == `TTL_END;	//Indica si es el último salto

	assign out_data = out_stall ? stall_data : out_data_next;
	assign out_data_next = send ? send_data : fwd_data;
	assign out_data_valid = out_stall || send || (in_hold_valid && !last_hop && in_data_ready);

	assign send_data.tag = core_tag;
	assign send_data.ttl = `TTL_MAX;	   // Acá se inicializa el valor máximo de TTL
	assign send_data.data = fwd_data.data; // Esto evita muchos muxes
	assign send_data.read = send_read;
	assign send_data.index = core_index;
	assign send_data.inval = send_inval;
	assign send_data.reply = 0;

	always_comb begin
		fwd_data = in_hold;
		fwd_data.ttl = in_hold.ttl - 2'b1;

		if (set_reply) begin
			fwd_data.data = data_rd;
			fwd_data.reply = 1;
		end
	end

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			in_hold_valid <= 0;
			out_stall <= 0;
		end else begin
			if (in_data_ready)
				in_hold_valid <= in_data_valid;

			out_stall <= out_data_valid && !out_data_ready;
		end

	always_ff @(posedge clk) begin
		if (in_data_ready)
			in_hold <= in_data;

		if (!out_stall)
			stall_data <= out_data_next;
	end

endmodule
