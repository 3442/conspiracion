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
typedef fp                        vec2[2];
typedef fp                        vec4[`FLOATS_PER_VEC];
typedef vec4                      mat4[`VECS_PER_MAT];

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

typedef struct packed
{
	color8 r, g, b;
} rgb24;

typedef struct packed
{
	logic[9:0] r, g, b;
} rgb30;

typedef struct packed
{
	color8 a, r, g, b;
} rgb32;

`define FIXED_FRAC 16

`define FIXED_DIV_STAGES     8
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

typedef logic[7:0] coarse_dim;

`define GFX_MASK_SRAM_STAGES 3
`define GFX_MASK_STAGES      (1 + `GFX_MASK_SRAM_STAGES + 1)
`define GFX_SCAN_STAGES      3 // Ajustable

`define GFX_SETUP_BOUNDS_STAGES  3
`define GFX_SETUP_EDGE_STAGES    (1 + `FIXED_FMA_DOT_STAGES)
`define GFX_SETUP_OFFSETS_STAGES 2
`define GFX_SETUP_STAGES         (`GFX_SETUP_BOUNDS_STAGES \
                                 + `GFX_SETUP_EDGE_STAGES \
                                 + `GFX_SETUP_OFFSETS_STAGES)

`define GFX_FINE_STAGES 2

`define GFX_RASTER_BITS     2
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

`endif
