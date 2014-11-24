-- ===================================================================
-- TITLE : VGA Controller / Sync Generator
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2010/12/10 -> 2010/12/10
--            : 2010/12/27 (FIXED)
--
--     UPDATE : 2012/02/21 add pixelena signal(for ATM0430D5)
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

entity vga_syncgen is
	generic (
		H_TOTAL		: integer := 800;
		H_SYNC		: integer := 96;
		H_BACKP		: integer := 48;
		H_ACTIVE	: integer := 640;
		V_TOTAL		: integer := 525;
		V_SYNC		: integer := 2;
		V_BACKP		: integer := 33;
		V_ACTIVE	: integer := 480
	);
	port (
		reset		: in  std_logic;		-- active high
		video_clk	: in  std_logic;		-- typ 25.175MHz

		scan_ena	: in  std_logic;		-- framebuff scan enable
		dither_ena	: in  std_logic;		-- dither enable

		framestart	: out std_logic;
		linestart	: out std_logic;
		dither		: out std_logic;		-- RGB444 dither signal
		pixelena	: out std_logic;		-- pixel readout active

		hsync		: out std_logic;
		vsync		: out std_logic;
		hblank		: out std_logic;
		vblank		: out std_logic
	);
end vga_syncgen;

architecture RTL of vga_syncgen is
	signal hcount	: integer range 0 to H_TOTAL-1;
	signal vcount	: integer range 0 to V_TOTAL-1;

	signal scan_in_reg	: std_logic;
	signal scanena_reg	: std_logic;
	signal dithena_reg	: std_logic;
	signal frame_reg	: std_logic;
	signal line_reg		: std_logic;
	signal hsync_reg	: std_logic;
	signal vsync_reg	: std_logic;
	signal hblank_reg	: std_logic;
	signal vblank_reg	: std_logic;
	signal dither_reg	: std_logic;

begin

	framestart <= frame_reg;	-- 必ずレジスタ出力 
	linestart  <= line_reg;		-- 必ずレジスタ出力 
	dither     <= dither_reg;
	pixelena   <= scanena_reg when (hblank_reg = '0' and vblank_reg = '0') else '0';

	hsync  <= hsync_reg;
	vsync  <= vsync_reg;
	hblank <= hblank_reg;
	vblank <= vblank_reg;


	process (video_clk, reset) begin
		if (reset = '1') then
			hcount <= H_TOTAL-1;
			vcount <= V_TOTAL-1;

			scan_in_reg <= '0';
			scanena_reg <= '0';
			dithena_reg <= '0';
			frame_reg   <= '0';
			line_reg    <= '0';
			hsync_reg   <= '0';
			vsync_reg   <= '0';
			hblank_reg  <= '1';
			vblank_reg  <= '1';
			dither_reg  <= '0';

		elsif(video_clk'event and video_clk='1') then
			scan_in_reg <= scan_ena;
			dithena_reg <= dither_ena;

			if (hcount = 0 and vcount = 0) then
				scanena_reg <= scan_in_reg;
			end if;


			if (hcount = H_TOTAL-1) then
				hcount <= 0;
			else
				hcount <= hcount + 1;
			end if;

			if (hcount = H_TOTAL-1) then
				hsync_reg <= '1';
			elsif (hcount = H_SYNC-1) then
				hsync_reg <= '0';
			end if;

			if (hcount = H_SYNC + H_BACKP-1) then
				hblank_reg <= '0';
			elsif (hcount = H_SYNC + H_BACKP + H_ACTIVE-1) then
				hblank_reg <= '1';
			end if;


			if (hcount = H_SYNC + H_BACKP + H_ACTIVE-1) then
				if (vcount = V_TOTAL-1) then
					vcount <= 0;
				else
					vcount <= vcount + 1;
				end if;

				if (vcount = V_TOTAL-1) then
					vsync_reg <= '1';
				elsif (vcount = V_SYNC-1) then
					vsync_reg <= '0';
				end if;

				if (vcount = V_SYNC + V_BACKP-1) then
					vblank_reg <= '0';
				elsif (vcount = V_SYNC + V_BACKP + V_ACTIVE-1) then
					vblank_reg <= '1';
				end if;
			end if;


			if (hcount = H_TOTAL-1) then
				if (vcount = 0) then
					frame_reg <= '1';
				else
					frame_reg <= '0';
				end if;

				if (vblank_reg = '0') then
					line_reg <= scanena_reg;	--'1';
				else
					line_reg <= '0';
				end if;
			elsif (hcount = H_SYNC-1) then
				frame_reg <= '0';
				line_reg  <= '0';
			end if;


			if ((hcount mod 2) /= (vcount mod 2)) then
				dither_reg <= dithena_reg;
			else
				dither_reg <= '0';
			end if;

		end if;
	end process;


end RTL;
