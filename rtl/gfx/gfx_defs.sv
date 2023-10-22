`ifndef GFX_DEFS_SV
`define GFX_DEFS_SV

// Esto es arquitectural, no se puede ajustar sin cambiar otras cosas
`define FLOAT_BITS     16
`define FLOATS_PER_VEC 4
`define VECS_PER_MAT   4

// Target de 100MHz con float16, rounding aproximado
`define FP_ADD_STAGES 4 // ~325 LUTs
`define FP_MUL_STAGES 3 // ~119 LUTs ~1 bloque DSP

typedef logic[`FLOAT_BITS - 1:0] fp;
typedef fp                       vec2[2];
typedef fp                       vec4[`FLOATS_PER_VEC];
typedef vec4                     mat4[`VECS_PER_MAT];

typedef logic[1:0] index4;

`define INDEX4_MIN 2'b00
`define INDEX4_MAX 2'b11

`endif
