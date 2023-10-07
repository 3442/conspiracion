`include "cache/defs.sv"

module test_ring
(
	input  logic clk,
	             rst_n
);

	logic data_0_valid, data_1_valid, data_2_valid, data_3_valid,
	      data_0_ready, data_1_ready, data_2_ready, data_3_ready;

	ring_req data_0, data_1, data_2, data_3;

	cache_ring segment_0
	(
		.core_tag(),
		.core_index(),
		.data_rd(),

		.send(),
		.send_read(),
		.send_inval(),
		.set_reply(),

		.in_data(data_3),
		.in_data_ready(data_3_ready),
		.in_data_valid(data_3_valid),

		.out_data(data_0),
		.out_data_ready(data_0_ready),
		.out_data_valid(data_0_valid),

		.in_hold(),
		.in_hold_valid(),
		.last_hop(),
		.out_stall(),

		.*
	);

	cache_ring segment_1
	(
		.core_tag(),
		.core_index(),
		.data_rd(),

		.send(),
		.send_read(),
		.send_inval(),
		.set_reply(),

		.in_data(data_0),
		.in_data_ready(data_0_ready),
		.in_data_valid(data_0_valid),

		.out_data(data_1),
		.out_data_ready(data_1_ready),
		.out_data_valid(data_1_valid),

		.in_hold(),
		.in_hold_valid(),
		.last_hop(),
		.out_stall(),

		.*
	);

	cache_ring segment_2
	(
		.core_tag(),
		.core_index(),
		.data_rd(),

		.send(),
		.send_read(),
		.send_inval(),
		.set_reply(),

		.in_data(data_1),
		.in_data_ready(data_1_ready),
		.in_data_valid(data_1_valid),

		.out_data(data_2),
		.out_data_ready(data_2_ready),
		.out_data_valid(data_2_valid),

		.in_hold(),
		.in_hold_valid(),
		.last_hop(),
		.out_stall(),

		.*
	);

	cache_ring segment_3
	(
		.core_tag(),
		.core_index(),
		.data_rd(),

		.send(),
		.send_read(),
		.send_inval(),
		.set_reply(),

		.in_data(data_2),
		.in_data_ready(data_2_ready),
		.in_data_valid(data_2_valid),

		.out_data(data_3),
		.out_data_ready(data_3_ready),
		.out_data_valid(data_3_valid),

		.in_hold(),
		.in_hold_valid(),
		.last_hop(),
		.out_stall(),

		.*
	);

endmodule
