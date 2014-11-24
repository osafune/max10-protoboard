-- ===================================================================
-- TITLE : VGA Controller / AvalonMM Component
--
--     DESIGN : S.OSAFUNE (J-7SYSTEM Works)
--     DATE   : 2010/12/11 -> 2010/12/11
--            : 2010/12/27 (FIXED)
--
--     UPDATE : 2013/05/31 add s1_reset signal
--            : 2013/07/10 modify g_reset signal, add dot_enable signal
-- ===================================================================
-- *******************************************************************
--   Copyright (C) 2010-2013, J-7SYSTEM Works.  All rights Reserved.
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

entity vga_component is
	generic (
		LINEOFFSETBYTES	: integer := 1024*2;
		H_TOTAL			: integer := 800;
		H_SYNC			: integer := 96;
		H_BACKP			: integer := 48;
		H_ACTIVE		: integer := 640;
		V_TOTAL			: integer := 525;
		V_SYNC			: integer := 2;
		V_BACKP			: integer := 33;
		V_ACTIVE		: integer := 480
	);
	port (
		----- AvalonMMクロック信号 -----------
		g_reset				: in  std_logic;
		m1_clk				: in  std_logic;
		s1_clk				: in  std_logic;

		----- AvalonMMマスタ信号 -----------
		avm_m1_address		: out std_logic_vector(31 downto 0);
		avm_m1_waitrequest	: in  std_logic;
		avm_m1_burstcount	: out std_logic_vector(9 downto 0);

		avm_m1_read			: out std_logic;
		avm_m1_readdata		: in  std_logic_vector(31 downto 0);
		avm_m1_readdatavalid: in  std_logic;

		----- AvalonMMスレーブ信号 -----------
		avs_s1_address		: in  std_logic_vector(3 downto 2);
		avs_s1_read			: in  std_logic;
		avs_s1_readdata		: out std_logic_vector(31 downto 0);
		avs_s1_write		: in  std_logic;
		avs_s1_writedata	: in  std_logic_vector(31 downto 0);

		irq_s1				: out std_logic;

		----- 外部信号 -----------
		video_clk			: in  std_logic;		-- typ 25.175MHz
		video_hsync_n		: out std_logic;
		video_vsync_n		: out std_logic;
		video_enable		: out std_logic;
		video_rout			: out std_logic_vector(4 downto 0);
		video_gout			: out std_logic_vector(4 downto 0);
		video_bout			: out std_logic_vector(4 downto 0)
	);
end vga_component;

architecture RTL of vga_component is

	signal reset_sig	: std_logic;
	signal readdata_0_sig		: std_logic_vector(31 downto 0);
	signal readdata_1_sig		: std_logic_vector(31 downto 0);
	signal readdata_2_sig		: std_logic_vector(31 downto 0);

	signal vs_0_reg				: std_logic;
	signal vs_1_reg				: std_logic;
	signal vs_2_reg				: std_logic;
	signal vsirq_reg			: std_logic;
	signal vsirqena_reg			: std_logic;
	signal ovr_0_reg			: std_logic;
	signal ovr_1_reg			: std_logic;
	signal ovr_2_reg			: std_logic;
	signal ovrerr_reg			: std_logic;
	signal vsflag_reg			: std_logic;
	signal scanena_reg			: std_logic;
