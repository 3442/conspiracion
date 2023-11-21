`ifndef GFX_DEFS_SV
`define GFX_DEFS_SV

// Esto es arquitectural, no se puede ajustar sin cambiar otras cosas
`define FLOAT_BITS     16
`define FLOATS_PER_VEC 4
`define VECS_PER_MAT   4

// Target de 200MHz (reloj es 143MHz) con float16, rounding aproximado
`define FP_ADD_STAGES 10 // ~401 LUTs
`define FP_MUL_STAGES 5  // ~144 LUTs ~1 bloque DSP
`define FP_INV_STAGES 3  // ~178 LUTs ~1 bloque DSP

typedef logic[`FLOAT_BITS - 1:0]  fp;
typedef fp[1:0]                   vec2;
typedef fp[`FLOATS_PER_VEC - 1:0] vec4;
typedef vec4[`VECS_PER_MAT - 1:0] mat4;

`define FP_UNIT 16'h3c00

typedef struct packed
{
	fp x, y, z, w;
} attr4;

typedef logic[1:0] index4;

`define INDEX4_MIN 2'b00
`define INDEX4_MAX 2'b11

typedef logic[8:0]  x_coord;
typedef logic[9:0]  y_coord;
typedef logic[9:0]  xy_coord;
typedef logic[18:0] linear_coord;
typedef logic[19:0] half_coord;

`define GFX_X_RES      640
`define GFX_Y_RES      480
`define GFX_LINEAR_RES (`GFX_X_RES * `GFX_Y_RES)

`define COLOR_CHANNELS 4

typedef logic[7:0] color8;
typedef logic[9:0] color10;

typedef struct packed
{
	color8 r, g, b;
} rgb24;

typedef struct packed
{
	color10 r, g, b;
} rgb30;

typedef struct packed
{
	color8 a, r, g, b;
} rgb32;

`define FIXED_FRAC 16

`define FIXED_DIV_PIPES      2
`define FIXED_DIV_STAGES     (`FIXED_DIV_PIPES + $bits(fixed) + `FIXED_FRAC)
`define FIXED_FMA_STAGES     5
`define FIXED_FMA_DOT_STAGES (2 * `FIXED_FMA_STAGES)
`define LERP_STAGES          `FIXED_FMA_DOT_STAGES

typedef logic signed[31:0] fixed;
typedef fixed[2:0]         fixed_tri;

`define EDGE_P0_TO_P1 0
`define EDGE_P1_TO_P2 1
`define EDGE_P2_TO_P0 2

typedef struct packed
{
	fixed x, y;
} raster_xy;

typedef struct packed
{
	fixed z, w;
} raster_zw;

typedef struct packed
{
	raster_xy xy;
	raster_zw zw;
} raster_xyzw;

typedef logic[8:0] coarse_dim;

`define GFX_MASK_SRAM_STAGES 3
`define GFX_MASK_STAGES      (1 + `GFX_MASK_SRAM_STAGES + 1)

