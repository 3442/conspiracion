module gfx_raster
(
	input  logic       clk,
	                   rst_n,

	       gfx_pkts.rx geometry,

	       gfx_pkts.tx coverage
);

	import gfx::*;

	gfx_raster_bounds setup_bounds
	(
		.clk,
		.rst_n,

		.geometry,

		.edges_ref(bounds_edges_ref),
		.edges_vtx(bounds_edges_vtx),
		.edges_span(bounds_edges_span),
		.edges_ready(bounds_edges_ready),
		.edges_valid(bounds_edges_valid),
		.edges_geom_id(bounds_edges_geom_id)
	);

	word bounds_edges_geom_id;
	logic bounds_edges_ready, bounds_edges_valid;
	vtx_xy bounds_edges_vtx;
	fixed_xy bounds_edges_ref;
	raster_prec_xy bounds_edges_span;

	gfx_raster_edges setup_edges
	(
		.clk,
		.rst_n,

		.bounds_ref(bounds_edges_ref),
		.bounds_vtx(bounds_edges_vtx),
		.bounds_span(bounds_edges_span),
		.bounds_ready(bounds_edges_ready),
		.bounds_valid(bounds_edges_valid),
		.bounds_geom_id(bounds_edges_geom_id),

		.coarse_ref(edges_coarse_ref),
		.coarse_base(edges_coarse_base),
		.coarse_span(edges_coarse_span),
		.coarse_ready(edges_coarse_ready),
		.coarse_valid(edges_coarse_valid),
		.coarse_geom_id(edges_coarse_geom_id),
		.coarse_offsets(edges_coarse_offsets)
	);

	word edges_coarse_geom_id;
	fixed edges_coarse_base;
	logic edges_coarse_ready, edges_coarse_valid;
	fixed_xy edges_coarse_ref;
	raster_prec_xy edges_coarse_span;
	raster_offsets_xy edges_coarse_offsets;

	gfx_raster_coarse coarse
	(
		.clk,
		.rst_n,

		.edges_ref(edges_coarse_ref),
		.edges_base(edges_coarse_base),
		.edges_span(edges_coarse_span),
		.edges_ready(edges_coarse_ready),
		.edges_valid(edges_coarse_valid),
		.edges_geom_id(edges_coarse_geom_id),
		.edges_offsets(edges_coarse_offsets),

		.fine_ref(coarse_fine_ref),
		.fine_ready(coarse_fine_ready),
		.fine_valid(coarse_fine_valid),
		.fine_corner(coarse_fine_corner),
		.fine_geom_id(coarse_fine_geom_id),
		.fine_offsets(coarse_fine_offsets)
	);

	word coarse_fine_geom_id;
	fixed coarse_fine_corner;
	logic coarse_fine_ready, coarse_fine_valid;
	fixed_xy coarse_fine_ref;
	raster_offsets_xy coarse_fine_offsets;

	gfx_raster_fine fine
	(
		.clk,
		.rst_n,

		.coarse_ref(coarse_fine_ref),
		.coarse_ready(coarse_fine_ready),
		.coarse_valid(coarse_fine_valid),
		.coarse_corner(coarse_fine_corner),
		.coarse_geom_id(coarse_fine_geom_id),
		.coarse_offsets(coarse_fine_offsets),

		.coverage
	);

endmodule

