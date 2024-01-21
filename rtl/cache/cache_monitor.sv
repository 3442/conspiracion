`include "cache/defs.sv"

module cache_monitor
(
	input  logic       clk,
	                   rst_n,

	input  addr_tag    core_tag,
	input  addr_index  core_index,
	input  addr_offset core_offset,		// Alguno de los 4 cores
	input logic        core_lock,
	input  word        core_writedata,
	output logic[1:0]  core_response,

	input  line        data_rd,

	input  logic       monitor_acquire,
	                   monitor_fail,
	                   monitor_release,
	output line        monitor_update,
	output logic       monitor_commit
);

	// Este módulo provee capacidad para spin_locks (básicamente mutexes) para
	// proteger una sección de código a través de spin lock/unlock.
	// Esto básicamente es la implemenntación de las instrucciones de ARM
	// ldrex, strexeq, que originalmente no son parte ARMv4, esto implica
	// que este quad-core es un frankenstein entre ARMv4 y alguna versión
	// posterior que sí implementa esas instrucciones.


	line monitor_rd, monitor_wr;
	word update_3, update_2, update_1, update_0;
	logic dirty, done, hit, known;
	addr_tag tag;
	addr_index index;

	logic[3:0] mask, mask_clear, core_ex_mask;

	assign monitor_commit = !core_lock || (hit && known && done);
	assign monitor_update = {update_3, update_2, update_1, update_0};

	/* Avalon p. 15:
	 * - 00: OKAY - Successful response for a transaction.
	 * - 10: SLVERR - Error from an endpoint agent. Indicates an unsuccessful transaction.
	 */
	assign core_response = {monitor_fail, 1'b0};

	assign hit = tag == core_tag && index == core_index;
	assign done = monitor_rd == data_rd && mask_clear == 4'b0000;
	assign known = mask[core_offset];
	assign mask_clear = mask & ~core_ex_mask;

	always_comb begin
		{update_3, update_2, update_1, update_0} = monitor_wr;

		unique case (core_offset)
			2'b00: begin
				update_0 = core_writedata;
				core_ex_mask = 4'b0001;
			end

			2'b01: begin
				update_1 = core_writedata;
				core_ex_mask = 4'b0010;
			end

			2'b10: begin
				update_2 = core_writedata;
				core_ex_mask = 4'b0100;
			end

			2'b11: begin
				update_3 = core_writedata;
				core_ex_mask = 4'b1000;
			end
		endcase
	end

	always @(posedge clk or negedge rst_n)
		if (!rst_n) begin
			mask <= 4'b0000;
			dirty <= 0;
		end else begin
			// ldrex
			if (monitor_acquire) begin
				mask <= hit && !known && !dirty ? mask | core_ex_mask : core_ex_mask;
				dirty <= 0;
			end

			// strexeq
			if (monitor_release) begin
				mask <= hit && known ? mask_clear : 4'b0000;
				dirty <= hit && known;
			end
		end

	always_ff @(posedge clk) begin
		if (monitor_acquire) begin
			tag <= core_tag;
			index <= core_index;

			if (!hit || known || dirty || mask == 4'b0000) begin
				monitor_rd <= data_rd;
				monitor_wr <= data_rd;
			end
		end

		if (monitor_release)
			monitor_wr <= monitor_update;
	end

endmodule
