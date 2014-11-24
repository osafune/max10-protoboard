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


module altera_modular_adc_control_fsm (
    input               clk, 
    input               rst_n,
    input               clk_in_pll_locked,
    input               cmd_valid,
    input [4:0]         cmd_channel,
    input               cmd_sop,
    input               cmd_eop,
    input               clk_dft,
    input               eoc,
    input [11:0]        dout,

    output reg          rsp_valid,
    output reg [4:0]    rsp_channel,
    output reg [11:0]   rsp_data,
    output reg          rsp_sop,
    output reg          rsp_eop,
    output reg          cmd_ready,
    output reg [4:0]    chsel,
    output reg          soc,
    output reg          usr_pwd,
    output reg          tsen

);

reg [3:0]   ctrl_state;
reg [3:0]   ctrl_state_nxt;
reg         clk_dft_synch_dly;
reg         eoc_synch_dly;
reg [4:0]   chsel_nxt;
reg         soc_nxt;
reg         usr_pwd_nxt;
reg         tsen_nxt;
reg         prev_cmd_is_ts;
reg         cmd_fetched;
reg         pend;
reg [4:0]   cmd_channel_dly;
reg         cmd_sop_dly;
reg         cmd_eop_dly;
reg [7:0]   int_timer;

wire        clk_dft_synch;
wire        eoc_synch;
wire        clk_dft_lh;
wire        clk_dft_hl;
wire        eoc_hl;
wire        cmd_is_rclb;
wire        cmd_is_ts;
wire        arc_to_putresp;
wire        arc_conv_putresp;
wire        arc_pwrup_soc_putresp;
wire        arc_wait_pend_putresp_pend;
wire        load_rsp;
wire        load_cmd_ready;
wire        arc_getcmd_w_pwrdwn;
wire        arc_getcmd_pwrdwn;
wire        load_cmd_fetched;
wire        load_int_timer;
wire        incr_int_timer;
wire        arc_out_from_pwrup_soc;
wire        clr_cmd_fetched;
wire        adc_change_mode;


localparam [3:0]    IDLE            = 4'b0000;
localparam [3:0]    PWRDWN          = 4'b0001;
localparam [3:0]    PWRDWN_TSEN     = 4'b0010;
localparam [3:0]    PWRDWN_DONE     = 4'b0011;
localparam [3:0]    PWRUP_CH        = 4'b0100;
localparam [3:0]    PWRUP_SOC       = 4'b0101;
localparam [3:0]    WAIT            = 4'b0110;
localparam [3:0]    GETCMD          = 4'b0111;
localparam [3:0]    GETCMD_W        = 4'b1000;
localparam [3:0]    PRE_CONV        = 4'b1001;
localparam [3:0]    CONV            = 4'b1010;
localparam [3:0]    PUTRESP         = 4'b1011;
localparam [3:0]    PUTRESP_DLY1    = 4'b1100;
localparam [3:0]    PUTRESP_DLY2    = 4'b1101;
localparam [3:0]    WAIT_PEND       = 4'b1110;
localparam [3:0]    PUTRESP_PEND    = 4'b1111;

//--------------------------------------------------------------------------------------------//
// Double Synchronize control signal from ADC hardblock
//--------------------------------------------------------------------------------------------//
altera_std_synchronizer #(
    .depth    (2)
) u_clk_dft_synchronizer (
    .clk        (clk),
    .reset_n    (rst_n),
    .din        (clk_dft),
    .dout       (clk_dft_synch)
);

altera_std_synchronizer #(
    .depth    (2)
) u_eoc_synchronizer (
    .clk        (clk),
    .reset_n    (rst_n),
    .din        (eoc),
    .dout       (eoc_synch)
);



//--------------------------------------------------------------------------------------------//
// Edge detection for both synchronized clk_dft and eoc
//--------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_dft_synch_dly   <= 1'b0;
        eoc_synch_dly       <= 1'b0;
    end
    else begin
        clk_dft_synch_dly   <= clk_dft_synch;
        eoc_synch_dly       <= eoc_synch;
    end
end

assign clk_dft_lh   = clk_dft_synch & ~clk_dft_synch_dly;
assign clk_dft_hl   = ~clk_dft_synch & clk_dft_synch_dly;
assign eoc_hl       = ~eoc_synch & eoc_synch_dly;



//--------------------------------------------------------------------------------------------//
// Main FSM
//--------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        ctrl_state   <= IDLE;
    else
        ctrl_state   <= ctrl_state_nxt;
end

