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

typedef logic[`FLOAT_BITS - 1:0] fp;
typedef fp                       vec2[2];
typedef fp                       vec4[`FLOATS_PER_VEC];
typedef vec4                     mat4[`VECS_PER_MAT];

typedef logic[1:0] index4;

`define INDEX4_MIN 2'b00
`define INDEX4_MAX 2'b11

typedef logic[9:0]  y_coord;
typedef logic[8:0]  x_coord;
typedef logic[18:0] linear_coord;
typedef logic[19:0] half_coord;

`define GFX_X_RES      640
`define GFX_Y_RES      480
`define GFX_LINEAR_RES (`GFX_X_RES * `GFX_Y_RES)

typedef struct packed
{
	logic[7:0] r, g, b;
} rgb24;

typedef struct packed
{
	logic[9:0] r, g, b;
} rgb30;

`define GFX_MASK_SRAM_STAGES 3
`define GFX_MASK_STAGES      (1 + `GFX_MASK_SRAM_STAGES + 1)
`define GFX_SCAN_STAGES      3 // Ajustable

`endif
