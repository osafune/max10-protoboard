-- ===================================================================
-- TITLE : VGA Controller / AvalonMM Burst Master
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2010/11/20 -> 2010/12/12
--            : 2010/12/27 (FIXED)
--
--     UPDATE : 2011/06/25 modify overrun enable condition
--
-- ===================================================================
-- *******************************************************************
--   Copyright (C) 2010-2011, J-7SYSTEM Works.  All rights Reserved.
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity vga_avm is
	generic (
		BURSTCYCLE			: integer := 320;
		LINEOFFSETBYTES		: integer := 1024*2
	);
	port (
		----- AvalonMMクロック信号 -----------
		csi_m1_reset		: in  std_logic;
		csi_m1_clk			: in  std_logic;

		----- AvalonMMマスタ信号 -----------
		avm_m1_address		: out std_logic_vector(31 downto 0);
		avm_m1_waitrequest	: in  std_logic;
		avm_m1_burstcount	: out std_logic_vector(9 downto 0);

		avm_m1_read			: out std_logic;
		avm_m1_readdata		: in  std_logic_vector(31 downto 0);
		avm_m1_readdatavalid: in  std_logic;

		----- 外部信号 -----------
		framebuff_addr		: in  std_logic_vector(31 downto 0);
		framestart			: in  std_logic;
		linestart			: in  std_logic;
		ready				: out std_logic;
		overrun				: out std_logic;		-- linebuffer overrun. clear for framestart signal.

		video_clk			: in  std_logic;		-- typ 25MHz
		video_active		: in  std_logic;
		video_dither		: in  std_logic;
		video_rout			: out std_logic_vector(4 downto 0);
		video_gout			: out std_logic_vector(4 downto 0);
		video_bout			: out std_logic_vector(4 downto 0);
		video_pixelvalid	: out std_logic
	);
end vga_avm;

architecture RTL of vga_avm is

	type BUS_STATE is (IDLE,
						READ_ISSUE,DATA_READ,READ_DONE,
						WRITE_ISSUE,WRITE_DONE);
	signal avm_state : BUS_STATE;
	signal datacount	: integer range 0 to BURSTCYCLE;
	signal topaddr_reg	: std_logic_vector(31 downto 0);
	signal lineoffs_reg	: std_logic_vector(31 downto 0);
	signal addr_reg		: std_logic_vector(31 downto 2);
	signal read_reg		: std_logic;
	signal write_reg	: std_logic;

	signal pixelcount_reg	: std_logic_vector(8 downto 0);
	signal overrun_reg		: std_logic;

	signal readdata_sig			: std_logic_vector(31 downto 0);
	signal readdatavalid_sig	: std_logic;
	signal pixeladdr_reg		: std_logic_vector(9 downto 0);
	signal pixeldata_sig		: std_logic_vector(15 downto 0);
	signal valid_reg			: std_logic_vector(2 downto 0);

	signal pixel_r_sig			: std_logic_vector(4 downto 0);
	signal pixel_g_sig			: std_logic_vector(4 downto 0);
	signal pixel_b_sig			: std_logic_vector(4 downto 0);
	signal dither_r_sig			: std_logic_vector(4 downto 0);
	signal dither_g_sig			: std_logic_vector(4 downto 0);
	signal dither_b_sig			: std_logic_vector(4 downto 0);
	signal rout_reg				: std_logic_vector(4 downto 0);
	signal gout_reg				: std_logic_vector(4 downto 0);
	signal bout_reg				: std_logic_vector(4 downto 0);

	component vga_linebuffer
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		wraddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC  := '0';
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	end component;

