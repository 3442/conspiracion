`ifndef GFX_DEFS_SV
`define GFX_DEFS_SV

`define FP_ADD_STAGES 13
`define FP_MUL_STAGES 6

`define FLOATS_PER_VEC 4
`define VECS_PER_MAT   4

typedef logic[31:0] fp;
typedef fp          vec4[`FLOATS_PER_VEC];
typedef vec4        mat4[`VECS_PER_MAT];

`endif
