// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


////////////////////////////////////////////////////////////////////
//
//  ALTERA_ONCHIP_FLASH_AVMM_DATA_CONTROLLER
//
//  Copyright (C) 1991-2013 Altera Corporation
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, Altera MegaCore Function License 
//  Agreement, or other applicable license agreement, including, 
//  without limitation, that your use is for the sole purpose of 
//  programming logic devices manufactured by Altera and sold by 
//  Altera or its authorized distributors.  Please refer to the 
//  applicable agreement for further details.
//
////////////////////////////////////////////////////////////////////

// synthesis VERILOG_INPUT_VERSION VERILOG_2001

`timescale 1 ps / 1 ps

module altera_onchip_flash_avmm_data_controller (
	// To/From System
	clock,
	reset_n,
	
	// To/From Flash IP interface
	flash_busy,
	flash_se_pass,
	flash_sp_pass,
	flash_drdout,
	flash_xe_ye,
	flash_se,
	flash_arclk,
	flash_arshft,
	flash_drclk,
	flash_drshft,
	flash_drdin,
	flash_nprogram,
	flash_nerase,
	flash_ardin,
		
	// To/From Avalon_MM data slave interface
	avmm_read,
	avmm_write,
	avmm_addr,
	avmm_writedata,
	avmm_burstcount,
	avmm_waitrequest,
	avmm_readdatavalid,
	avmm_readdata,
		
	// To/From Avalon_MM csr slave interface
	csr_control,
	csr_status
);

	parameter READ_AND_WRITE_MODE = 0;
	parameter WRAPPING_BURST_MODE = 0;
	parameter DATA_WIDTH = 32;
	parameter AVMM_DATA_ADDR_WIDTH = 20;
	parameter AVMM_DATA_BURSTCOUNT_WIDTH = 4;
	parameter FLASH_ADDR_WIDTH = 23;
	parameter FLASH_SEQ_READ_DATA_COUNT = 2;	//number of 32-bit data per sequential read
	parameter FLASH_READ_CYCLE_MAX_INDEX = 3;	//period to for each sequential read
	parameter FLASH_ADDR_ALIGNMENT_BITS = 1; 	//number of last addr bits for alignment
	parameter FLASH_RESET_CYCLE_MAX_INDEX = 28;	//period that required by flash before back to idle for erase and program operation
	parameter FLASH_BUSY_TIMEOUT_CYCLE_MAX_INDEX = 112; //flash busy timeout period (960ns)
	parameter FLASH_ERASE_TIMEOUT_CYCLE_MAX_INDEX = 40603248; //erase timeout period (350ms)
	parameter FLASH_WRITE_TIMEOUT_CYCLE_MAX_INDEX = 35382; //write timeout period (305us)

	// address legality check
	parameter MIN_VALID_ADDR = 1;
	parameter MAX_VALID_ADDR = 1;
	parameter SECTOR1_START_ADDR = 1;
	parameter SECTOR1_END_ADDR = 1;
	parameter SECTOR2_START_ADDR = 1;
	parameter SECTOR2_END_ADDR = 1;
	parameter SECTOR3_START_ADDR = 1;
	parameter SECTOR3_END_ADDR = 1;
	parameter SECTOR4_START_ADDR = 1;
	parameter SECTOR4_END_ADDR = 1;
	parameter SECTOR5_START_ADDR = 1;
	parameter SECTOR5_END_ADDR = 1;
	parameter SECTOR_READ_PROTECTION_MODE = 5'b11111;

	localparam [1:0]	ERASE_ST_IDLE = 0,
						ERASE_ST_PENDING = 1,
						ERASE_ST_BUSY = 2;

	localparam [1:0]	STATUS_IDLE = 0,
						STATUS_BUSY_ERASE = 1,
						STATUS_BUSY_WRITE = 2,
						STATUS_BUSY_READ = 3;

	localparam [2:0]	WRITE_STATE_IDLE = 0,
						WRITE_STATE_WRITE = 1,
						WRITE_STATE_WAIT_BUSY = 2,
						WRITE_STATE_WAIT_DONE = 3,
						WRITE_STATE_RESET = 4,
						WRITE_STATE_ERROR = 5;

	localparam [2:0]	ERASE_STATE_IDLE = 0,
						ERASE_STATE_WAIT_BUSY = 1,
						ERASE_STATE_WAIT_DONE = 2,
						ERASE_STATE_RESET = 3,
						ERASE_STATE_ERROR = 4;

	localparam [2:0]	READ_STATE_IDLE = 0,
						READ_STATE_READ = 1,
						READ_STATE_SETUP = 1,
						READ_STATE_DUMMY = 2,
						READ_STATE_READY = 3,
						READ_STATE_FINAL = 4,
						READ_STATE_CLEAR = 5;

	localparam [0:0]	READ_SETUP = 0,
						READ_RECV_DATA = 1;

	localparam [0:0]	READ_VALID_IDLE = 0,
						READ_VALID_READING = 1;

	// To/From System
	input clock;
	input reset_n;
	
	// To/From Flash IP interface
	input flash_busy;
	input flash_se_pass;
	input flash_sp_pass;
	input [DATA_WIDTH-1:0] flash_drdout;
	output flash_xe_ye;
	output flash_se;
	output flash_arclk;
	output flash_arshft;
	output flash_drclk;
	output flash_drshft;
	output flash_drdin;
	output flash_nprogram;
	output flash_nerase;
	output [FLASH_ADDR_WIDTH-1:0] flash_ardin;
		
	// To/From Avalon_MM data slave interface
	input avmm_read;
	input avmm_write;
	input [AVMM_DATA_ADDR_WIDTH-1:0] avmm_addr;
	input [DATA_WIDTH-1:0] avmm_writedata;
	input [AVMM_DATA_BURSTCOUNT_WIDTH-1:0] avmm_burstcount;
	output avmm_waitrequest;
	output avmm_readdatavalid;
	output [DATA_WIDTH-1:0] avmm_readdata;
		
	// To/From Avalon_MM csr slave interface
	input [31:0] csr_control;
	output [9:0] csr_status;

	reg [1:0] csr_status_busy;
	reg csr_status_e_pass;
	reg csr_status_w_pass;
	reg csr_status_r_pass;

	reg [2:0] erase_state /* synthesis noprune */;
	reg [2:0] write_state /* synthesis noprune */;
	reg [2:0] read_state /* synthesis noprune */;

	reg avmm_read_state;
	reg avmm_read_valid_state;
	reg avmm_readdatavalid_reg;
	reg avmm_readdata_ready;
	reg [FLASH_ADDR_WIDTH-1:0] flash_seq_read_ardin;
	reg [FLASH_ADDR_ALIGNMENT_BITS-1:0] flash_ardin_align_reg;
	reg [FLASH_ADDR_ALIGNMENT_BITS-1:0] flash_ardin_align_backup_reg;
	reg [AVMM_DATA_BURSTCOUNT_WIDTH-1:0] avmm_burstcount_input_reg;
	reg [AVMM_DATA_BURSTCOUNT_WIDTH-1:0] avmm_burstcount_reg;
	reg write_drclk_en;
	reg read_drclk_en;
	reg enable_arclk_neg_reg;
	reg enable_arclk_neg_pos_reg;
	reg enable_drclk_neg_reg;
	reg enable_drclk_neg_pos_reg;
	reg enable_drclk_neg_pos_write_reg;
	reg reset_n_reg1;
	reg reset_n_reg2;
	reg [31:0] write_count;
	reg [25:0] erase_count;
	reg [2:0] read_ctrl_count;
	reg [2:0] data_count;
	reg write_wait;
	reg write_invalid_addr;
	reg read_invalid_addr;
	reg flash_nerase_reg /* synthesis noprune */;
	reg flash_nprogram_reg /* synthesis noprune */;
	reg flash_arshft_reg /* synthesis noprune */;
	reg flash_drshft_reg /* synthesis noprune */;
	reg flash_drdin_neg_reg /* synthesis noprune */;
	reg flash_busy_reg;
	reg flash_se_pass_reg;
	reg flash_sp_pass_reg;
	reg read_wait;
	reg [2:0] read_count;
	/* add write/erase timeout */
	reg write_busy_timeout /* synthesis noprune */;
	reg erase_busy_timeout /* synthesis noprune */;
	reg write_timeout /* synthesis noprune */;
	reg erase_timeout /* synthesis noprune */;
	
	wire reset_n_w;
	wire [FLASH_ADDR_WIDTH-1:0] avmm_addr_w;
	wire is_addr_within_valid_range;
	wire is_sector1_addr;
	wire is_sector2_addr;
	wire is_sector3_addr;
	wire is_sector4_addr;
	wire is_sector5_addr;
	wire is_sector1_writable;
	wire is_sector2_writable;
	wire is_sector3_writable;
	wire is_sector4_writable;
	wire is_sector5_writable;
	wire is_addr_writable;
	wire is_valid_write_burst_count;
	wire is_valid_wrapping_read_burst_count;
	
	wire is_erase_busy;
	wire is_write_busy;
	wire is_read_busy;
	wire is_busy;
	
	wire [FLASH_ADDR_WIDTH-1:0] flash_ardin_w;
	wire [FLASH_ADDR_WIDTH-1:0] flash_erase_addr;
	wire [FLASH_ADDR_WIDTH-1:0] flash_read_addr;
	wire [FLASH_ADDR_WIDTH-1:0] next_flash_read_ardin;
	
	wire [19:0] csr_page_erase_addr;
	wire [2:0] csr_sector_erase_addr;
	wire valid_csr_sector_erase_addr;
	wire [1:0] csr_erase_state;
	wire [4:0] csr_write_protection_mode;
	wire valid_csr_erase;
	wire valid_command;
	wire flash_drdin_w;
	wire flash_drclk_en_w;
	wire flash_arclk_arshft_en_w;
	wire write_wait_w;
	wire write_invalid_addr_w;
	
	// avoid async reset removal issue 
	assign reset_n_w = reset_n_reg2;
	assign avmm_addr_w = ({{(FLASH_ADDR_WIDTH-AVMM_DATA_ADDR_WIDTH){1'b0}}, avmm_addr} + MIN_VALID_ADDR[FLASH_ADDR_WIDTH-1:0]);
	
	generate // generate combi based on read and write mode
		if (READ_AND_WRITE_MODE == 1) begin
			assign is_erase_busy = (erase_state != ERASE_STATE_IDLE);
			assign is_write_busy = (write_state != WRITE_STATE_IDLE);
			assign is_read_busy = (read_state != READ_STATE_IDLE);
			assign is_busy = is_erase_busy || is_write_busy || is_read_busy;
		end
		else begin
			assign is_erase_busy = 1'b0;
			assign is_write_busy = 1'b0;
			assign is_read_busy = (read_state != READ_STATE_IDLE);
			assign is_busy = is_read_busy;
		end
	endgenerate
	
	assign csr_page_erase_addr = csr_control[19:0];
	assign csr_sector_erase_addr = csr_control[22:20];
	assign csr_erase_state = csr_control[31:30];
	assign csr_write_protection_mode = csr_control[27:23];
	assign valid_csr_sector_erase_addr = (csr_sector_erase_addr != {(3){1'b1}});
	assign valid_csr_erase = (csr_erase_state == ERASE_ST_PENDING);
	assign valid_command = (valid_csr_erase == 1) || (avmm_write == 1) || (avmm_read == 1);
	
	generate // generate combi based on read burst mode
		if (WRAPPING_BURST_MODE == 0) begin
			// incrementing read
			assign flash_read_addr = (is_read_busy) ? flash_seq_read_ardin : avmm_addr_w;
			assign flash_ardin_w = (valid_csr_erase) ? flash_erase_addr : flash_read_addr;
			assign flash_arclk_arshft_en_w = (~is_erase_busy && ~is_write_busy && ~is_read_busy && valid_command) || (is_read_busy && read_state == READ_STATE_FINAL);
			assign flash_se = ((is_read_busy && read_state == READ_STATE_SETUP) && enable_arclk_neg_pos_reg);
			assign avmm_waitrequest = ~reset_n || (((~is_write_busy && avmm_write) || (is_busy && avmm_read) || write_wait) && (~write_invalid_addr));
			assign next_flash_read_ardin = {flash_seq_read_ardin[FLASH_ADDR_WIDTH-1:FLASH_ADDR_ALIGNMENT_BITS], {(FLASH_ADDR_ALIGNMENT_BITS){1'b0}}} + FLASH_SEQ_READ_DATA_COUNT[22:0];
		end
		else begin
			// wrapping read
			assign flash_ardin_w = (valid_csr_erase) ? flash_erase_addr : avmm_addr_w;
			assign flash_arclk_arshft_en_w = (~is_erase_busy && ~is_write_busy && ~is_read_busy && valid_command) || (read_wait && read_ctrl_count == 1 && avmm_read);
			assign flash_se = ((read_state == READ_STATE_READ && read_ctrl_count==FLASH_READ_CYCLE_MAX_INDEX+1) && enable_arclk_neg_pos_reg);
			assign avmm_waitrequest = ~reset_n || (((~is_write_busy && avmm_write) || write_wait_w || (~is_read_busy && avmm_read) || (avmm_read && read_wait)) && (~write_invalid_addr_w && ~read_invalid_addr));
		end
	endgenerate
	
	assign flash_erase_addr = (valid_csr_sector_erase_addr) ? { csr_sector_erase_addr, 1'b0, {(19){1'b1}} } : { {(3){1'b0}}, (csr_page_erase_addr+MIN_VALID_ADDR[19:0]) };
	assign flash_arclk = (~enable_arclk_neg_reg || clock || enable_arclk_neg_pos_reg);
	assign flash_arshft = flash_arshft_reg;
	assign flash_drshft = flash_drshft_reg;
	assign flash_drdin = flash_drdin_neg_reg;
	assign flash_nerase = flash_nerase_reg;
	assign flash_nprogram = flash_nprogram_reg;
	assign flash_xe_ye = ((~is_busy && avmm_read) || is_read_busy);
	assign flash_ardin = flash_ardin_w;
	assign avmm_readdatavalid = avmm_readdatavalid_reg;
	assign avmm_readdata = (read_invalid_addr) ? 32'hffffffff : flash_drdout;
	assign is_valid_wrapping_read_burst_count = (avmm_burstcount == FLASH_SEQ_READ_DATA_COUNT[AVMM_DATA_BURSTCOUNT_WIDTH-1:0]);
	assign is_addr_within_valid_range = (flash_ardin_w >= MIN_VALID_ADDR) && (flash_ardin_w <= MAX_VALID_ADDR);

	generate // generate combi based on read and write mode
		if (READ_AND_WRITE_MODE == 1) begin
			assign csr_status = { SECTOR_READ_PROTECTION_MODE[4:0], csr_status_e_pass, csr_status_w_pass, csr_status_r_pass, csr_status_busy};
			assign flash_drclk_en_w = (write_drclk_en || read_drclk_en);
			assign flash_drclk = (~enable_drclk_neg_reg || clock || enable_drclk_neg_pos_reg || enable_drclk_neg_pos_write_reg);
			assign is_valid_write_burst_count = (avmm_burstcount == 1);
			assign write_wait_w = write_wait;
			assign write_invalid_addr_w = write_invalid_addr;
			assign is_sector1_addr = (valid_csr_erase && valid_csr_sector_erase_addr) ? (csr_sector_erase_addr == 1) : ((flash_ardin_w >= SECTOR1_START_ADDR) && (flash_ardin_w <= SECTOR1_END_ADDR));
			assign is_sector2_addr = (valid_csr_erase && valid_csr_sector_erase_addr) ? (csr_sector_erase_addr == 2) : ((flash_ardin_w >= SECTOR2_START_ADDR) && (flash_ardin_w <= SECTOR2_END_ADDR));
			assign is_sector3_addr = (valid_csr_erase && valid_csr_sector_erase_addr) ? (csr_sector_erase_addr == 3) : ((flash_ardin_w >= SECTOR3_START_ADDR) && (flash_ardin_w <= SECTOR3_END_ADDR));
			assign is_sector4_addr = (valid_csr_erase && valid_csr_sector_erase_addr) ? (csr_sector_erase_addr == 4) : ((flash_ardin_w >= SECTOR4_START_ADDR) && (flash_ardin_w <= SECTOR4_END_ADDR));
			assign is_sector5_addr = (valid_csr_erase && valid_csr_sector_erase_addr) ? (csr_sector_erase_addr == 5) : ((flash_ardin_w >= SECTOR5_START_ADDR) && (flash_ardin_w <= SECTOR5_END_ADDR));
			assign is_sector1_writable = ~(csr_write_protection_mode[0] || SECTOR_READ_PROTECTION_MODE[0]) && is_sector1_addr;
			assign is_sector2_writable = ~(csr_write_protection_mode[1] || SECTOR_READ_PROTECTION_MODE[1]) && is_sector2_addr;
			assign is_sector3_writable = ~(csr_write_protection_mode[2] || SECTOR_READ_PROTECTION_MODE[2]) && is_sector3_addr;
			assign is_sector4_writable = ~(csr_write_protection_mode[3] || SECTOR_READ_PROTECTION_MODE[3]) && is_sector4_addr;
			assign is_sector5_writable = ~(csr_write_protection_mode[4] || SECTOR_READ_PROTECTION_MODE[4]) && is_sector5_addr;
			assign is_addr_writable = (is_sector1_writable ||
									   is_sector2_writable ||
									   is_sector3_writable ||
									   is_sector4_writable ||
									   is_sector5_writable);			
		end
		else begin
			assign csr_status = 10'b0000000000;
			assign flash_drclk_en_w = read_drclk_en;
			assign flash_drclk = (~enable_drclk_neg_reg || clock || enable_drclk_neg_pos_reg);
			assign write_wait_w = 1'b0;
			assign write_invalid_addr_w = 1'b0;
		end
	endgenerate
	
	// initial register
	initial begin
		csr_status_busy = STATUS_IDLE;
		csr_status_e_pass = 0;
		csr_status_w_pass = 0;
		csr_status_r_pass = 0;
		avmm_burstcount_input_reg = {(AVMM_DATA_BURSTCOUNT_WIDTH){1'b0}};
		avmm_burstcount_reg = {(AVMM_DATA_BURSTCOUNT_WIDTH){1'b0}};
		erase_state = ERASE_STATE_IDLE;
		write_state = WRITE_STATE_IDLE;
		read_state = READ_STATE_IDLE;
		avmm_read_state = READ_SETUP;
		avmm_read_valid_state = READ_VALID_IDLE;
		avmm_readdatavalid_reg = 0;
		avmm_readdata_ready = 0;
		flash_ardin_align_reg = {(FLASH_ADDR_ALIGNMENT_BITS){1'b0}};
		flash_ardin_align_backup_reg = {(FLASH_ADDR_ALIGNMENT_BITS){1'b0}};
		write_drclk_en = 0;
		read_drclk_en = 0;
		flash_nerase_reg = 1;
		flash_nprogram_reg = 1;
		flash_arshft_reg = 1;
		flash_drshft_reg = 1;
		flash_drdin_neg_reg = 0;
		flash_busy_reg = 0;
		flash_se_pass_reg = 0;
		flash_sp_pass_reg = 0;
		flash_seq_read_ardin = 0;
		enable_arclk_neg_reg = 0;
		enable_arclk_neg_pos_reg = 0;
		enable_drclk_neg_reg = 0;
		enable_drclk_neg_pos_reg = 0;
		enable_drclk_neg_pos_write_reg = 0;
		write_count = 0;
		erase_count = 0;
		read_ctrl_count = 0;		
		data_count = 0;
		write_wait = 0;
		reset_n_reg1 = 0;
		reset_n_reg2 = 0;
		write_invalid_addr = 0;
		read_invalid_addr = 0;
		read_wait = 0;
		read_count = 0;
		write_busy_timeout = 0;
		erase_busy_timeout = 0;
		write_timeout = 0;
		erase_timeout = 0;
	end
	
	// -------------------------------------------------------------------
	// Avoid async reset removal issue 
	// -------------------------------------------------------------------
	always @ (negedge reset_n or posedge clock) begin
		if (~reset_n) begin
			{reset_n_reg2, reset_n_reg1} <= 2'b0;
		end
		else begin
			{reset_n_reg2, reset_n_reg1} <= {reset_n_reg1, 1'b1};
		end
	end

	// -------------------------------------------------------------------
	// Get rid of the race condition between different dynamic clock. Trigger clock enable in early half cycle.
	// -------------------------------------------------------------------
	always @ (negedge clock) begin
		if (~reset_n_w) begin
			enable_arclk_neg_reg <= 0;
			enable_drclk_neg_reg <= 0;
			// Get rid of the race condition of shftreg signal (drdin), add half cycle delay to the data
			flash_drdin_neg_reg <= 0;
		end
		else begin
			enable_arclk_neg_reg <= flash_arclk_arshft_en_w;
			enable_drclk_neg_reg <= flash_drclk_en_w;
			// Get rid of the race condition of shftreg signal (drdin), add half cycle delay to the data
			flash_drdin_neg_reg <= flash_drdin_w;
		end
	end

	// -------------------------------------------------------------------
	// Get rid of glitch for pos clock
	// -------------------------------------------------------------------
	always @ (posedge clock) begin
		if (~reset_n_w) begin
			enable_arclk_neg_pos_reg <= 0;
			flash_arshft_reg <= 1;
		end
		else begin
			enable_arclk_neg_pos_reg <= enable_arclk_neg_reg;
			flash_arshft_reg <= 1;
		end
	end

	generate // generate always block based on read and write mode. Write and erase operation is unnecessary in read only mode.

		if (READ_AND_WRITE_MODE == 1) begin
			// -------------------------------------------------------------------
			// Update CSR busy status
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					csr_status_busy <= STATUS_IDLE;
				end
				else begin
					if (is_erase_busy) begin
						csr_status_busy <= STATUS_BUSY_ERASE;
					end
					else if (is_write_busy) begin
						csr_status_busy <= STATUS_BUSY_WRITE;
					end
					else if (is_read_busy) begin
						csr_status_busy <= STATUS_BUSY_READ;
					end
					else begin
						csr_status_busy <= STATUS_IDLE;
					end
				end
			end
			
			// -------------------------------------------------------------------
			// Monitor and store flash busy signal, it may faster then the clock
			// -------------------------------------------------------------------
			always @ (negedge reset_n or negedge is_busy or posedge flash_busy) begin
				if (~reset_n || ~is_busy) begin
					flash_busy_reg <= 0;
				end
				else begin
					flash_busy_reg <= 1;
				end
			end
			
			// -------------------------------------------------------------------
			// Monitor flash pass signal
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					flash_se_pass_reg <= 0;
					flash_sp_pass_reg <= 0;
				end
				else begin
					flash_se_pass_reg <= flash_se_pass;
					flash_sp_pass_reg <= flash_sp_pass;
				end
			end
			
			// -------------------------------------------------------------------
			// Avalon_MM data interface fsm - communicate between Avalon_MM and Flash IP (Write Operation)
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					write_state <= WRITE_STATE_IDLE;
					csr_status_w_pass <= 0;
					write_wait <= 0;
				end
				else begin
					case (write_state)
						WRITE_STATE_IDLE: begin
							// reset all register
							write_drclk_en <= 0;
							write_count <= 0;
							write_busy_timeout <= 0;
							write_timeout <= 0;
							write_invalid_addr <= 0;
							enable_drclk_neg_pos_write_reg <= 0;
							flash_nprogram_reg <= 1;
							
							// check command
							if (avmm_write) begin
								write_wait <= 1;
								if (~valid_csr_erase && ~is_erase_busy && ~is_read_busy) begin
									// address legality check
									if (is_addr_writable && is_valid_write_burst_count) begin
										write_state <= WRITE_STATE_WRITE;
										write_count <= DATA_WIDTH;
									end
									else begin
										write_state <= WRITE_STATE_ERROR;
										write_wait <= 0;
										write_invalid_addr <= 1;
										write_count <= 2;
									end
								end
							end
						end

						WRITE_STATE_WRITE: begin
							if (write_count > 0) begin
								write_drclk_en <= 1;
								write_count <= write_count - 1;
							end
							else begin
								flash_nprogram_reg <= 0;
								enable_drclk_neg_pos_write_reg <= 1;
								write_drclk_en <= 0;
								write_count <= FLASH_BUSY_TIMEOUT_CYCLE_MAX_INDEX;
								write_state <= WRITE_STATE_WAIT_BUSY;
							end
						end				

						WRITE_STATE_WAIT_BUSY: begin
							if (flash_busy_reg) begin
								write_count <= FLASH_WRITE_TIMEOUT_CYCLE_MAX_INDEX;
								write_state <= WRITE_STATE_WAIT_DONE;
							end
							else begin
								if (write_count == 0) begin
									write_busy_timeout <= 1;
									write_count <= FLASH_WRITE_TIMEOUT_CYCLE_MAX_INDEX;
									write_state <= WRITE_STATE_WAIT_DONE;
								end
								else begin
									write_count <= write_count - 1;
								end
							end
						end
						
						WRITE_STATE_WAIT_DONE: begin
							if (~flash_busy) begin
								flash_nprogram_reg <= 1;
								write_count <= FLASH_RESET_CYCLE_MAX_INDEX;
								write_state <= WRITE_STATE_RESET;
							end
							else begin
								if (write_count == 0) begin
									write_timeout <= 1;
									write_count <= FLASH_RESET_CYCLE_MAX_INDEX;
									write_state <= WRITE_STATE_RESET;
								end
								else begin
									write_count <= write_count - 1;
								end
							end
						end

						WRITE_STATE_RESET: begin
							if (write_busy_timeout || write_timeout) begin
								csr_status_w_pass <= 0;
							end
							else begin
								csr_status_w_pass <= flash_sp_pass_reg;
							end
							if (write_count == 1) begin
								write_wait <= 0;
							end
							if (write_count > 0) begin
								write_count <= write_count - 1;
							end
							else begin
								write_state <= WRITE_STATE_IDLE;
							end
						end
						
						WRITE_STATE_ERROR: begin
							csr_status_w_pass <= 0;
							if (write_count > 0) begin
								write_count <= write_count - 1;
							end
							else begin
								write_state <= WRITE_STATE_IDLE;
							end
						end
						
						default: begin
							write_state <= WRITE_STATE_IDLE;
						end
						
					endcase
				end
			end	

			// -------------------------------------------------------------------
			// Avalon_MM data interface fsm - communicate between Avalon_MM and Flash IP (Erase Operation)
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					erase_state <= ERASE_STATE_IDLE;
					csr_status_e_pass <= 0;
				end
				else begin
					case (erase_state)

						ERASE_STATE_IDLE: begin
							// reset all register
							erase_count <= 0;
							erase_busy_timeout <= 0;
							erase_timeout <= 0;
							flash_nerase_reg <= 1;
							
							// check command
							if (valid_csr_erase && ~is_write_busy && ~is_read_busy) begin
								// address legality check
								if (is_addr_writable) begin
									flash_nerase_reg <= 0;
									erase_count <= FLASH_BUSY_TIMEOUT_CYCLE_MAX_INDEX;
									erase_state <= ERASE_STATE_WAIT_BUSY;
								end
								else begin
									erase_state <= ERASE_STATE_ERROR;
									erase_count <= 2;
								end
							end
						end

						ERASE_STATE_WAIT_BUSY: begin
							if (flash_busy_reg) begin
								erase_count <= FLASH_ERASE_TIMEOUT_CYCLE_MAX_INDEX;
								erase_state <= ERASE_STATE_WAIT_DONE;
							end
							else begin
								if (erase_count == 0) begin
									erase_busy_timeout <= 1;
									erase_count <= FLASH_ERASE_TIMEOUT_CYCLE_MAX_INDEX;
									erase_state <= ERASE_STATE_WAIT_DONE;
								end
								else begin
									erase_count <= erase_count - 1;
								end
							end
						end

						ERASE_STATE_WAIT_DONE: begin
							if (~flash_busy) begin
								flash_nerase_reg <= 1;
								erase_count <= FLASH_RESET_CYCLE_MAX_INDEX;
								erase_state <= ERASE_STATE_RESET;
							end
							else begin
								if (erase_count == 0) begin
									erase_timeout <= 1;
									erase_count <= FLASH_RESET_CYCLE_MAX_INDEX;
									erase_state <= ERASE_STATE_RESET;
								end
								else begin
									erase_count <= erase_count - 1;
								end
							end
						end

						ERASE_STATE_RESET: begin
							if (erase_busy_timeout || erase_timeout) begin
								csr_status_e_pass <= 0;
							end
							else begin
								csr_status_e_pass <= flash_se_pass_reg;
							end
							if (erase_count > 0) begin
								erase_count <= erase_count - 1;
							end
							else begin
								erase_state <= ERASE_STATE_IDLE;
							end
						end

						ERASE_STATE_ERROR: begin
							csr_status_e_pass <= 0;
							if (erase_count > 0) begin
								erase_count <= erase_count - 1;
							end
							else begin
								erase_state <= ERASE_STATE_IDLE;
							end
						end
						
						default: begin
							erase_state <= ERASE_STATE_IDLE;
						end
						
					endcase
				end
			end
			
			// -------------------------------------------------------------------
			// Instantiate a shift register to send the data to UFM serially (load parallel)
			// -------------------------------------------------------------------
			lpm_shiftreg # (
				.lpm_type ("LPM_SHIFTREG"),
				.lpm_width (DATA_WIDTH),
				.lpm_direction ("LEFT")
			) ufm_data_shiftreg (
				.data(avmm_writedata),
				.clock(clock),
				.enable(write_state == WRITE_STATE_WRITE),
				.load(write_count == DATA_WIDTH),
				.shiftout(flash_drdin_w),
				.aclr(write_state == WRITE_STATE_IDLE)
			);			
		end
		else begin
			// fixed signal for read only mode
			assign flash_drdin_w = 1'b0;
			
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					flash_nerase_reg <= 1;
					flash_nprogram_reg <= 1;
				end
				else begin
					flash_nerase_reg <= 1;
					flash_nprogram_reg <= 1;
				end
			end
		end
	endgenerate
	
	generate // generate always block for read operation based on read burst mode.
		if (WRAPPING_BURST_MODE == 0) begin
			// -------------------------------------------------------------------
			// Avalon_MM data interface fsm - communicate between Avalon_MM and Flash IP (Increamenting Burst Read Operation)
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					read_state <= READ_STATE_IDLE;
					csr_status_r_pass <= 0;
				end
				else begin
					case (read_state)

						READ_STATE_IDLE: begin
							// reset all register
							avmm_read_state <= READ_SETUP;
							avmm_readdata_ready <= 0;
							flash_ardin_align_reg <= 0;
							read_ctrl_count <= 0;
							read_invalid_addr <= 0;
							avmm_burstcount_input_reg <= 0;
							enable_drclk_neg_pos_reg <= 0;
							read_drclk_en <= 0;
							flash_drshft_reg <= 1;
							
							// check command
							if (avmm_read) begin
								if (~valid_csr_erase && ~is_erase_busy && ~is_write_busy) begin
								
									if (is_addr_within_valid_range) begin
										csr_status_r_pass <= 1;
										read_invalid_addr <= 0;
									end
									else begin
										csr_status_r_pass <= 0;
										read_invalid_addr <= 1;
									end
								
									read_state <= READ_STATE_SETUP;
									flash_seq_read_ardin <= avmm_addr_w;
									avmm_burstcount_input_reg <= avmm_burstcount;
								end
							end
						end
						
						// incrementing read
						READ_STATE_SETUP: begin
							if (next_flash_read_ardin > MAX_VALID_ADDR) begin
								flash_seq_read_ardin <= MIN_VALID_ADDR[FLASH_ADDR_WIDTH-1:0];
							end
							else begin
								flash_seq_read_ardin <= next_flash_read_ardin;
							end
							flash_ardin_align_reg <= flash_seq_read_ardin[FLASH_ADDR_ALIGNMENT_BITS-1:0];
							if (FLASH_READ_CYCLE_MAX_INDEX[2:0] > 2) begin
								read_ctrl_count <= FLASH_READ_CYCLE_MAX_INDEX[2:0] - 3'd2;
								read_state <= READ_STATE_DUMMY;
							end
							else begin
								read_state <= READ_STATE_READY;
							end
						end

						READ_STATE_DUMMY: begin
							if (read_ctrl_count > 1) begin
								read_ctrl_count <= read_ctrl_count - 3'd1;
							end
							else begin
								read_state <= READ_STATE_READY;
							end
						end

						READ_STATE_READY: begin
							if (avmm_read_state == READ_SETUP) begin
								avmm_readdata_ready <= 1;
							end
							read_drclk_en <= 1;
							flash_drshft_reg <= 0;
							read_state <= READ_STATE_FINAL;
						end
						
						READ_STATE_FINAL: begin
							flash_drshft_reg <= 1;
							avmm_readdata_ready <= 0;
							avmm_read_state <= READ_RECV_DATA;

							if ((avmm_read_state == READ_RECV_DATA) && (avmm_burstcount_reg == 0)) begin
								read_state <= READ_STATE_CLEAR;
								read_drclk_en <= 0;
								enable_drclk_neg_pos_reg <= 1;
							end
							else begin
								read_state <= READ_STATE_SETUP;
							end
						end

						// Dummy state to clear arclk glitch
						READ_STATE_CLEAR: begin
							read_state <= READ_STATE_IDLE;
						end

						default: begin
							read_state <= READ_STATE_IDLE;
						end
						
					endcase
				end
			end	
		end
		else begin
			// -------------------------------------------------------------------
			// Avalon_MM data interface fsm - communicate between Avalon_MM and Flash IP (Wrapping Burst Read Operation)
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					read_state <= READ_STATE_IDLE;
					read_wait <= 0;
				end
				else begin
					case (read_state)

						READ_STATE_IDLE: begin
							// reset all register
							avmm_readdata_ready <= 0;
							flash_ardin_align_reg <= 0;
							read_ctrl_count <= 0;
							read_invalid_addr <= 0;
							enable_drclk_neg_pos_reg <= 0;
							flash_drshft_reg <= 1;
							read_drclk_en <= 0;
							
							// check command
							if (avmm_read) begin
								if (~valid_csr_erase && ~is_erase_busy && ~is_write_busy) begin
									read_wait <= 1;
									if (is_addr_within_valid_range && is_valid_wrapping_read_burst_count) begin
										csr_status_r_pass <= 1;
										read_invalid_addr <= 0;
									end
									else begin
										csr_status_r_pass <= 0;
										read_invalid_addr <= 1;
									end
									
									read_state <= READ_STATE_READ;
									read_ctrl_count <= FLASH_READ_CYCLE_MAX_INDEX[2:0] + 3'd1;
								end
							end
						end
						
						// wrapping read
						READ_STATE_READ: begin
							
							// read control signal
							if (read_ctrl_count > 0) begin
								read_ctrl_count <= read_ctrl_count - 3'd1;
							end
							if (read_ctrl_count == 4) begin
								read_wait <= 0;
							end
							if (read_ctrl_count == 2) begin
								avmm_readdata_ready <= 1;
								read_drclk_en <= 1;
								flash_drshft_reg <= 0;
							end
							else begin
								flash_drshft_reg <= 1;
							end
							if (avmm_read && ~read_wait) begin
								read_wait <= 1;
							end
							if (avmm_readdata_ready || read_ctrl_count == 0) begin
								avmm_readdata_ready <= 0;
								if (avmm_read) begin
									if (is_addr_within_valid_range && is_valid_wrapping_read_burst_count) begin
										csr_status_r_pass <= 1;
										read_invalid_addr <= 0;
									end
									else begin
										csr_status_r_pass <= 0;
										read_invalid_addr <= 1;
									end
									read_ctrl_count <= FLASH_READ_CYCLE_MAX_INDEX[2:0] + 3'd1;
								end
							end
							
							// read data signal
							if (read_count > 0) begin
								read_count <= read_count - 3'd1;
							end
							else begin
								if (avmm_readdata_ready) begin
									read_count <= FLASH_SEQ_READ_DATA_COUNT[2:0] - 3'd1;
								end
							end
							
							// back to idle if both control and read cycle are finished
							if (read_ctrl_count == 0 && read_count == 0 && ~avmm_read) begin
								read_state <= READ_STATE_IDLE;
								read_drclk_en <= 0;
								read_wait <= 0;
								enable_drclk_neg_pos_reg <= 1;
							end
							
						end

						default: begin
							read_state <= READ_STATE_IDLE;
						end
						
					endcase
				end
			end
		end
	endgenerate

	generate // generate readdatavalid control signal always block based on read burst mode.
		if (WRAPPING_BURST_MODE == 0) begin
			// -------------------------------------------------------------------
			// Control readdatavalid signal - incrementing read
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					avmm_read_valid_state <= READ_VALID_IDLE;
					avmm_burstcount_reg <= 0;
					avmm_readdatavalid_reg <= 0;
					flash_ardin_align_backup_reg <= 0;
					data_count <= 0;
				end
				else begin
					case (avmm_read_valid_state)
						READ_VALID_IDLE: begin
							if (avmm_readdata_ready) begin
								data_count <= FLASH_READ_CYCLE_MAX_INDEX[2:0];
								avmm_read_valid_state <= READ_VALID_READING;
								avmm_readdatavalid_reg <= 1;
								avmm_burstcount_reg <= avmm_burstcount_input_reg - 1;
								flash_ardin_align_backup_reg <= flash_ardin_align_reg;
							end
						end
						
						READ_VALID_READING: begin

							if (avmm_burstcount_reg == 0) begin
								avmm_read_valid_state <= READ_VALID_IDLE;
								avmm_readdatavalid_reg <= 0;
							end
							else begin
								if (data_count > 0) begin
									if ((FLASH_READ_CYCLE_MAX_INDEX - data_count + 1 + flash_ardin_align_backup_reg) < FLASH_SEQ_READ_DATA_COUNT) begin
										avmm_readdatavalid_reg <= 1;
										avmm_burstcount_reg <= avmm_burstcount_reg - 1;
									end
									else begin
										avmm_readdatavalid_reg <= 0;
									end
									data_count <= data_count - 3'd1;
								end
								else begin
									flash_ardin_align_backup_reg <= 0;
									data_count <= FLASH_READ_CYCLE_MAX_INDEX[2:0];
									avmm_readdatavalid_reg <= 1;
									avmm_burstcount_reg <= avmm_burstcount_reg - 1;
								end
							end
						end
						
						default: begin
							avmm_read_valid_state <= READ_VALID_IDLE;
							avmm_burstcount_reg <= 0;
							avmm_readdatavalid_reg <= 0;
							flash_ardin_align_backup_reg <= 0;
							data_count <= 0;
						end
					endcase
				end
			end
		end
		else begin
			// -------------------------------------------------------------------
			// Control readdatavalid signal - wrapping read with fixed burst count
			//     Burst count
			//         2 - ZB2/ZB8
			//         4 - all other devices
			// -------------------------------------------------------------------		
			always @ (posedge clock) begin
				if (~reset_n_w) begin
					avmm_read_valid_state <= READ_VALID_IDLE;
				end
				else begin
					case (avmm_read_valid_state)
						READ_VALID_IDLE: begin
							avmm_readdatavalid_reg <= 0;
							data_count <= 0;
							if (avmm_readdata_ready) begin
								data_count <= FLASH_SEQ_READ_DATA_COUNT[2:0] - 3'd1;
								avmm_read_valid_state <= READ_VALID_READING;
								avmm_readdatavalid_reg <= 1;
							end
						end
						
						READ_VALID_READING: begin
							if (data_count > 0) begin
								data_count <= data_count - 3'd1;
							end
							else begin
								if (avmm_readdata_ready) begin
									data_count <= FLASH_SEQ_READ_DATA_COUNT[2:0] - 3'd1;
								end
								else begin
									avmm_readdatavalid_reg <= 0;
									avmm_read_valid_state <= READ_VALID_IDLE;
								end
							end
						end
						
						default: begin
							avmm_read_valid_state <= READ_VALID_IDLE;
						end
					endcase
				end
			end
		end
	endgenerate

endmodule

