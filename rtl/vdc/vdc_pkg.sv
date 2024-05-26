package vdc_pkg;

	typedef logic[7:0]  rgb8;
	typedef logic[9:0]  rgb10;
	typedef logic[15:0] geom_dim;
	typedef logic[29:0] ptr;

	typedef struct
	{
		rgb8 r, g, b;
	} pix_rgb24;

	typedef struct
	{
		rgb10 r, g, b;
	} pix_rgb30;

	function rgb10 rgb8to10(rgb8 in);
		return {in, in[0], in[0]};
	endfunction

endpackage