always @* begin
    case (ctrl_state)
        IDLE: begin
            if (clk_in_pll_locked)
                ctrl_state_nxt = PWRDWN;
            else
                ctrl_state_nxt = IDLE;
        end

        PWRDWN: begin
            if (int_timer[6])
                ctrl_state_nxt = PWRDWN_TSEN;
            else
                ctrl_state_nxt = PWRDWN;
        end

        PWRDWN_TSEN: begin
            if (int_timer[7])
                ctrl_state_nxt = PWRDWN_DONE;
            else
                ctrl_state_nxt = PWRDWN_TSEN;
        end

        PWRDWN_DONE: begin
            if (clk_dft_lh)
                ctrl_state_nxt = PWRUP_CH;
            else
                ctrl_state_nxt = PWRDWN_DONE;
        end

        PWRUP_CH: begin
            if (clk_dft_hl)
                ctrl_state_nxt = PWRUP_SOC;
            else
                ctrl_state_nxt = PWRUP_CH;
        end

        PWRUP_SOC: begin
            if (cmd_fetched & ~cmd_is_rclb & eoc_hl)
                ctrl_state_nxt = CONV;
            else if (cmd_fetched & cmd_is_rclb & eoc_hl)
                ctrl_state_nxt = PUTRESP;
            else if (cmd_valid & eoc_hl)
                ctrl_state_nxt = GETCMD;
            else if (eoc_hl)
                ctrl_state_nxt = WAIT;
            else
                ctrl_state_nxt = PWRUP_SOC;
        end

        WAIT: begin
            if (cmd_valid)
                ctrl_state_nxt = GETCMD_W;
            else
                ctrl_state_nxt = WAIT;
        end

        GETCMD_W: begin
            if (cmd_is_rclb | adc_change_mode)
                ctrl_state_nxt = PWRDWN;
            else
                ctrl_state_nxt = PRE_CONV;
        end

        PRE_CONV: begin
            if (eoc_hl)
                ctrl_state_nxt = CONV;
            else
                ctrl_state_nxt = PRE_CONV;
        end

        GETCMD: begin
            if ((cmd_is_rclb | adc_change_mode) & ~pend)
                ctrl_state_nxt = PWRDWN;
            else if ((cmd_is_rclb | adc_change_mode) & pend)
                ctrl_state_nxt = WAIT_PEND;
            else
                ctrl_state_nxt = CONV;
        end

        CONV: begin
            if (eoc_hl)
                ctrl_state_nxt = PUTRESP;
            else
                ctrl_state_nxt = CONV;
        end

        PUTRESP: begin
            ctrl_state_nxt = PUTRESP_DLY1;
        end
        
        PUTRESP_DLY1: begin
            ctrl_state_nxt = PUTRESP_DLY2;
        end

        PUTRESP_DLY2: begin
            if (cmd_valid)
                ctrl_state_nxt = GETCMD;
            else if (pend)
                ctrl_state_nxt = WAIT_PEND;
            else
                ctrl_state_nxt = WAIT;
        end

        WAIT_PEND: begin
            if (eoc_hl)
                ctrl_state_nxt = PUTRESP_PEND;
            else
                ctrl_state_nxt = WAIT_PEND;
        end

        PUTRESP_PEND: begin
            if (cmd_valid)
                ctrl_state_nxt = GETCMD;
            else
                ctrl_state_nxt = WAIT;
        end

        default: begin
            ctrl_state_nxt = IDLE;
        end

    endcase
end



//--------------------------------------------------------------------------------------------//
// ADC control signal generation from FSM
//--------------------------------------------------------------------------------------------//
always @* begin
    chsel_nxt       = chsel;
    soc_nxt         = soc;
    usr_pwd_nxt     = usr_pwd;
    tsen_nxt        = tsen;

    case (ctrl_state_nxt)
        IDLE: begin
            chsel_nxt   = 5'b11110;
            soc_nxt     = 1'b0;
            usr_pwd_nxt = 1'b1;
            tsen_nxt    = 1'b0;
        end

        PWRDWN: begin
            chsel_nxt   = chsel;
            soc_nxt     = 1'b0;
            usr_pwd_nxt = 1'b1;
            tsen_nxt    = tsen;
        end

        PWRDWN_TSEN: begin
            chsel_nxt   = chsel;
            soc_nxt     = 1'b0;
            usr_pwd_nxt = 1'b1;
            if (cmd_fetched & cmd_is_ts)        // Transition to TS mode
                tsen_nxt    = 1'b1;
            else if (cmd_fetched & cmd_is_rclb) // In recalibration mode, maintain previous TSEN setting
                tsen_nxt    = tsen;
            else
                tsen_nxt    = 1'b0;             // Transition to Normal mode
        end

        PWRDWN_DONE: begin
            chsel_nxt   = chsel;
            soc_nxt     = 1'b0;
            usr_pwd_nxt = 1'b0;
            tsen_nxt    = tsen;
        end

        PWRUP_CH: begin
            chsel_nxt   = 5'b11110;
            soc_nxt     = soc;
            usr_pwd_nxt = 1'b0;
            tsen_nxt    = tsen;
        end

        PWRUP_SOC: begin
            chsel_nxt   = chsel;
            soc_nxt     = 1'b1;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        WAIT: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        GETCMD_W: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        PRE_CONV: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        GETCMD: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        CONV: begin
            chsel_nxt   = cmd_channel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        PUTRESP: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end
        
        PUTRESP_DLY1: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        PUTRESP_DLY2: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        WAIT_PEND: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        PUTRESP_PEND: begin
            chsel_nxt   = chsel;
            soc_nxt     = soc;
            usr_pwd_nxt = usr_pwd;
            tsen_nxt    = tsen;
        end

        default: begin
            chsel_nxt   = 5'bx;
            soc_nxt     = 1'bx;
            usr_pwd_nxt = 1'bx;
            tsen_nxt    = 1'bx;
        end

    endcase
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        chsel       <= 5'b11110;
        soc         <= 1'b0;
        usr_pwd     <= 1'b1;
        tsen        <= 1'b0;
    end
    else begin
        chsel       <= chsel_nxt;
        soc         <= soc_nxt;
        usr_pwd     <= usr_pwd_nxt;
        tsen        <= tsen_nxt;

    end
