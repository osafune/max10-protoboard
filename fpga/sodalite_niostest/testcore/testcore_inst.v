	testcore u0 (
		.clk100_clk            (<connected-to-clk100_clk>),            //         clk100.clk
		.reset_reset_n         (<connected-to-reset_reset_n>),         //          reset.reset_n
		.led_export            (<connected-to-led_export>),            //            led.export
		.gpio_export           (<connected-to-gpio_export>),           //           gpio.export
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
		.adc_pll_locked_export (<connected-to-adc_pll_locked_export>)  // adc_pll_locked.export
	);