begin

	-- ステータス＆エラーチェック 

	ready   <= '1' when (avm_state = IDLE) else '0';
	overrun <= overrun_reg;


	-- AvalonMMバーストマスタ・ステートマシン 

	avm_m1_address    <= addr_reg & "00";
	avm_m1_burstcount <= CONV_STD_LOGIC_VECTOR(BURSTCYCLE, 10);
	avm_m1_read       <= read_reg;
	readdata_sig      <= avm_m1_readdata;
	readdatavalid_sig <= avm_m1_readdatavalid when (avm_state=DATA_READ) else '0';

	process (csi_m1_clk, csi_m1_reset) begin
		if (csi_m1_reset = '1') then
			avm_state <= IDLE;
			datacount <= 0;
			addr_reg  <= (others=>'0');
			read_reg  <= '0';
			write_reg <= '0';

			topaddr_reg  <= (others=>'0');
			lineoffs_reg <= (others=>'0');

		elsif(csi_m1_clk'event and csi_m1_clk='1') then

			case avm_state is
			when IDLE =>
				if (linestart = '1') then
					avm_state <= READ_ISSUE;
					addr_reg  <= topaddr_reg(31 downto 2) + lineoffs_reg(31 downto 2);
					read_reg  <= '1';
					datacount <= 0;
				end if;

			when READ_ISSUE =>
				if (avm_m1_waitrequest = '0') then
					avm_state <= DATA_READ;
					read_reg  <= '0';
				end if;

			when DATA_READ =>
				if (avm_m1_readdatavalid = '1') then
					if (datacount = BURSTCYCLE-1) then
						avm_state <= IDLE;
					end if;

					datacount <= datacount + 1;
				end if;

			when others=>
			end case;


			topaddr_reg <= framebuff_addr;

			if (framestart = '1') then
				lineoffs_reg <= (others=>'0');
			elsif (avm_state = IDLE and linestart = '1') then
				lineoffs_reg <= lineoffs_reg + CONV_STD_LOGIC_VECTOR(LINEOFFSETBYTES, 32);
			end if;

		end if;
	end process;


	-- ラインバッファメモリ 

	video_rout       <= rout_reg;
	video_gout       <= gout_reg;
	video_bout       <= bout_reg;
	video_pixelvalid <= valid_reg(2);

	process(video_clk)begin
		if (video_clk'event and video_clk='1') then
			valid_reg <= valid_reg(1 downto 0) & video_active;

			if (video_active = '0') then
				pixeladdr_reg <= (others=>'0');
			else
				pixeladdr_reg <= pixeladdr_reg + '1';
			end if;

			if (valid_reg(1) = '1') then
				rout_reg <= dither_r_sig;
				gout_reg <= dither_g_sig;
				bout_reg <= dither_b_sig;
			else
				rout_reg <= (others=>'0');
				gout_reg <= (others=>'0');
				bout_reg <= (others=>'0');
			end if;

			pixelcount_reg <= CONV_STD_LOGIC_VECTOR(datacount, 9);
			if (video_active = '0') then
				overrun_reg <= '0';
			elsif (pixelcount_reg < pixeladdr_reg(9 downto 1)) then
				overrun_reg <= '1';
			end if;

		end if;
	end process;


	U0 : vga_linebuffer
	PORT MAP (
		wrclock		=> csi_m1_clk,
		wraddress	=> CONV_STD_LOGIC_VECTOR(datacount, 9),
		data		=> readdata_sig,
		wren		=> readdatavalid_sig,

		rdclock	 	=> video_clk,
		rdaddress	=> pixeladdr_reg,
		q			=> pixeldata_sig
	);

	pixel_r_sig <= pixeldata_sig(14 downto 10);
	pixel_g_sig <= pixeldata_sig( 9 downto  5);
	pixel_b_sig <= pixeldata_sig( 4 downto  0);

	dither_r_sig <= pixel_r_sig + "00001" when(pixel_r_sig/="11111" and video_dither='1') else pixel_r_sig;
	dither_g_sig <= pixel_g_sig + "00001" when(pixel_g_sig/="11111" and video_dither='1') else pixel_g_sig;
	dither_b_sig <= pixel_b_sig + "00001" when(pixel_b_sig/="11111" and video_dither='1') else pixel_b_sig;


end RTL;
