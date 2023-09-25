`include "cache/defs.sv"

module cache_control
#(parameter TOKEN_AT_RESET=0)
(
	input  logic      clk,
	                  rst_n,

	input  addr_tag   core_tag,
	input  addr_index core_index,
	input  logic      core_read,
	                  core_write,
	input  line       core_data_wr,
	output logic      core_waitrequest,

	input  ring_req   in_data,
	input  logic      in_data_valid,
	output logic      in_data_ready,

	input  logic      out_data_ready,
	output ring_req   out_data,
	output logic      out_data_valid,

	input  ring_token in_token,
	input  logic      in_token_valid,

	output ring_token out_token,
	output logic      out_token_valid,

	input  addr_tag   tag_rd,
	input  line       data_rd,
	input  line_state state_rd,

	output addr_index index_rd,
	                  index_wr,
	output logic      write_data,
	                  write_state,
	output addr_tag   tag_wr,
	output line       data_wr,
	output line_state state_wr,

	input  logic      mem_waitrequest,
	input  line       mem_readdata,
	output word       mem_address,
	output logic      mem_read,
	                  mem_write,
	output line       mem_writedata
);

	enum int unsigned
	{
		ACCEPT,
		CORE,
		SNOOP,
		REPLY
	} state, next_state;

	logic accept_snoop, in_hold_valid, inval_reply, last_hop, lock_line, locked,
	      may_send, may_send_if_token_held, mem_begin, mem_end, mem_read_end, mem_wait,
	      out_stall, wait_reply, replace, retry, send, send_inval, send_read,
	      snoop_hit, set_reply, unlock_line, writeback;

	ring_req in_hold, send_data, fwd_data, stall_data, out_data_next;

	addr_tag mem_tag;
	addr_index mem_index;

	assign mem_end = (mem_read || mem_write) && !mem_waitrequest;
	assign mem_wait = (mem_read || mem_write) && mem_waitrequest;
	assign mem_address = {3'b000, mem_tag, mem_index, 4'b0000};
	assign mem_read_end = mem_read && !mem_waitrequest;

	/* Desbloquear la línea hasta que la request del core termine garantiza
	 * avance del sistema completo, en lockstep en el peor caso posible,
	 * a pesar de retries (una fuerte contención de writes a INVALID
	 * o SHARED jamás provocará que dos o más nodos queden en deadlock).
	 */
	assign unlock_line = !core_waitrequest;

	assign replace = tag_rd != core_tag && state_rd != INVALID;
	assign last_hop = in_hold.ttl == `TTL_END;
	assign snoop_hit = tag_rd == in_hold.tag;
	assign accept_snoop = in_hold_valid && !last_hop && (in_hold.inval || !in_hold.reply);

	assign may_send = may_send_if_token_held && in_token_valid;
	assign may_send_if_token_held
	     = (!in_token.e2.valid || in_token.e2.index != core_index || in_token.e2.tag != core_tag)
	    && (!in_token.e1.valid || in_token.e1.index != core_index || in_token.e1.tag != core_tag)
	    && (!in_token.e0.valid || in_token.e0.index != core_index || in_token.e0.tag != core_tag);

	assign out_data = out_stall ? stall_data : out_data_next;
	assign out_data_next = send ? send_data : fwd_data;
	assign out_data_valid = out_stall || send || (in_hold_valid && !last_hop && in_data_ready);

	assign send_data.tag = core_tag;
	assign send_data.ttl = `TTL_MAX;
	assign send_data.data = fwd_data.data; // Esto evita muchos muxes
	assign send_data.read = send_read;
	assign send_data.index = core_index;
	assign send_data.inval = send_inval;
	assign send_data.reply = 0;

	always_comb begin
		tag_wr = core_tag;
		data_wr = core_data_wr;
		index_rd = core_index;

		state_wr = INVALID; //FIXME: debería ser 'bx
		write_data = 0;
		write_state = 0;

		mem_begin = 0;
		writeback = 0;

		send = 0;
		send_read = 0;
		send_inval = 0;

		set_reply = 0;
		inval_reply = 0;
		core_waitrequest = 1;

		in_data_ready = !in_hold_valid;

		unique case (state)
			ACCEPT: begin
				if (last_hop && !in_hold.read) begin
					inval_reply = in_hold_valid;
					in_data_ready = 1;
				end

				if (accept_snoop)
					index_rd = in_hold.index;
			end

			CORE:
				if (replace) begin
					state_wr = INVALID;
					write_state = 1;

					if (state_rd == MODIFIED)
						writeback = 1;
				end else unique case ({state_rd, core_write})
					{INVALID, 1'b0}: begin
						send = 1;
						send_read = 1;
					end

					{INVALID, 1'b1}: begin
						send = 1;
						send_read = 1;
						send_inval = 1;
					end

					{SHARED, 1'b0}:
						core_waitrequest = 0;

					{SHARED, 1'b1}: begin
						/* No hacemos write_data ya que reintentaremos el
						 * write luego, cuando el estado será EXCLUSIVE.
						 *
						 * Nótese que esta es la misma razón por la que no
						 * pasamos directamente a MODIFIED.
						 */
						state_wr = EXCLUSIVE;
						write_state = 1;

						send = 1;
						send_inval = 1;
					end

					{EXCLUSIVE, 1'b0}:
						core_waitrequest = 0;

					{EXCLUSIVE, 1'b1}: begin
						state_wr = MODIFIED;
						write_data = 1;
						write_state = 1;
						core_waitrequest = 0;
					end

					{MODIFIED, 1'b0}:
						core_waitrequest = 0;

					{MODIFIED, 1'b1}: begin
						write_data = 1;
						core_waitrequest = 0;
					end
				endcase

			SNOOP: begin
				index_rd = in_hold.index;
				in_data_ready = 1;

				if (snoop_hit) begin
					if (in_hold.read) begin
						set_reply = 1;

						unique case (state_rd)
							INVALID:
								set_reply = 0;

							SHARED: ;

							EXCLUSIVE: begin
								state_wr = SHARED;
								write_state = 1;
							end

							MODIFIED: begin
								state_wr = SHARED;
								write_state = 1;

								writeback = 1;
							end
						endcase
					end

					if (in_hold.inval) begin
						state_wr = INVALID;
						write_state = 1;
					end
				end
			end

			REPLY: begin
				in_data_ready = 1;

				if (in_hold.reply) begin
					data_wr = in_hold.data;
					state_wr = SHARED;
					write_data = 1;
					write_state = 1;
				end else
					mem_begin = 1;
			end

			default: ;
		endcase

		if (writeback)
			mem_begin = 1;

		// Colisiones de bus 
		retry = (mem_read_end && (write_data || write_state)) || (mem_wait && mem_begin);

		// Nótese la diferencia con un assign, ya que send puede cambiar más abajo
		lock_line = send;

		if (send && !may_send && !locked)
			retry = 1;

		if (retry) begin
			send = 0;
			mem_begin = 0;
			write_data = 0;
			write_state = 0;

			in_data_ready = !in_hold_valid;
			core_waitrequest = 1;
		end

		index_wr = index_rd;
		if (mem_read_end) begin
			tag_wr = mem_tag;
			index_wr = mem_index;

			data_wr = mem_readdata;
			state_wr = EXCLUSIVE;

			write_data = 1;
			write_state = 1;
		end
	end

	always_comb begin
		fwd_data = in_hold;
		fwd_data.ttl = in_hold.ttl - 2'b1;

		if (set_reply) begin
			fwd_data.data = data_rd;
			fwd_data.reply = 1;
		end
	end

	always_comb begin
		next_state = ACCEPT;

		unique case (state)
			ACCEPT: begin
				if (accept_snoop)
					next_state = SNOOP;
				else if (in_hold_valid && last_hop && in_hold.read)
					next_state = REPLY;
				else if ((core_read || core_write) && !wait_reply && (!locked || may_send))
					next_state = CORE;

				if (out_stall && !out_data_ready)
					next_state = ACCEPT;
			end

			default: ;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		state <= !rst_n ? ACCEPT : next_state;

	always_ff @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			out_token <= {($bits(out_token)){1'b0}};
			out_token_valid <= TOKEN_AT_RESET;

			in_hold_valid <= 0;
			out_stall <= 0;

			locked <= 0;
			wait_reply <= 0;

			mem_read <= 0;
			mem_write <= 0;
		end else begin
			out_token.e0.tag <= core_tag;
			out_token.e0.index <= core_index;
			out_token.e0.valid <= may_send_if_token_held && (send || locked) && !unlock_line;

			out_token.e2 <= in_token.e1;
			out_token.e1 <= in_token.e0;
			out_token_valid <= in_token_valid;

			if (in_data_ready)
				in_hold_valid <= in_data_valid;

			out_stall <= out_data_valid && !out_data_ready;

			if (lock_line)
				locked <= 1;

			if (unlock_line)
				locked <= 0;

			if (send)
				wait_reply <= 1;

			if (inval_reply || mem_read_end)
				wait_reply <= 0;

			if (mem_end) begin
				mem_read <= 0;
				mem_write <= 0;
			end

			if (mem_begin) begin
				mem_read <= !writeback;
				mem_write <= writeback;
			end
		end

	always_ff @(posedge clk) begin
		if (in_data_ready)
			in_hold <= in_data;

		if (!out_stall)
			stall_data <= out_data_next;

		if (mem_begin) begin
			mem_tag <= writeback ? tag_rd : core_tag;
			mem_index <= index_wr;
			mem_writedata <= data_rd;
		end
	end

endmodule