module gfx_raster_bounds
(
	input  logic               clk,
	                           rst_n,

	       gfx_pkts.rx         geometry,

	input  logic               edges_ready,
	output logic               edges_valid,
	output gfx::word           edges_geom_id,
	output gfx::fixed_xy       edges_ref,
	output gfx::raster_prec_xy edges_span,
	output gfx::vtx_xy         edges_vtx
);

	import gfx::*;

	enum int unsigned
	{
		IN_GEOM_ID,
		IN_DIM_X,
		IN_DIM_Y
	} in_state;

	enum int unsigned
	{
		VTX_A,
		VTX_B,
		VTX_C
	} vtx_state;

	logic a_lt_b, a_lt_c, b_lt_c, edges_handshake, geom_complete, geom_last,
	      geom_recv, in_vtx, next_dim, new_vtx;

	logic end_new_dim, end_valid, vtx_valid, lt_new_dim, lt_valid, minmax_new_dim, minmax_valid;

	fixed geom_data;
	vtx_fixed dim_vtx, dim_vtx_x, dim_vtx_y;
	raster_prec max, min;

	assign geom_recv = geometry.tready & geometry.tvalid;
	assign edges_handshake = edges_valid & edges_ready;

	assign edges_vtx.a.x = dim_vtx_x.a;
	assign edges_vtx.a.y = dim_vtx_y.a;
	assign edges_vtx.b.x = dim_vtx_x.b;
	assign edges_vtx.b.y = dim_vtx_y.b;
	assign edges_vtx.c.x = dim_vtx_x.c;
	assign edges_vtx.c.y = dim_vtx_y.c;

	assign geometry.tready = edges_handshake | ~geom_complete;

	always_comb begin
		unique case (vtx_state)
			VTX_C:   next_dim = geom_recv;
			default: next_dim = 0;
		endcase

		unique case (in_state)
			IN_DIM_Y: geom_last = next_dim;
			default:  geom_last = 0;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			in_state <= IN_GEOM_ID;
			vtx_state <= VTX_A;

			in_vtx <= 0;
			new_vtx <= 0;
			geom_complete <= 0;

			lt_valid <= 0;
			end_valid <= 0;
			vtx_valid <= 0;
			edges_valid <= 0;
			minmax_valid <= 0;

			lt_new_dim <= 0;
			end_new_dim <= 0;
			minmax_new_dim <= 0;

			edges_geom_id <= 'x;
		end else begin
			end_valid <= 0;
			vtx_valid <= end_valid;
			lt_valid <= vtx_valid;
			minmax_valid <= lt_valid;

			if (~edges_valid | edges_ready)
				edges_valid <= minmax_valid;

			geom_complete <= (geom_complete | geom_last) & ~edges_handshake;

			unique case (in_state)
				IN_GEOM_ID:
					if (geom_recv) begin
						in_state <= IN_DIM_X;

						in_vtx <= 1;
						edges_geom_id <= geometry.tdata;
					end

				IN_DIM_X:
					if (next_dim)
						in_state <= IN_DIM_Y;

				IN_DIM_Y:
					if (next_dim) begin
						in_state <= IN_GEOM_ID;

						in_vtx <= 0;
						end_valid <= 1;
					end
			endcase

			new_vtx <= 0;

			lt_new_dim <= 0;
			minmax_new_dim <= lt_new_dim;
			end_new_dim <= minmax_new_dim;

			unique case (vtx_state)
				VTX_A: begin
					if (in_vtx & geom_recv) begin
						new_vtx <= 1;
						vtx_state <= VTX_B;
					end

					if (new_vtx) begin
						dim_vtx.c <= geom_data;
						lt_new_dim <= 1;
					end
				end

				VTX_B: begin
					if (geom_recv) begin
						new_vtx <= 1;
						vtx_state <= VTX_C;
					end

					if (new_vtx)
						dim_vtx.a <= geom_data;
				end

				VTX_C: begin
					if (geom_recv) begin
						new_vtx <= 1;
						vtx_state <= VTX_A;
					end

					if (new_vtx)
						dim_vtx.b <= geom_data;
				end
			endcase

			if (in_state == IN_DIM_Y & next_dim)
				assert(geometry.tlast);
		end

	always_ff @(posedge clk) begin
		geom_data <= geometry.tdata;

		a_lt_b <= $signed(dim_vtx.a) < $signed(dim_vtx.b);
		a_lt_c <= $signed(dim_vtx.a) < $signed(dim_vtx.c);
		b_lt_c <= $signed(dim_vtx.b) < $signed(dim_vtx.c);

		// Realmente no son 'x' o 'y' hasta cuando edges_valid = 1
		if (lt_new_dim) begin
			dim_vtx_y <= dim_vtx;
			dim_vtx_x <= dim_vtx_y;
		end

		if (a_lt_b) begin
			min <= a_lt_c ? dim_vtx_y.a : dim_vtx_y.c;
			max <= b_lt_c ? dim_vtx_y.c : dim_vtx_y.b;
		end else begin
			min <= b_lt_c ? dim_vtx_y.b : dim_vtx_y.c;
			max <= a_lt_c ? dim_vtx_y.c : dim_vtx_y.a;
		end

		{min.fine, min.sub} <= '0;
		{max.fine, max.sub} <= '0;

		edges_ref.y <= min;
		edges_span.y <= max - min;

		if (end_new_dim) begin
			edges_ref.x <= edges_ref.y;
			edges_span.x <= edges_span.y;
		end
	end

