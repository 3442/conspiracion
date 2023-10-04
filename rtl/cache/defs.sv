`ifndef CACHE_DEFS_SV
`define CACHE_DEFS_SV

typedef logic[3:0]   word_be;
typedef logic[15:0]  line_be;
typedef logic[127:0] line;

// Choca con typedef en core/uarch.sv
`ifndef WORD_DEFINED
typedef logic[29:0] ptr;
typedef logic[31:0] word;
`define WORD_DEFINED
`endif

/* Tenemos 512MiB de SDRAM, el resto del espacio es I/O (uncached). Usamos
 * 4096 líneas direct-mapped de 16 bytes cada una. El core solo realiza
 * operaciones alineadas. Por tanto, cada dirección de 32 bits consta de:
 * - 2 bits que siempre son 0 (traducidos a byteenable por core)
 * - 2 bits de offset (ya que para cache la unidad direccionable es la word)
 * - 12 bits de index
 * - 13 bits de tag
 * - 3 bits que son == 0 si cached, != 0 si uncached
 */
typedef logic[1:0]  addr_mbz;
typedef logic[1:0]  addr_offset;
typedef logic[11:0] addr_index;
typedef logic[12:0] addr_tag;
typedef logic[2:0]  addr_io_region;
typedef logic[26:0] addr_cacheable;

typedef struct packed
{
	addr_io_region io;
	addr_tag       tag;
	addr_index     index;
	addr_offset    offset;
	addr_mbz       mbz;
} addr_bits;

typedef enum logic[1:0]
{
	INVALID,
	SHARED,
	EXCLUSIVE,
	MODIFIED
} line_state;

typedef struct packed
{
`ifndef VERILATOR
	// Error: data width (158) must be a multiple of bitsPerSymbol (8)
	logic[1:0] padding;
`endif
	logic[1:0] ttl;
	logic      read,
	           inval,
	           reply;
	addr_tag   tag;
	addr_index index;
	line       data;
} ring_req;

`define TTL_END 2'b00
`define TTL_MAX 2'b11

typedef struct packed
{
	logic      valid;
	addr_tag   tag;
	addr_index index;
} token_lock;

typedef struct packed
{
`ifndef VERILATOR
	// Error: data width (78) must be a multiple of bitsPerSymbol (8)
	logic[1:0] padding;
`endif
	token_lock e2, e1, e0;
} ring_token;

`endif