--	signal ditherena_reg		: std_logic;
	signal framebuff_addr_reg	: std_logic_vector(31 downto 0);
	signal vsynccounter_reg		: std_logic_vector(7 downto 0);

	signal framestart_sig		: std_logic;
	signal linestart_sig		: std_logic;
	signal overrun_sig			: std_logic;
	signal fs_0_reg				: std_logic;
	signal fs_1_reg				: std_logic;
	signal fs_2_reg				: std_logic;
	signal ls_0_reg				: std_logic;
	signal ls_1_reg				: std_logic;
	signal ls_2_reg				: std_logic;
	signal fs_riseedge_sig		: std_logic;
	signal ls_riseedge_sig		: std_logic;

	signal hsync_sig			: std_logic;
	signal vsync_sig			: std_logic;
	signal dither_sig			: std_logic;
	signal hblank_sig			: std_logic;
	signal vblank_sig			: std_logic;

	signal pixelactive_sig		: std_logic;
	signal pixelscanena_reg		: std_logic;
	signal de_delay_reg			: std_logic_vector(2 downto 0);
	signal hs_delay_reg			: std_logic_vector(2 downto 0);
	signal vs_delay_reg			: std_logic_vector(2 downto 0);


	component vga_avm
	generic (
		BURSTCYCLE			: integer;
		LINEOFFSETBYTES		: integer
	);
	port (
		csi_m1_reset		: in  std_logic;
		csi_m1_clk			: in  std_logic;

		avm_m1_address		: out std_logic_vector(31 downto 0);
		avm_m1_waitrequest	: in  std_logic;
		avm_m1_burstcount	: out std_logic_vector(9 downto 0);

		avm_m1_read			: out std_logic;
		avm_m1_readdata		: in  std_logic_vector(31 downto 0);
		avm_m1_readdatavalid: in  std_logic;

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
	end component;

begin

	reset_sig <= g_reset;


	----- コントロールレジスタ -----------

	readdata_0_sig <= (	15=>vsirqena_reg,
						14=>vsirq_reg,
						13=>vsflag_reg,
						12=>ovrerr_reg,
--						1 =>ditherena_reg,
						0 =>scanena_reg,
						others=>'0');
	readdata_1_sig <= framebuff_addr_reg;
	readdata_2_sig(31 downto 8) <= (others=>'0');
	readdata_2_sig(7 downto 0)  <= vsynccounter_reg;

	with avs_s1_address select avs_s1_readdata <=
		readdata_0_sig when "00",
		readdata_1_sig when "01",
		readdata_2_sig when "10",
		(others=>'X')  when others;

	irq_s1 <= vsirq_reg when (vsirqena_reg = '1') else '0';

	process(s1_clk, reset_sig)begin
		if (reset_sig = '1') then
			vs_0_reg  <= '0';
			vs_1_reg  <= '0';
			vs_2_reg  <= '0';
			ovr_0_reg <= '0';
			ovr_1_reg <= '0';
			ovr_2_reg <= '0';

			vsirq_reg    <= '0';
			vsirqena_reg <= '0';
			vsflag_reg   <= '0';
			ovrerr_reg   <= '0';
			scanena_reg  <= '0';
--			ditherena_reg<= '0';

			framebuff_addr_reg <= (others=>'0');
			vsynccounter_reg   <= (others=>'0');

		elsif (s1_clk'event and s1_clk = '1') then

			-- VSYNC割り込みフラグのセットとクリア 
			vs_0_reg  <= vsync_sig;
			vs_1_reg  <= vs_0_reg;
			vs_2_reg  <= vs_1_reg;

			if (vs_2_reg = '0' and vs_1_reg = '1') then
				vsirq_reg  <= '1';
				vsflag_reg <= not vsflag_reg;		-- vsflagはVSYNCの度に反転する 

			elsif (avs_s1_write = '1' and avs_s1_address = "00" and avs_s1_writedata(14) = '0') then
				vsirq_reg <= '0';

			end if;

			-- VSYNCカウンタのセットとデクリメント 
			if (avs_s1_write = '1' and avs_s1_address = "10") then
				vsynccounter_reg <= avs_s1_writedata(7 downto 0);

			elsif (vs_2_reg = '0' and vs_1_reg = '1') then
				if (vsynccounter_reg /= 0) then
					vsynccounter_reg <= vsynccounter_reg - '1';
				end if;

			end if;

			-- OVERRUNエラーフラグのセットとクリア 
			ovr_0_reg <= overrun_sig;
			ovr_1_reg <= ovr_0_reg;
			ovr_2_reg <= ovr_1_reg;

			if (ovr_2_reg = '0' and ovr_1_reg = '1') then
				ovrerr_reg <= '1';

			elsif (avs_s1_write = '1' and avs_s1_address = "00" and avs_s1_writedata(12) = '0') then
				ovrerr_reg <= '0';

			end if;

			-- その他の制御レジスタの書き込み 
			if (avs_s1_write = '1') then
				case avs_s1_address is
				when "00" =>
					vsirqena_reg <= avs_s1_writedata(15);
--					ditherena_reg<= avs_s1_writedata(1);
					scanena_reg  <= avs_s1_writedata(0);

				when "01" =>
					framebuff_addr_reg <= avs_s1_writedata;

				when others =>
				end case;
			end if;

		end if;
	end process;



	----- タイミング信号生成 -----------

	video_enable  <= de_delay_reg(2);
	video_hsync_n <= not hs_delay_reg(2);
	video_vsync_n <= not vs_delay_reg(2);

	process(video_clk)begin				-- pixelデータ出力遅延分だけ同期信号もずらす 
		if (video_clk'event and video_clk = '1') then
			de_delay_reg <= de_delay_reg(1 downto 0) & ((not hblank_sig) and (not vblank_sig));
			hs_delay_reg <= hs_delay_reg(1 downto 0) & hsync_sig;
			vs_delay_reg <= vs_delay_reg(1 downto 0) & vsync_sig;
		end if;
	end process;


	U0 : vga_syncgen
	generic map (
		H_TOTAL		=> H_TOTAL,
		H_SYNC		=> H_SYNC,
		H_BACKP		=> H_BACKP,
		H_ACTIVE	=> H_ACTIVE,
		V_TOTAL		=> V_TOTAL,
		V_SYNC		=> V_SYNC,
		V_BACKP		=> V_BACKP,
		V_ACTIVE	=> V_ACTIVE
	)
	port map (
		video_clk	=> video_clk,
		reset		=> reset_sig,
		scan_ena	=> scanena_reg,
		dither_ena	=> '0',				--ditherena_reg,

		framestart	=> framestart_sig,
		linestart	=> linestart_sig,
		dither		=> dither_sig,
		pixelena	=> pixelactive_sig,
		hsync		=> hsync_sig,
		vsync		=> vsync_sig,
		hblank		=> hblank_sig,
		vblank		=> vblank_sig
	);


	----- メモリアクセス -----------

	fs_riseedge_sig <= '1' when (fs_2_reg = '0' and fs_1_reg = '1') else '0';
	ls_riseedge_sig <= '1' when (ls_2_reg = '0' and ls_1_reg = '1') else '0';

	process(m1_clk, reset_sig)begin		-- framestart,linestartの立ち上がりを検出 
		if (reset_sig = '1') then
			fs_0_reg <= '0';
			fs_1_reg <= '0';
			fs_2_reg <= '0';
			ls_0_reg <= '0';
			ls_1_reg <= '0';
			ls_2_reg <= '0';

		elsif (m1_clk'event and m1_clk = '1') then
			fs_0_reg <= framestart_sig;
			fs_1_reg <= fs_0_reg;
			fs_2_reg <= fs_1_reg;

			ls_0_reg <= linestart_sig;
			ls_1_reg <= ls_0_reg;
			ls_2_reg <= ls_1_reg;
		end if;
	end process;


	U1 : vga_avm
	generic map (
		BURSTCYCLE			=> H_ACTIVE/2,
		LINEOFFSETBYTES		=> LINEOFFSETBYTES
	)
	port map (
		csi_m1_reset		=> reset_sig,
		csi_m1_clk			=> m1_clk,
		avm_m1_address		=> avm_m1_address,
		avm_m1_waitrequest	=> avm_m1_waitrequest,
		avm_m1_burstcount	=> avm_m1_burstcount,
		avm_m1_read			=> avm_m1_read,
		avm_m1_readdata		=> avm_m1_readdata,
		avm_m1_readdatavalid=> avm_m1_readdatavalid,

		framebuff_addr		=> framebuff_addr_reg,
		framestart			=> fs_riseedge_sig,
		linestart			=> ls_riseedge_sig,
		ready				=> open,
		overrun				=> overrun_sig,

		video_clk			=> video_clk,
		video_active		=> pixelactive_sig,
		video_dither		=> dither_sig,
		video_rout			=> video_rout,
		video_gout			=> video_gout,
		video_bout			=> video_bout,
		video_pixelvalid	=> open
	);


end RTL;
