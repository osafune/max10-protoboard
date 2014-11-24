
module testcore (
	clk100_clk,
	reset_reset_n,
	led_export,
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
	adc_pll_locked_export,
	mmc_nCS,
	mmc_SCK,
	mmc_SDO,
	mmc_SDI,
	mmc_CD,
	mmc_WP,
	vga_clk,
	vga_rout,
	vga_gout,
	vga_bout,
	vga_hsync_n,
	vga_vsync_n,
	vga_enable);	

	input		clk100_clk;
	input		reset_reset_n;
	output		led_export;
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
	output		mmc_nCS;
	output		mmc_SCK;
	output		mmc_SDO;
	input		mmc_SDI;
	input		mmc_CD;
	input		mmc_WP;
	input		vga_clk;
	output	[4:0]	vga_rout;
	output	[4:0]	vga_gout;
	output	[4:0]	vga_bout;
	output		vga_hsync_n;
	output		vga_vsync_n;
	output		vga_enable;
endmodule
