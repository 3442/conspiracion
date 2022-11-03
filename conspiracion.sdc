create_clock -period 20 -name clk_clk [get_ports clk_clk]
derive_pll_clocks
derive_clock_uncertainty