`define GFX_SCANOUT_FIFO_DEPTH 16 // Ajustable

`define GFX_SETUP_BOUNDS_STAGES  3
`define GFX_SETUP_EDGE_STAGES    (1 + `FIXED_FMA_DOT_STAGES)
`define GFX_SETUP_OFFSETS_STAGES 2
`define GFX_SETUP_STAGES         (`GFX_SETUP_BOUNDS_STAGES \
                                 + `GFX_SETUP_EDGE_STAGES \
                                 + `GFX_SETUP_OFFSETS_STAGES)

`define GFX_FINE_STAGES 2

`define GFX_RASTER_BITS     1 // Solía ser 2, pero la FPGA no da para tanto
`define GFX_RASTER_SUB_BITS 4
`define GFX_RASTER_PAD_BITS ($bits(fixed) - $bits(coarse_dim) - `FIXED_FRAC - `GFX_RASTER_BITS - 1)
`define GFX_RASTER_SIZE     (1 << `GFX_RASTER_BITS)
`define GFX_RASTER_OFFSETS  (1 << (2 * `GFX_RASTER_BITS))

typedef struct packed
{
	logic[`GFX_RASTER_SUB_BITS - 1:0]               num;
	logic[`FIXED_FRAC - `GFX_RASTER_SUB_BITS - 1:0] prec;
} raster_sub;

typedef struct packed
{
	logic                             sign;
	logic[`GFX_RASTER_PAD_BITS - 1:0] padding;
	coarse_dim                        coarse;
	logic[`GFX_RASTER_BITS - 1:0]     fine;
	raster_sub                        sub;
} raster_prec;

typedef struct packed
{
	raster_prec x, y;
} raster_xy_prec;

typedef fixed[`GFX_RASTER_OFFSETS - 1:0] raster_offsets;
typedef raster_offsets[2:0]              raster_offsets_tri;

`define GFX_FINE_LANES (`GFX_RASTER_SIZE * `GFX_RASTER_SIZE)

typedef struct packed
{
	xy_coord x, y;
} frag_xy;

typedef frag_xy[`GFX_FINE_LANES - 1:0]   frag_xy_lanes;
typedef logic[`GFX_FINE_LANES - 1:0]     paint_lanes;
typedef fixed[`COLOR_CHANNELS - 1:0]     color_lerp_lanes;
typedef fixed_tri[`GFX_FINE_LANES - 1:0] bary_lanes;

typedef struct packed
{
	linear_coord addr;
	rgb32        color;
} frag_paint;

`define GFX_FRAG_ADDR_STAGES  3
`define GFX_FRAG_BARY_STAGES  (`FIXED_DIV_STAGES + 2 + `FIXED_DIV_STAGES)
`define GFX_FRAG_SHADE_STAGES (`LERP_STAGES + 1)
`define GFX_FRAG_STAGES       (`GFX_FRAG_BARY_STAGES + `GFX_FRAG_SHADE_STAGES)

`define GFX_MEM_WORD_ADDR_BITS 25
`define GFX_MEM_DATA_BITS      16 // No puedo hacer nada al respecto
`define GFX_MEM_SUBWORD_BITS   ($clog2(`GFX_MEM_DATA_BITS / 8))
`define GFX_MEM_ADDR_BITS      (`GFX_MEM_WORD_ADDR_BITS + `GFX_MEM_SUBWORD_BITS)
`define GFX_MEM_RESPONSE_DEPTH 2 // Ajustar
`define GFX_MEM_TRANS_DEPTH    4 // NO TOCAR, ver `GFX_MEM_MAX_PENDING_READS
`define GFX_MEM_DISPATCH_DEPTH 8 // Nótese que platform.vram_0.s1.maximumPendingReadTransactions = 7

// NO TOCAR. Esto debe coincidir perfectamente con gfx_hw.tcl
`define GFX_VRAM_MAX_PENDING_READS 7 // platform.vram_0.s1.maximumPendingReadTransactions
`define GFX_MEM_MAX_PENDING_READS  (1 + `GFX_MEM_TRANS_DEPTH + 1 + `GFX_VRAM_MAX_PENDING_READS)

typedef logic[`GFX_MEM_DATA_BITS - 1:0]      vram_word;
typedef logic[`GFX_MEM_ADDR_BITS - 1:0]      vram_byte_addr;
typedef logic[`GFX_MEM_WORD_ADDR_BITS - 1:0] vram_addr;

`define GFX_INSN_BITS         32
`define GFX_INSN_ADDR_BITS    (`GFX_MEM_WORD_ADDR_BITS - $clog2(`GFX_INSN_BITS / `GFX_MEM_DATA_BITS))
`define GFX_INSN_SUBWORD_BITS (`GFX_MEM_ADDR_BITS - `GFX_INSN_ADDR_BITS)
`define GFX_LANE_BITS         $bits(mat4)
`define GFX_LANE_ADDR_BITS    (`GFX_MEM_WORD_ADDR_BITS - $clog2(`GFX_LANE_BITS / `GFX_MEM_DATA_BITS))
`define GFX_LANE_SUBWORD_BITS (`GFX_MEM_ADDR_BITS - `GFX_LANE_ADDR_BITS)
`define GFX_INSN_BITS_IN_LANE (`GFX_LANE_SUBWORD_BITS - `GFX_INSN_SUBWORD_BITS)

typedef logic[`GFX_INSN_BITS - 1:0]      insn_word;
typedef logic[`GFX_LANE_BITS - 1:0]      lane_word;
typedef logic[`GFX_INSN_ADDR_BITS - 1:0] vram_insn_addr;
typedef logic[`GFX_LANE_ADDR_BITS - 1:0] vram_lane_addr;

typedef logic[5:0]  cmd_addr;
typedef logic[31:0] cmd_word;

`define GFX_CMD_REG_ID          2'b00
`define GFX_CMD_REG_SCAN        2'b01
`define GFX_CMD_REG_HEADER_BASE 2'b10
`define GFX_CMD_REG_HEADER_SIZE 2'b11

typedef struct packed
{
	logic[$bits(cmd_word) - $bits(vram_insn_addr) - `GFX_INSN_SUBWORD_BITS - 1:0] pad;
	vram_insn_addr                                                                addr;
	logic[`GFX_INSN_SUBWORD_BITS - 1:0]                                           sub;
} cmd_insn_ptr;

typedef struct packed
{
	logic[$bits(cmd_word) - $bits(vram_lane_addr) - `GFX_LANE_SUBWORD_BITS - 1:0] pad;
	vram_lane_addr                                                                addr;
	logic[`GFX_LANE_SUBWORD_BITS - 1:0]                                           sub;
} cmd_lane_ptr;

`define GFX_FETCH_FIFO_DEPTH 8

`define GFX_BATCH_FIFO_DEPTH 4
`define GFX_SP_LANES         `VECS_PER_MAT

typedef logic[`GFX_SP_LANES - 1:0]   lane_mask;
typedef logic[`FLOATS_PER_VEC - 1:0] vec_mask;

typedef logic[`FLOATS_PER_VEC - 1:0][$clog2(`FLOATS_PER_VEC) - 1:0] swizzle_lanes;

typedef logic[2:0] vreg_num;

typedef struct packed
{
	logic stream,
	      combiner,
	      shuffler;
} ex_units;

typedef struct packed
{
	logic         is_swizzle,
	              is_broadcast;
	fp            imm;
	vec_mask      select_mask;
	swizzle_lanes swizzle_op;
} shuffler_deco;

typedef struct packed
{
	logic         writeback,
	              read_src_a,
	              read_src_b,
	              clear_lanes;
	vreg_num      dst,
	              src_a,
	              src_b;
	ex_units      ex;
	shuffler_deco shuffler;
} insn_deco; // "insn_decode" ya existe en core, esto es confuso pero lo hice por tiempo

typedef struct packed
{
	vreg_num dst;
	mat4     data;
} wb_op;

`define GFX_SP_COMBINER_FIFO_DEPTH 4 // TODO: optimizar esto

`define GFX_SP_WB_STAGES 2

`endif