endmodule

module gfx_raster_edges
(
	input  logic                  clk,
	                              rst_n,

	input  logic                  bounds_valid,
	input  gfx::word              bounds_geom_id,
	input  gfx::fixed_xy          bounds_ref,
	input  gfx::raster_prec_xy    bounds_span,
	input  gfx::vtx_xy            bounds_vtx,
	output logic                  bounds_ready,

	input  logic                  coarse_ready,
	output logic                  coarse_valid,
	output gfx::word              coarse_geom_id,
	output gfx::fixed_xy          coarse_ref,
	output gfx::raster_prec_xy    coarse_span,
	output gfx::fixed             coarse_base,
	output gfx::raster_offsets_xy coarse_offsets
);

	import gfx::*;

	logic coarse_handshake, coarse_stall, offsets_flow;
	fixed_xy delta, inc, p, q;

	// - 3 porque empieza antes que offsets y porque coarse valid va al final
	logic[FIXED_DOTADD_DEPTH - 3:0] dotadd_valid;

	enum int unsigned
	{
		EDGE_AB,
		EDGE_BC,
		EDGE_CA
	} state;

	assign coarse_stall = coarse_valid & ~coarse_ready;
	assign coarse_handshake = coarse_valid & coarse_ready;

	gfx_fixed_dotadd edge_base
	(
		.clk,
		.c(0),
		.q(coarse_base),
		.a0(delta.x),
		.b0(inc.x),
		.a1(delta.y),
		.b1(inc.y),
		.stall(coarse_stall)
	);

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			state <= EDGE_AB;

			p <= 'x;
			q <= 'x;
			coarse_ref <= 'x;
			coarse_geom_id <= 'x;

			bounds_ready <= 0;
			coarse_valid <= 0;
			offsets_flow <= 1;

			for (int i = 0; i < $bits(dotadd_valid) - 1; ++i)
				dotadd_valid[i] <= 0;
		end else begin
			dotadd_valid[0] <= 0;
			for (int i = 1; i < $bits(dotadd_valid); ++i)
				dotadd_valid[i] <= dotadd_valid[i - 1];

			if (~coarse_stall)
				coarse_valid <= dotadd_valid[$bits(dotadd_valid) - 1];

			bounds_ready <= 0;

			unique case (state)
				EDGE_AB: begin
					if (bounds_valid)
						state <= EDGE_BC;

					coarse_ref <= bounds_ref;
					coarse_span <= bounds_span;
					coarse_geom_id <= bounds_geom_id;

					p <= bounds_vtx.a;
					q <= bounds_vtx.b;
				end

				EDGE_BC: begin
					state <= EDGE_CA;
					bounds_ready <= 1;

					p <= bounds_vtx.b;
					q <= bounds_vtx.c;
				end

				EDGE_CA: begin
					p <= bounds_vtx.c;
					q <= bounds_vtx.a;

					// Esto ocurre justamente en un momento en que ab, bc, ca
					// quedan todos en sus lugares correctos en la pipeline
					if (offsets_flow) begin
						offsets_flow <= 0;
						dotadd_valid[0] <= 1;
					end else begin
						offsets_flow <= coarse_handshake;

						if (coarse_handshake)
							state <= EDGE_AB;
					end
				end
			endcase
		end

	always_ff @(posedge clk) begin
		//TODO: top-left rule
		delta.x <= coarse_ref.x - q.x;
		delta.y <= coarse_ref.y - q.y;

		if (offsets_flow) begin
			inc.x <= p.y - q.y;
			inc.y <= q.x - p.x;

			coarse_offsets.x <= make_raster_offsets(inc.x);
			coarse_offsets.y <= make_raster_offsets(inc.y);
		end
	end

endmodule

