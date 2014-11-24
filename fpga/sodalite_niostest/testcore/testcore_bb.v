
module testcore (
	clk100_clk,
	reset_reset_n,
	led_export,
	gpio_export,
	clk40_clk,
	sdr_addr,
	sdr_ba,
	sdr_cas_n,
	sdr_cke,
	sdr_cs_n,
	sdr_dq,
	sdr_dqm,
	sdr_ras_n,
	sdr_we_n,
	adc_pll_locked_export);	

	input		clk100_clk;
	input		reset_reset_n;
	output		led_export;
	inout	[27:0]	gpio_export;
	input		clk40_clk;
	output	[12:0]	sdr_addr;
	output	[1:0]	sdr_ba;
	output		sdr_cas_n;
	output		sdr_cke;
	output		sdr_cs_n;
	inout	[15:0]	sdr_dq;
	output	[1:0]	sdr_dqm;
	output		sdr_ras_n;
	output		sdr_we_n;
	input		adc_pll_locked_export;
endmodule
