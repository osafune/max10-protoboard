-- ===================================================================
-- TITLE : SODALITE HDMI出力テスト 
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2014/11/15 -> 2014/11/15
--
-- ===================================================================
-- *******************************************************************
--   Copyright (C) 2010-2014, J-7SYSTEM Works.  All rights Reserved.
--
-- * This module is a free sourcecode and there is NO WARRANTY.
-- * No restriction on use. You can use, modify and redistribute it
--   for personal, non-profit or commercial products UNDER YOUR
--   RESPONSIBILITY.
-- * Redistributions of source code must retain the above copyright
--   notice.
-- *******************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity max10_hdmi_top is
	port(
		FREQ_SEL		: out std_logic;	-- OSC Frequency selector
--		CLOCK_50		: in  std_logic;	-- 50.0MHz in
		CLOCK_74		: in  std_logic;	-- 74.25MHz in
		RESET_N			: in  std_logic;
		LED				: out std_logic;

		TMDS_CLOCK_N	: out std_logic;
		TMDS_CLOCK_P	: out std_logic;
		TMDS_DATA0_N	: out std_logic;
		TMDS_DATA0_P	: out std_logic;
		TMDS_DATA1_N	: out std_logic;
		TMDS_DATA1_P	: out std_logic;
		TMDS_DATA2_N	: out std_logic;
		TMDS_DATA2_P	: out std_logic
	);
end max10_hdmi_top;

architecture RTL of max10_hdmi_top is
	signal pllreset_sig		: std_logic;
	signal vga_clk_sig		: std_logic;
	signal tx_clk_sig		: std_logic;
	signal locked_sig		: std_logic;
	signal reset_sig		: std_logic;

	signal dvi_hsync_sig	: std_logic;
	signal dvi_vsync_sig	: std_logic;
	signal dvi_hblank_sig	: std_logic;
	signal dvi_vblank_sig	: std_logic;
	signal dvi_de_sig		: std_logic;
	signal dvi_r_sig		: std_logic_vector(7 downto 0);
	signal dvi_g_sig		: std_logic_vector(7 downto 0);
	signal dvi_b_sig		: std_logic_vector(7 downto 0);


	component videopll
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';		-- 50.0MHz input
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

	component hdvideopll
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';		-- 74.25MHz input
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component;

	component vga_syncgen
	generic (
		H_TOTAL		: integer;
		H_SYNC		: integer;
		H_BACKP		: integer;
		H_ACTIVE	: integer;
		V_TOTAL		: integer;
		V_SYNC		: integer;
		V_BACKP		: integer;
		V_ACTIVE	: integer
	);
	port (
		reset		: in  std_logic;
		video_clk	: in  std_logic;

		scan_ena	: in  std_logic;
		dither_ena	: in  std_logic;

		framestart	: out std_logic;
		linestart	: out std_logic;
		dither		: out std_logic;
		pixelena	: out std_logic;

		hsync		: out std_logic;
		vsync		: out std_logic;
		hblank		: out std_logic;
		vblank		: out std_logic;
		cb_rout		: out std_logic_vector(7 downto 0);	
		cb_gout		: out std_logic_vector(7 downto 0);
		cb_bout		: out std_logic_vector(7 downto 0)
	);
	end component;

	component dvi_tx_pdiff
	generic(
		RESET_LEVEL		: std_logic := '1'
	);
	port(
		reset		: in  std_logic;
		clk			: in  std_logic;
		clk_x5		: in  std_logic;

		test_data0	: out std_logic_vector(9 downto 0);
		test_data1	: out std_logic_vector(9 downto 0);
		test_data2	: out std_logic_vector(9 downto 0);

		dvi_de		: in  std_logic;
		dvi_blu		: in  std_logic_vector(7 downto 0);
		dvi_grn		: in  std_logic_vector(7 downto 0);
		dvi_red		: in  std_logic_vector(7 downto 0);
		dvi_hsync	: in  std_logic;
		dvi_vsync	: in  std_logic;
		dvi_ctl		: in  std_logic_vector(3 downto 0) :="0000";

		data0_p		: out std_logic;
		data0_n		: out std_logic;
		data1_p		: out std_logic;
		data1_n		: out std_logic;
		data2_p		: out std_logic;
		data2_n		: out std_logic;
		clock_p		: out std_logic;
		clock_n		: out std_logic
	);
	end component;

begin

--	FREQ_SEL <= '1';	-- 50.0MHz settings
	FREQ_SEL <= '0';	-- 74.25MHz settings

	pllreset_sig <= not RESET_N;
	LED <= locked_sig;

--	videopll_inst : videopll
--	PORT MAP (
--		areset	 => pllreset_sig,
--		inclk0	 => CLOCK_50,
--		c0		 => vga_clk_sig,	-- 25.175MHz (25.0MHz)
--		c1		 => tx_clk_sig,		-- 125.875MHz (c0 x 5)
--		locked	 => locked_sig
--	);

	hdvideopll_inst : hdvideopll
	PORT MAP (
		areset	 => pllreset_sig,
		inclk0	 => CLOCK_74,
		c0		 => vga_clk_sig,	-- 74.25MHz
		c1		 => tx_clk_sig,		-- 371.25MHz (c0 x 5)
		locked	 => locked_sig
	);

	reset_sig <= not locked_sig;


	U_DVI : vga_syncgen
	generic map (
--		H_TOTAL		=> 794,		-- VGA(794は25.0MHzの補正) 
--		H_SYNC		=> 96,
--		H_BACKP		=> 48,
--		H_ACTIVE	=> 640,
--		V_TOTAL		=> 525,
--		V_SYNC		=> 2,
--		V_BACKP		=> 33,
--		V_ACTIVE	=> 480

		H_TOTAL		=> 1650,	-- 720p
		H_SYNC		=> 40,
		H_BACKP		=> 260,
		H_ACTIVE	=> 1280,
		V_TOTAL		=> 750,
		V_SYNC		=> 5,
		V_BACKP		=> 20,
		V_ACTIVE	=> 720
	)
	port map (
		video_clk	=> vga_clk_sig,
		reset		=> reset_sig,
		scan_ena	=> '0',
		dither_ena	=> '0',
		hsync		=> dvi_hsync_sig,
		vsync		=> dvi_vsync_sig,
		hblank		=> dvi_hblank_sig,
		vblank		=> dvi_vblank_sig,
		cb_rout		=> dvi_r_sig,
		cb_gout		=> dvi_g_sig,
		cb_bout		=> dvi_b_sig
	);

	dvi_de_sig <= (not dvi_hblank_sig) and (not dvi_vblank_sig);


	U_TMDS : dvi_tx_pdiff
	port map (
		reset		=> reset_sig,
		clk			=> vga_clk_sig,
		clk_x5		=> tx_clk_sig,

		dvi_de		=> dvi_de_sig,
		dvi_blu		=> dvi_b_sig,
		dvi_grn		=> dvi_g_sig,
		dvi_red		=> dvi_r_sig,
		dvi_hsync	=> dvi_hsync_sig,
		dvi_vsync	=> dvi_vsync_sig,
		dvi_ctl		=> "0000",

		data0_p		=> TMDS_DATA0_P,
		data0_n		=> TMDS_DATA0_N,
		data1_p		=> TMDS_DATA1_P,
		data1_n		=> TMDS_DATA1_N,
		data2_p		=> TMDS_DATA2_P,
		data2_n		=> TMDS_DATA2_N,
		clock_p		=> TMDS_CLOCK_P,
		clock_n		=> TMDS_CLOCK_N
	);



end RTL;
