	component testcore is
		port (
			clk100_clk            : in    std_logic                     := 'X';             -- clk
			reset_reset_n         : in    std_logic                     := 'X';             -- reset_n
			led_export            : out   std_logic;                                        -- export
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
			adc_pll_locked_export : in    std_logic                     := 'X';             -- export
			mmc_nCS               : out   std_logic;                                        -- nCS
			mmc_SCK               : out   std_logic;                                        -- SCK
			mmc_SDO               : out   std_logic;                                        -- SDO
			mmc_SDI               : in    std_logic                     := 'X';             -- SDI
			mmc_CD                : in    std_logic                     := 'X';             -- CD
			mmc_WP                : in    std_logic                     := 'X';             -- WP
			vga_clk               : in    std_logic                     := 'X';             -- clk
			vga_rout              : out   std_logic_vector(4 downto 0);                     -- rout
			vga_gout              : out   std_logic_vector(4 downto 0);                     -- gout
			vga_bout              : out   std_logic_vector(4 downto 0);                     -- bout
			vga_hsync_n           : out   std_logic;                                        -- hsync_n
			vga_vsync_n           : out   std_logic;                                        -- vsync_n
			vga_enable            : out   std_logic                                         -- enable
		);
	end component testcore;

	u0 : component testcore
		port map (
			clk100_clk            => CONNECTED_TO_clk100_clk,            --         clk100.clk
			reset_reset_n         => CONNECTED_TO_reset_reset_n,         --          reset.reset_n
			led_export            => CONNECTED_TO_led_export,            --            led.export
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
			adc_pll_locked_export => CONNECTED_TO_adc_pll_locked_export, -- adc_pll_locked.export
			mmc_nCS               => CONNECTED_TO_mmc_nCS,               --            mmc.nCS
			mmc_SCK               => CONNECTED_TO_mmc_SCK,               --               .SCK
			mmc_SDO               => CONNECTED_TO_mmc_SDO,               --               .SDO
			mmc_SDI               => CONNECTED_TO_mmc_SDI,               --               .SDI
			mmc_CD                => CONNECTED_TO_mmc_CD,                --               .CD
			mmc_WP                => CONNECTED_TO_mmc_WP,                --               .WP
			vga_clk               => CONNECTED_TO_vga_clk,               --            vga.clk
			vga_rout              => CONNECTED_TO_vga_rout,              --               .rout
			vga_gout              => CONNECTED_TO_vga_gout,              --               .gout
			vga_bout              => CONNECTED_TO_vga_bout,              --               .bout
			vga_hsync_n           => CONNECTED_TO_vga_hsync_n,           --               .hsync_n
			vga_vsync_n           => CONNECTED_TO_vga_vsync_n,           --               .vsync_n
			vga_enable            => CONNECTED_TO_vga_enable             --               .enable
		);

