	testcore u0 (
		.clk100_clk            (<connected-to-clk100_clk>),            //         clk100.clk
		.reset_reset_n         (<connected-to-reset_reset_n>),         //          reset.reset_n
		.led_export            (<connected-to-led_export>),            //            led.export
		.clk40_clk             (<connected-to-clk40_clk>),             //          clk40.clk
		.sdr_addr              (<connected-to-sdr_addr>),              //            sdr.addr
		.sdr_ba                (<connected-to-sdr_ba>),                //               .ba
		.sdr_cas_n             (<connected-to-sdr_cas_n>),             //               .cas_n
		.sdr_cke               (<connected-to-sdr_cke>),               //               .cke
		.sdr_cs_n              (<connected-to-sdr_cs_n>),              //               .cs_n
		.sdr_dq                (<connected-to-sdr_dq>),                //               .dq
		.sdr_dqm               (<connected-to-sdr_dqm>),               //               .dqm
		.sdr_ras_n             (<connected-to-sdr_ras_n>),             //               .ras_n
		.sdr_we_n              (<connected-to-sdr_we_n>),              //               .we_n
		.adc_pll_locked_export (<connected-to-adc_pll_locked_export>), // adc_pll_locked.export
		.mmc_nCS               (<connected-to-mmc_nCS>),               //            mmc.nCS
		.mmc_SCK               (<connected-to-mmc_SCK>),               //               .SCK
		.mmc_SDO               (<connected-to-mmc_SDO>),               //               .SDO
		.mmc_SDI               (<connected-to-mmc_SDI>),               //               .SDI
		.mmc_CD                (<connected-to-mmc_CD>),                //               .CD
		.mmc_WP                (<connected-to-mmc_WP>),                //               .WP
		.vga_clk               (<connected-to-vga_clk>),               //            vga.clk
		.vga_rout              (<connected-to-vga_rout>),              //               .rout
		.vga_gout              (<connected-to-vga_gout>),              //               .gout
		.vga_bout              (<connected-to-vga_bout>),              //               .bout
		.vga_hsync_n           (<connected-to-vga_hsync_n>),           //               .hsync_n
		.vga_vsync_n           (<connected-to-vga_vsync_n>),           //               .vsync_n
		.vga_enable            (<connected-to-vga_enable>)             //               .enable
	);

