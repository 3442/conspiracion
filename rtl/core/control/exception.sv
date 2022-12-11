`include "core/uarch.sv"

module core_control_exception
(
	input  logic      clk,
	                  rst_n,

	input  ctrl_cycle next_cycle,
	input  logic      high_vectors,
	                  undefined,
	                  mem_fault,

	output logic      exception,
	                  exception_offset_pc,
	output psr_mode   exception_mode,
	output word       exception_vector
);

	logic[2:0] vector_offset;

	//TODO: irq, fiq, prefetch abort, swi

	assign exception = undefined || mem_fault;
	assign exception_vector = {{16{high_vectors}}, 11'b0, vector_offset, 2'b00};

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			vector_offset <= 0;
			exception_mode <= 0;
			exception_offset_pc <= 0;
		end else if(mem_fault) begin
			vector_offset <= 3'b100;
			exception_mode <= `MODE_ABT;
		end else if(undefined) begin
			vector_offset <= 3'b001;
			exception_mode <= `MODE_UND;
		end

		if(next_cycle.escalate)
			exception_offset_pc <= !mem_fault;
	end

endmodule