module gfx_raster_coarse
(
	input  logic                  clk,
	                              rst_n,

	input  logic                  edges_valid,
	input  gfx::word              edges_geom_id,
	input  gfx::fixed_xy          edges_ref,
	input  gfx::raster_prec_xy    edges_span,
	input  gfx::fixed             edges_base,
	input  gfx::raster_offsets_xy edges_offsets,
	output logic                  edges_ready,

	input  logic                  fine_ready,
	output logic                  fine_valid,
	output gfx::word              fine_geom_id,
	output gfx::fixed_xy          fine_ref,
	output gfx::fixed             fine_corner,
	output gfx::raster_offsets_xy fine_offsets
);

	import gfx::*;

	enum int unsigned
	{
		SETUP,
		TEST_AB,
		TEST_BC,
		TEST_CA,
		OUT
	} state;

	struct
	{
		fixed cur,
		      next,
		      prev;
	} corner, edge_fn, vertical;

	struct
	{
		raster_offsets_xy cur,
		                  next,
		                  prev;
	} offsets;

	fixed edge_test, reference_x, vertical_inc;
	logic edges_recv, end_x, end_y, mask, mask_reset, new_geom, test_flow, out_flow;
	fixed_xy max_offset, min_offset, test_offset;
	raster_coarse_xy stride;
	raster_coarse_dim width;
	raster_offsets_xy next_offsets;

	function fixed coarse_offset(raster_offsets offsets);
		return raster_idx(offsets, RASTER_BITS'(1)) << RASTER_BITS;
	endfunction

	assign end_x = stride.x == '0;
	assign end_y = stride.y == '0;

	assign edge_test = edge_fn.cur + test_offset.x + test_offset.y;
	assign vertical_inc = vertical.cur + coarse_offset(offsets.cur.y);

	assign fine_corner = corner.cur;
	assign fine_offsets = offsets.cur; // Vuelve a cur luego de 3 ciclos

	assign min_offset.x = raster_idx(next_offsets.x, RASTER_BITS'(0));
	assign min_offset.y = raster_idx(next_offsets.y, RASTER_BITS'(0));
	assign max_offset.x = raster_idx(next_offsets.x, RASTER_BITS'(RASTER_SIZE - 1));
	assign max_offset.y = raster_idx(next_offsets.y, RASTER_BITS'(RASTER_SIZE - 1));
	assign next_offsets = edges_recv ? edges_offsets : offsets.next;

	always_comb begin
		unique case (state)
			SETUP:   new_geom = 1;
			default: new_geom = 0;
		endcase

		unique case (state)
			TEST_AB: mask_reset = 1;
			default: mask_reset = 0;
		endcase

		unique case (state)
			TEST_BC: edges_ready = 1;
			default: edges_ready = 0;
		endcase

		unique case (state)
			SETUP, TEST_AB, TEST_BC:
				edges_recv = 1;

			default:
				edges_recv = 0;
		endcase

		unique case (state)
			OUT:     fine_valid = mask;
			default: fine_valid = 0;
		endcase

		unique case (state)
			OUT: begin
				out_flow = ~mask | fine_ready;
				test_flow = 0;
			end

			default: begin
				out_flow = 0;
				test_flow = 1;
			end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n)
			state <= SETUP;
		else
			unique case (state)
				SETUP:
					if (edges_valid)
						state <= TEST_AB;

				TEST_AB:
					state <= TEST_BC;

				TEST_BC:
					state <= TEST_CA;

				TEST_CA:
					state <= OUT;

				OUT:
					if (out_flow)
						state <= end_x & end_y ? SETUP : TEST_AB;
			endcase

	always_ff @(posedge clk) begin
		if (new_geom) begin
			width <= edges_span.x.coarse;
			stride.x <= edges_span.x.coarse;
			stride.y <= edges_span.y.coarse;
			reference_x <= edges_ref.x;

			fine_ref <= edges_ref;
			fine_geom_id <= edges_geom_id;
		end

		if (out_flow) begin
			stride.x <= stride.x - 1;
			fine_ref.x.fint <= fine_ref.x.fint + ($bits(fixed_int))'(RASTER_SIZE);

			if (end_x) begin
				fine_ref.x <= reference_x;
				fine_ref.y.fint <= fine_ref.y.fint + ($bits(fixed_int))'(RASTER_SIZE);

				stride.x <= width;
				stride.y <= stride.y - 1;
			end
		end

		if (test_flow) begin
			offsets.cur <= next_offsets;
			offsets.next <= offsets.prev;
			offsets.prev <= offsets.cur;

			vertical.cur <= vertical.next;
			vertical.next <= vertical.prev;
			vertical.prev <= vertical.cur;

			edge_fn.cur <= edge_fn.next;
			edge_fn.next <= edge_fn.prev;
			edge_fn.prev <= edge_fn.cur + coarse_offset(offsets.cur.x);

			if (end_x) begin
				edge_fn.prev <= vertical_inc;
				vertical.prev <= vertical_inc;
			end

			corner.cur <= corner.next;
			corner.next <= corner.prev;
			corner.prev <= edge_fn.cur;

			if (coarse_offset(next_offsets.x) >= 'sd0)
				test_offset.x <= max_offset.x;
			else
				test_offset.x <= min_offset.x;

			if (coarse_offset(next_offsets.y) >= 'sd0)
				test_offset.y <= max_offset.y;
			else
				test_offset.y <= min_offset.y;

			mask <= (mask | mask_reset) & (edge_test >= 0);
		end

		if (edges_recv) begin
			edge_fn.cur <= edges_base;
			vertical.cur <= edges_base;
		end
	end

endmodule

module gfx_raster_fine
(
	input  logic                  clk,
	                              rst_n,

	input  logic                  coarse_valid,
	input  gfx::word              coarse_geom_id,
	input  gfx::fixed_xy          coarse_ref,
	input  gfx::fixed             coarse_corner,
	input  gfx::raster_offsets_xy coarse_offsets,
	output logic                  coarse_ready,

	       gfx_pkts.tx            coverage
);

	import gfx::*;

	enum int unsigned
	{
		IN_C,
		IN_A,
		IN_B,
		IN_MASK
	} in_state;

	enum int unsigned
	{
		OUT_ACCEPT,
		OUT_GEOM_ID,
		OUT_POS,
		OUT_MASK,
		OUT_BARY_C,
		OUT_BARY_A,
		OUT_BARY_B
	} out_state;

	struct
	{
		fixed cur,
		      next,
		      prev;
	} corner;

	struct
	{
		raster_offsets_xy cur,
		                  next,
		                  prev;
	} offsets;

	logic begin_bary, hold_block, in_valid, mask_in_clean,
	      mask_in_reset, new_block, out_last;

	word geom_id;
	fixed bary_coord;
	lane_no lane, lane_ctz, lane_hold;
	fixed_xy block_ref;
	lane_mask mask_in, mask, mask_ctz;
	raster_index lane_x, lane_y;
	logic[$bits(lane_ctz):0] ctz_count;

	function shword ref_half(raster_prec dim);
		return dim.coarse[$bits(shword) - 1:0];
	endfunction

	assign lane_ctz = ctz_count[$bits(lane_ctz) - 1:0];
	assign in_valid = mask_in_clean & |mask_in;
	assign out_last = ~|mask;
	assign {lane_y, lane_x} = lane;

	// **IMPORTANTE**: Esto va a fallar a partir de RASTER_BITS >= 3,
	// ya que la fsm asume que ctz termina en 3 ciclos o menos

	gfx_ctz #(RASTER_COARSE_FRAGS) ctz
	(
		.clk,
		.value(mask_ctz),
		.ctz(ctz_count)
	);

	always_comb begin
		unique case (out_state)
			OUT_ACCEPT: new_block = 1;
			default:    new_block = 0;
		endcase

		unique case (out_state)
			OUT_ACCEPT: mask_ctz = mask_in;
			default:    mask_ctz = mask;
		endcase

		unique case (out_state)
			OUT_ACCEPT: coverage.tvalid = 0;
			default:    coverage.tvalid = 1;
		endcase

		unique case (out_state)
			OUT_MASK: begin_bary = coverage.tvalid;
			default:  begin_bary = 0;
		endcase

		unique case (out_state)
			OUT_BARY_B: coverage.tlast = out_last;
			default:    coverage.tlast = 0;
		endcase

		unique case (out_state)
			OUT_GEOM_ID:
				coverage.tdata = geom_id;

			OUT_POS:
				coverage.tdata = {ref_half(coarse_ref.y), ref_half(block_ref.x)};

			OUT_MASK:
				coverage.tdata = {{($bits(word) - $bits(mask)){1'b0}}, mask};

			OUT_BARY_C, OUT_BARY_A, OUT_BARY_B:
				coverage.tdata = bary_coord;

			default:
				coverage.tdata = 'x;
		endcase

		unique case (out_state)
			OUT_MASK:
				lane = lane_ctz;

			default:
				lane = lane_hold;
		endcase

		unique case (in_state)
			IN_C:    coarse_ready = new_block;
			default: coarse_ready = 0;
		endcase

		unique case (in_state)
			IN_C:    hold_block = new_block;
			IN_A:    hold_block = 1;
			IN_B:    hold_block = 1;
			IN_MASK: hold_block = 0;
		endcase

		unique case (in_state)
			IN_C:    mask_in_reset = 1;
			default: mask_in_reset = 0;
		endcase

		unique case (in_state)
			IN_MASK: mask_in_clean = 1;
			default: mask_in_clean = 0;
		endcase
	end

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			in_state <= IN_C;
			out_state <= OUT_ACCEPT;
		end else begin
			unique case (in_state)
				IN_C:
					if (coarse_valid & new_block)
						in_state <= IN_A;

				IN_A:
					in_state <= IN_B;

				IN_B:
					in_state <= IN_MASK;

				IN_MASK:
					in_state <= IN_C;
			endcase

			unique case (out_state)
				OUT_ACCEPT:
					if (in_valid)
						out_state <= OUT_GEOM_ID;

				OUT_GEOM_ID:
					if (coverage.tready)
						out_state <= OUT_POS;

				OUT_POS:
					if (coverage.tready)
						out_state <= OUT_MASK;

				OUT_MASK:
					if (coverage.tready)
						out_state <= OUT_BARY_C;

				OUT_BARY_C:
					if (coverage.tready)
						out_state <= OUT_BARY_A;

				OUT_BARY_A:
					if (coverage.tready)
						out_state <= OUT_BARY_B;

				OUT_BARY_B:
					if (coverage.tready)
						out_state <= out_last ? OUT_ACCEPT : OUT_BARY_C;
			endcase
		end

	always_ff @(posedge clk) begin
		// Prueba paralela de signos, esto hace el heavy lifting de fine raster
		// Nótese que muchos sumadores serán eliminados en síntesis
		for (int i = 0; i < RASTER_SIZE; ++i)
			for (int j = 0; j < RASTER_SIZE; ++j)
				mask_in[i * RASTER_SIZE + j] <=
					(mask_in[i * RASTER_SIZE + j] | mask_in_reset)
					& (coarse_corner
						+ raster_idx(coarse_offsets.y, RASTER_BITS'(i))
						+ raster_idx(coarse_offsets.x, RASTER_BITS'(j))
						>= 'sd0);

		// Recalculamos las coordenadas baricéntricas de cada fragmento que
		// no haya sido descartado. La razón de esto es evitar almacenar y
		// luego multiplexar las coordenadas de un bloque entero (48 words).
		if (coverage.tready)
			bary_coord <= corner.next
				+ raster_idx(offsets.next.y, RASTER_BITS'(lane_y))
				+ raster_idx(offsets.next.x, RASTER_BITS'(lane_x));

		if (new_block & mask_in_reset) begin
			geom_id <= coarse_geom_id;
			block_ref <= coarse_ref;
		end

		// new_block = 0 => coverage.tvalid = 1
		if (new_block | coverage.tready) begin
			corner.cur <= corner.next;
			corner.next <= corner.prev;
			corner.prev <= corner.cur;

			offsets.cur <= offsets.next;
			offsets.next <= offsets.prev;
			offsets.prev <= offsets.cur;
		end

		if (hold_block) begin
			// Para prev en vez de cur para que los primeros valores queden en
			// cur justamente al llegar a OUT_BARY_C
			corner.prev <= coarse_corner;
			offsets.prev <= coarse_offsets;
		end

		if (new_block)
			mask <= mask_in;

		if (begin_bary) begin
			mask <= mask & (mask - 1);
			lane_hold <= lane_ctz;
		end
	end

endmodule
