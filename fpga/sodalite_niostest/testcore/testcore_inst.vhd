	component testcore is
		port (
			clk100_clk            : in    std_logic                     := 'X';             -- clk
			reset_reset_n         : in    std_logic                     := 'X';             -- reset_n
			led_export            : out   std_logic;                                        -- export
			gpio_export           : inout std_logic_vector(27 downto 0) := (others => 'X'); -- export
			clk40_clk             : in    std_logic                     := 'X';             -- clk
			sdr_addr              : out   std_logic_vector(12 downto 0);                    -- addr
			sdr_ba                : out   std_logic_vector(1 downto 0);                     -- ba
			sdr_cas_n             : out   std_logic;                                        -- cas_n
			sdr_cke               : out   std_logic;                                        -- cke
			sdr_cs_n              : out   std_logic;                                        -- cs_n
			sdr_dq                : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdr_dqm               : out   std_logic_vector(1 downto 0);                     -- dqm
			sdr_ras_n             : out   std_logic;                                        -- ras_n
			sdr_we_n              : out   std_logic;                                        -- we_n
			adc_pll_locked_export : in    std_logic                     := 'X'              -- export
		);
	end component testcore;

	u0 : component testcore
		port map (
			clk100_clk            => CONNECTED_TO_clk100_clk,            --         clk100.clk
			reset_reset_n         => CONNECTED_TO_reset_reset_n,         --          reset.reset_n
			led_export            => CONNECTED_TO_led_export,            --            led.export
			gpio_export           => CONNECTED_TO_gpio_export,           --           gpio.export
			clk40_clk             => CONNECTED_TO_clk40_clk,             --          clk40.clk
			sdr_addr              => CONNECTED_TO_sdr_addr,              --            sdr.addr
			sdr_ba                => CONNECTED_TO_sdr_ba,                --               .ba
			sdr_cas_n             => CONNECTED_TO_sdr_cas_n,             --               .cas_n
			sdr_cke               => CONNECTED_TO_sdr_cke,               --               .cke
			sdr_cs_n              => CONNECTED_TO_sdr_cs_n,              --               .cs_n
			sdr_dq                => CONNECTED_TO_sdr_dq,                --               .dq
			sdr_dqm               => CONNECTED_TO_sdr_dqm,               --               .dqm
			sdr_ras_n             => CONNECTED_TO_sdr_ras_n,             --               .ras_n
			sdr_we_n              => CONNECTED_TO_sdr_we_n,              --               .we_n
			adc_pll_locked_export => CONNECTED_TO_adc_pll_locked_export  -- adc_pll_locked.export
		);