end



//--------------------------------------------------------------------------------------------//
// Control signal from FSM arc transition
//--------------------------------------------------------------------------------------------//
assign arc_conv_putresp             = (ctrl_state == CONV) & (ctrl_state_nxt == PUTRESP);
assign arc_pwrup_soc_putresp        = (ctrl_state == PWRUP_SOC) & (ctrl_state_nxt == PUTRESP);
assign arc_wait_pend_putresp_pend   = (ctrl_state == WAIT_PEND) & (ctrl_state_nxt == PUTRESP_PEND);
assign arc_to_putresp               = arc_conv_putresp | arc_pwrup_soc_putresp;
assign load_rsp                     = (arc_to_putresp & ~cmd_is_rclb & pend) | arc_wait_pend_putresp_pend;
assign load_cmd_ready               = arc_to_putresp;

assign arc_getcmd_w_pwrdwn          = (ctrl_state == GETCMD_W) & (ctrl_state_nxt == PWRDWN);
assign arc_getcmd_pwrdwn            = (ctrl_state == GETCMD) & (ctrl_state_nxt == PWRDWN);
assign load_cmd_fetched             = arc_getcmd_w_pwrdwn | arc_getcmd_pwrdwn;
assign load_int_timer               = arc_getcmd_w_pwrdwn | arc_getcmd_pwrdwn;
assign incr_int_timer               = (ctrl_state == PWRDWN) | (ctrl_state == PWRDWN_TSEN); 

assign arc_out_from_pwrup_soc       = (ctrl_state == PWRUP_SOC) & (ctrl_state_nxt != PWRUP_SOC);
assign clr_cmd_fetched              = arc_out_from_pwrup_soc;


//--------------------------------------------------------------------------------------------//
// Control signal required by FSM
//--------------------------------------------------------------------------------------------//
assign cmd_is_rclb      = (cmd_channel == 5'b11111);
assign cmd_is_ts        = (cmd_channel == 5'b10001);
assign adc_change_mode  = (~prev_cmd_is_ts & cmd_is_ts) | (prev_cmd_is_ts & ~cmd_is_ts);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        prev_cmd_is_ts  <= 1'b0;
    else if (load_cmd_ready)
        prev_cmd_is_ts  <= cmd_is_ts;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cmd_fetched  <= 1'b0;
    else if (load_cmd_fetched)
        cmd_fetched  <= 1'b1;
    else if (clr_cmd_fetched)
        cmd_fetched  <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pend <= 1'b0;
    else if (arc_conv_putresp)
        pend <= 1'b1;
    else if (arc_wait_pend_putresp_pend)
        pend <= 1'b0;

end



//--------------------------------------------------------------------------------------------//
// Internal timer to ensure soft power down stays at least for 1us 
//--------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        int_timer <= 8'h0;
    else if (load_int_timer)
        int_timer <= 8'h0;
    else if (incr_int_timer)
        int_timer <= int_timer + 8'h1;
end



//--------------------------------------------------------------------------------------------//
// Store up CMD information due to 
// Resp is always one clk_dft later from current cmd (ADC hardblock characteristic)
//--------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cmd_channel_dly <= 5'h0;
        cmd_sop_dly     <= 1'b0;
        cmd_eop_dly     <= 1'b0;
    end
    else if (load_cmd_ready) begin
        cmd_channel_dly <= cmd_channel;
        cmd_sop_dly     <= cmd_sop;
        cmd_eop_dly     <= cmd_eop;
    end
end



//--------------------------------------------------------------------------------------------//
// Avalon ST response interface output register
// Avalon ST command interface output register (cmd_ready)
//--------------------------------------------------------------------------------------------//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rsp_valid   <= 1'b0;
        rsp_channel <= 5'h0;
        rsp_data    <= 12'h0;
        rsp_sop     <= 1'b0;
        rsp_eop     <= 1'b0;
    end
    else if (load_rsp) begin
        rsp_valid   <= 1'b1;
        rsp_channel <= cmd_channel_dly;
        rsp_data    <= dout;
        rsp_sop     <= cmd_sop_dly;
        rsp_eop     <= cmd_eop_dly;
    end 
    else begin
        rsp_valid   <= 1'b0;
        rsp_channel <= 5'h0;
        rsp_data    <= 12'h0;
        rsp_sop     <= 1'b0;
        rsp_eop     <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cmd_ready   <= 1'b0;
    else if (load_cmd_ready)
        cmd_ready   <= 1'b1;
    else
        cmd_ready   <= 1'b0;
end

endmodule
