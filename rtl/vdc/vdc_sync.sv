module vdc_sync
import vdc_pkg::*;
(
	input  logic    clk,
	                rst_n,

	input  logic    csr_back_push,
	                csr_dac_enable,
	                csr_double_buff,
	input  ptr      csr_back,
	                csr_front,
	input  geom_dim csr_lines,
	                csr_stride,
	                csr_line_len,

	output logic    csr_dac_on,
	                csr_back_set,
	                csr_front_set,
	output ptr      csr_retired,
	                csr_back_next,
	                csr_front_next,

	input  logic    frame_done,

	output logic    frame_start,
	output ptr      front_base,
	output geom_dim lines,
	                stride,
	                line_len
);

	enum int unsigned
	{
		OFF,
		LOCK,
		START,
		RUN
	} next_state, state;

	logic lock;

	assign csr_back_set = lock & csr_double_buff & ~csr_back_push;
	assign csr_back_next = csr_front;
	assign csr_front_set = csr_back_set;
	assign csr_front_next = csr_back;

	always_comb begin
		next_state = state;
		unique case (state)
			OFF:
				if (csr_dac_enable)
					next_state = LOCK;

			LOCK:
				if (~csr_back_push)
					next_state = csr_dac_enable ? START : OFF;

			START:
				next_state = RUN;

			RUN:
				if (frame_done)
					next_state = LOCK;
		endcase

		unique case (state)
			OFF:     csr_dac_on = 0;
			default: csr_dac_on = 1;
		endcase

		unique case (state)
			LOCK:    lock = 1;
			default: lock = 0;
		endcase

		unique case (state)
			START:   frame_start = 1;
			default: frame_start = 0;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			state <= OFF;
		else
			state <= next_state;

	always_ff @(posedge clk) begin
		if (csr_back_push)
			csr_retired <= csr_back;

		if (lock) begin
			lines <= csr_lines;
			stride <= csr_stride;
			line_len <= csr_line_len;
			front_base <= csr_double_buff ? csr_back : csr_front;
		end
	end

endmodule
