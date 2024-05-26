interface vdc_dac;

	import vdc_pkg::*;

	logic first, last, ready, valid;
	pix_rgb30 pix;

	modport tx
	(
		input  ready,

		output pix,
		       last,
		       first,
		       valid
	);

	modport rx
	(
		input  pix,
		       last,
		       first,
		       valid,

		output ready
	);

endinterface
