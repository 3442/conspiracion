create_clock -period 10 -name clk_clk [get_ports clk_clk]
derive_pll_clocks
derive_clock_uncertainty
