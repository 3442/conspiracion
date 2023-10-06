`include "cache/defs.sv"

module cache_control
(
	input  logic       clk,
	                   rst_n,

	input  addr_tag    core_tag,
	input  addr_index  core_index,
	input  logic       core_read,
	                   core_write,
	                   core_lock,
	input  line        core_data_wr,
	output logic       core_waitrequest,

	input  ring_req    in_data,				// lo que se recibe
	input  logic       in_data_valid,		// este caché está recibiendo
	output logic       in_data_ready,		// este caché esta listo para recibir

	input  logic       out_data_ready,		// este caché está listo para enviar
	output ring_req    out_data,			// lo que se envía
	output logic       out_data_valid,		// este caché está enviando datos

	// Señales para la SRAM
	input  addr_tag    tag_rd,		// valor de la tag de esa línea
	input  line        data_rd,		// datos de la línea
	input  line_state  state_rd,	// estado de la línnea

	output addr_index  index_rd,
	                   index_wr,
	output logic       write_data,
	                   write_state,
	output addr_tag    tag_wr,
	output line        data_wr,
	output line_state  state_wr,

	input  logic       mem_waitrequest,
	input  line        mem_readdata,
	output word        mem_address,
	output logic       mem_read,
	                   mem_write,
	output line        mem_writedata,

	input  logic       locked,
	                   may_send,
	                   out_stall,
	                   in_hold_valid,
	                   last_hop,
	input  ring_req    in_hold,
	output logic       send,
	                   send_read,
	                   send_inval,
	                   set_reply,
	                   lock_line,
	                   unlock_line,

	input  logic       dbg_write,
	input  addr_index  debug_index,
	output logic       debug_ready,

	input  line        monitor_update,
	input  logic       monitor_commit,
	output logic       monitor_acquire,
	                   monitor_fail,
	                   monitor_release
);

	enum int unsigned
	{
		ACCEPT,
		CORE,
		SNOOP,
		REPLY
	} state, next_state;

	logic accept_snoop, debug, end_reply,
	      mem_begin, mem_end, mem_read_end, mem_wait, wait_reply,
	      replace, retry, snoop_hit, writeback;

	addr_tag mem_tag;
	addr_index mem_index;

	assign mem_end = (mem_read || mem_write) && !mem_waitrequest;
	assign mem_wait = (mem_read || mem_write) && mem_waitrequest;
	assign mem_address = {`IO_CACHED, mem_tag, mem_index, 4'b0000};
	assign mem_read_end = mem_read && !mem_waitrequest;

	/* Desbloquear la línea hasta que la request del core termine garantiza
	 * avance del sistema completo, en lockstep en el peor caso posible,
	 * a pesar de retries (una fuerte contención de writes a INVALID
	 * o SHARED jamás provocará que dos o más nodos queden en deadlock).
	 */
	assign unlock_line = !core_waitrequest;

	// Replace si no coinciden las tags y el estado no es INVALID
	assign replace = tag_rd != core_tag && state_rd != INVALID;
	assign snoop_hit = tag_rd == in_hold.tag;	//Snoop hit si coinciden las tags
	// Aceptar snoop si no es el último nodo y se tiene un mensaje válido
	assign accept_snoop = in_hold_valid && !last_hop && (in_hold.inval || !in_hold.reply);

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

		end_reply = 0;
		set_reply = 0;

		monitor_fail = 0;
		monitor_acquire = 0;
		monitor_release = 0;
		core_waitrequest = 1;

		in_data_ready = !in_hold_valid;

		// Maquina de estados maestra de la SRAM.
		//
		// Esta maquina define a lo que el controlador de SRAM está dándole
		// prioridad, ya que SRAM tiene un único puerto de read/write,
		// entonces tiene que decidir si le da prioridad al core o al bus.
		// 
		// ACCEPT:	Luego de todos los estados, se pasa a ACCEPT
		// CORE:	Acciones relacionadas a cada core específico (monitor, etc.)
		// SNOOP:	Vigilando memoria y "ejecutando" MESI.
		//			Esto pasa cuando llega un mensaje y el ttl del mensaje es > 0
		// REPLY:	Este core recibibió una respuesta
		unique case (state)
			ACCEPT: begin
				// Si es el último nodo en recibir el mensaje y la request no es de lectura
				if (last_hop && !in_hold.read) begin
					end_reply = in_hold_valid;	// Se termina el paso de ese mensaje
					in_data_ready = 1;
				end

				// Si no es el último salto y hay reply
				if (!last_hop && in_hold.reply && !in_hold.inval)
					in_data_ready = 1;

				if (accept_snoop)
					index_rd = in_hold.index;

				if (debug)
					index_rd = debug_index;
			end


			CORE: begin
				if (replace) begin
					// Para la línea actual, guardar en el state file que
					// ahora el estado es INVALID
					state_wr = INVALID;
					write_state = 1;

					if (state_rd == MODIFIED)
						writeback = 1;
				
				// Dependiendo del estado de la línea y de si el core quiere 
				// hacer un write
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

					{SHARED, 1'b0}: begin
						monitor_acquire = core_lock;
						core_waitrequest = 0;
					end

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

					{EXCLUSIVE, 1'b0}: begin
						monitor_acquire = core_lock;
						core_waitrequest = 0;
					end

					{EXCLUSIVE, 1'b1}: begin
						state_wr = MODIFIED;
						write_data = monitor_commit;
						write_state = monitor_commit;

						monitor_fail = !monitor_commit;
						monitor_release = core_lock;

						core_waitrequest = 0;
					end

					{MODIFIED, 1'b0}: begin
						monitor_acquire = core_lock;
						core_waitrequest = 0;
					end

					{MODIFIED, 1'b1}: begin
						write_data = monitor_commit;

						monitor_fail = !monitor_commit;
						monitor_release = core_lock;

						core_waitrequest = 0;
					end
				endcase

				if (monitor_release)
					data_wr = monitor_update;
			end

			SNOOP: begin
				index_rd = in_hold.index;
				in_data_ready = 1;

				if (snoop_hit) begin
					if (in_hold.read) begin
						set_reply = 1;

						// MESI
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
					state_wr = in_hold.inval ? EXCLUSIVE : SHARED;
					write_data = 1;
					write_state = 1;

					end_reply = 1;
				end else
					mem_begin = 1;
			end

			default: ;
		endcase

		if (writeback)
			mem_begin = 1;

	
		// Si el envío de un mensaje falló, el anillo intenta enviarlo de nuevo
		// Reintentar si hay colisiones de bus 
		retry = (mem_read_end && (write_data || write_state)) || (mem_wait && mem_begin);

		// Nótese la diferencia con un assign, ya que send puede cambiar más abajo
		lock_line = send;

		// Reintentar si quiere enviar, pero no puede porque el token no lo permite
		if (send && !may_send && !locked)
			retry = 1;

		if (retry) begin
			send = 0;
			mem_begin = 0;
			write_data = 0;
			write_state = 0;

			monitor_acquire = 0;
			monitor_release = 0;

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
		debug = 0;
		next_state = ACCEPT;

		unique case (state)
			// Le da prioridad a SNOOP, ya que la prioridad está en
			// hacer forward de mensajes.

			// Es mejor darle prioridad al SNOOP, ya que si se le da prioridad
			// a CORE, podrían suceder deadlocks o alunos mensajes nunca
			// podrían terminar de enviarse.

			// El orden de prioridad es SNOOP y REPLY, DEBUG, CORE
			ACCEPT: begin
				if (accept_snoop)
					next_state = SNOOP;
				else if (in_hold_valid && last_hop && in_hold.read)
					next_state = REPLY;
				else if (dbg_write && !debug_ready)
					debug = 1;
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
			wait_reply <= 0;

			mem_read <= 0;
			mem_write <= 0;

			debug_ready <= 0;
		end else begin
			if (send)
				wait_reply <= 1;

			if (end_reply || mem_read_end)
				wait_reply <= 0;

			if (mem_end) begin
				mem_read <= 0;
				mem_write <= 0;
			end

			if (mem_begin) begin
				mem_read <= !writeback;
				mem_write <= writeback;
			end

			debug_ready <= debug;
		end

	always_ff @(posedge clk)
		if (mem_begin) begin
			mem_tag <= writeback ? tag_rd : core_tag;
			mem_index <= index_wr;
			mem_writedata <= data_rd;
		end

endmodule
