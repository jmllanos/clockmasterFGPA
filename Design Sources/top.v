/**********************************************************

file: top.v
author: Eloise Perrochet
description:
**********************************************************/
`timescale 1ns / 1ps

//`include "parpadeoLED.v" //prueba de que funciona

`include "address_map.vh"

module top (
    input i_clk_10,
    input i_rst,
    input i_pps_raw,
    // SPI
    input i_MOSI,
    input i_SCLK,
    input i_SSEL,
    output o_MISO,
    // UART
    input i_rx,
    output o_tx,
    // Channel OUTPUTS
    output o_ch_0,
    output o_ch_1,
    output o_ch_2,
    output o_ch_3,
    // LED
    output o_led
);

////////////////////////////////////////////////////////////////////////////
/// POWER ON RESET
////////////////////////////////////////////////////////////////////////////
    wire    w_por;

    power_on_reset por(
        .i_clk  (i_clk_10),
        .o_por  (w_por)
    );

////////////////////////////////////////////////////////////////////////////
/// RESET BLOCK
////////////////////////////////////////////////////////////////////////////
    wire w_rst;
    
    reset_block reset(
        .i_clk      (i_clk_10),
        .i_rst_man  (i_rst),
        .i_rst_por  (w_por),
        .i_rst_sw   (1'b0),
        .o_rst      (w_rst)
    );

////////////////////////////////////////////////////////////////////////////
/// SPI
////////////////////////////////////////////////////////////////////////////
    wire [`DATA_WIDTH-1:0] w_data_read;
    wire [`DATA_WIDTH-1:0] w_data_write;
    wire [`ADDR_WIDTH-1:0] w_addr;
    wire w_wr;
        
    spi_block spi (  
        .i_clk            (i_clk_10),
        .i_rst            (w_rst),
        //SPI connections
        .i_MOSI           (i_MOSI),
        .i_SCLK           (i_SCLK),
        .i_SSEL           (i_SSEL),
        .o_MISO           (o_MISO),
        // BUS connections
        .i_data_read_bus  (w_data_read),
        .o_addr_bus       (w_addr),
        .o_data_write_bus (w_data_write),
        .o_wr_enable_bus  (w_wr)
    );

////////////////////////////////////////////////////////////////////////////
/// THUNDERBOLT COMPONENT
////////////////////////////////////////////////////////////////////////////
    wire [`DATA_WIDTH-1:0]	w_thunder_data_read;
	wire w_thunder_packet_dv;
    wire [`DATA_WIDTH-1:0]	w_thunder_year_h;
	wire [`DATA_WIDTH-1:0]	w_thunder_year_l;
	wire [`DATA_WIDTH-1:0]	w_thunder_month;
	wire [`DATA_WIDTH-1:0]	w_thunder_day;
	wire [`DATA_WIDTH-1:0]	w_thunder_hour;
	wire [`DATA_WIDTH-1:0]	w_thunder_minutes;
    wire [`DATA_WIDTH-1:0]	w_thunder_seconds;

	thunderbolt_block thunderbolt(
        .i_clk                  (i_clk_10),
        .i_rst	                (w_rst),
        .i_pps_raw              (i_pps_raw),
        .i_wr                   (w_wr),
        .i_addr                 (w_addr),
        .i_data                 (w_data_write),
        .o_data                 (w_thunder_data_read),
        .i_rx_thunder	        (i_rx),
        .o_tx_thunder		    (o_tx),
        .o_thunder_packet_dv    (w_thunder_packet_dv),
        .o_thunder_year_h	    (w_thunder_year_h),
        .o_thunder_year_l	    (w_thunder_year_l),
        .o_thunder_month	    (w_thunder_month),
        .o_thunder_day		    (w_thunder_day),
        .o_thunder_hour		    (w_thunder_hour),
        .o_thunder_minutes		(w_thunder_minutes),
        .o_thunder_seconds		(w_thunder_seconds)
    );
////////////////////////////////////////////////////////////////////////////
/// PPPS_DIVIDER_0
////////////////////////////////////////////////////////////////////////////
    wire [`DATA_WIDTH-1:0] w_pps_0_data_read;
    wire w_pps_divided_0;
            
    pps_div_block #(
        .PER_TRUE_ADDR (`PPS_DIV_0_PER_TRUE),
        .DIV_NUM_ADDR  (`PPS_DIV_0_DIV_NUM),
        .PHASE_0_ADDR  (`PPS_DIV_0_PHASE_0),
        .PHASE_1_ADDR  (`PPS_DIV_0_PHASE_1),
        .PHASE_2_ADDR  (`PPS_DIV_0_PHASE_2),
        .WIDTH_ADDR    (`PPS_DIV_0_WIDTH),
        .START_ADDR    (`PPS_DIV_0_START),
        .STOP_ADDR     (`PPS_DIV_0_STOP))
    pps_div_0 ( 
        .i_clk_10      (i_clk_10),
        .i_rst         (w_rst),
        .i_addr        (w_addr),
        .i_data        (w_data_write),
        .i_wr          (w_wr),
        .i_pps_raw     (i_pps_raw),
        .o_data        (w_pps_0_data_read),
        .o_pps_divided (w_pps_divided_0) 
    );

////////////////////////////////////////////////////////////////////////////
/// PPPS_DIVIDER_1
////////////////////////////////////////////////////////////////////////////    
    wire [`DATA_WIDTH-1:0] w_pps_1_data_read;
    wire w_pps_divided_1;                  
    
    pps_div_block #(
        .PER_TRUE_ADDR (`PPS_DIV_1_PER_TRUE),
        .DIV_NUM_ADDR  (`PPS_DIV_1_DIV_NUM),
        .PHASE_0_ADDR  (`PPS_DIV_1_PHASE_0),
        .PHASE_1_ADDR  (`PPS_DIV_1_PHASE_1),
        .PHASE_2_ADDR  (`PPS_DIV_1_PHASE_2),
        .WIDTH_ADDR    (`PPS_DIV_1_WIDTH),
        .START_ADDR    (`PPS_DIV_1_START),
        .STOP_ADDR     (`PPS_DIV_1_STOP))
    pps_div_1 ( 
        .i_clk_10      (i_clk_10),
        .i_rst         (w_rst),
        .i_addr        (w_addr),
        .i_data        (w_data_write),
        .i_wr          (w_wr),
        .i_pps_raw     (i_pps_raw),
        .o_data        (w_pps_1_data_read),
        .o_pps_divided (w_pps_divided_1) 
    );

////////////////////////////////////////////////////////////////////////////
/// PPPS_DIVIDER_2
////////////////////////////////////////////////////////////////////////////    
    wire [`DATA_WIDTH-1:0] w_pps_2_data_read;
    wire w_pps_divided_2;                  
    
    pps_div_block #(
        .PER_TRUE_ADDR (`PPS_DIV_2_PER_TRUE),
        .DIV_NUM_ADDR  (`PPS_DIV_2_DIV_NUM),
        .PHASE_0_ADDR  (`PPS_DIV_2_PHASE_0),
        .PHASE_1_ADDR  (`PPS_DIV_2_PHASE_1),
        .PHASE_2_ADDR  (`PPS_DIV_2_PHASE_2),
        .WIDTH_ADDR    (`PPS_DIV_2_WIDTH),
        .START_ADDR    (`PPS_DIV_2_START),
        .STOP_ADDR     (`PPS_DIV_2_STOP))
    pps_div_2 ( 
        .i_clk_10      (i_clk_10),
        .i_rst         (w_rst),
        .i_addr        (w_addr),
        .i_data        (w_data_write),
        .i_wr          (w_wr),
        .i_pps_raw     (i_pps_raw),
        .o_data        (w_pps_2_data_read),
        .o_pps_divided (w_pps_divided_2) 
    );  

////////////////////////////////////////////////////////////////////////////
/// PPPS_DIVIDER_3
////////////////////////////////////////////////////////////////////////////    
    wire [`DATA_WIDTH-1:0] w_pps_3_data_read;
    wire w_pps_divided_3;
                                      
    pps_div_block #(
        .PER_TRUE_ADDR (`PPS_DIV_3_PER_TRUE),
        .DIV_NUM_ADDR  (`PPS_DIV_3_DIV_NUM),
        .PHASE_0_ADDR  (`PPS_DIV_3_PHASE_0),
        .PHASE_1_ADDR  (`PPS_DIV_3_PHASE_1),
        .PHASE_2_ADDR  (`PPS_DIV_3_PHASE_2),
        .WIDTH_ADDR    (`PPS_DIV_3_WIDTH),
        .START_ADDR    (`PPS_DIV_3_START),
        .STOP_ADDR     (`PPS_DIV_3_STOP))
    pps_div_3 ( 
        .i_clk_10      (i_clk_10),
        .i_rst         (w_rst),
        .i_addr        (w_addr),
        .i_data        (w_data_write),
        .i_wr          (w_wr),
        .i_pps_raw     (i_pps_raw),
        .o_data        (w_pps_3_data_read),
        .o_pps_divided (w_pps_divided_3) 
    );

////////////////////////////////////////////////////////////////////////////
/// MAIN_MEMORY
////////////////////////////////////////////////////////////////////////////                      
    wire [`DATA_WIDTH-1:0] w_main_memory_data;  
    wire [3:0] w_ch_ena;
    wire [3:0] w_ch_sel;            
                   
    main_memory MM (
         .i_clk         (i_clk_10),
         .i_rst         (w_rst),
         .i_addr        (w_addr),
         .i_data        (w_data_write),
         .o_data        (w_main_memory_data),
         .i_wr          (w_wr),
         .o_ch_ena      (w_ch_ena),
         .o_ch_sel      (w_ch_sel)
    );
 
////////////////////////////////////////////////////////////////////////////
/// PULSE GENERATOR 0
////////////////////////////////////////////////////////////////////////////
	wire [`DATA_WIDTH-1:0] w_pg_0_data_read;
    wire w_pulse_out_0;

    pulse_generator_block #(
        .PULSE_ENA          (`PG0_PULSE_ENA),
        .USR_YEAR_H         (`PG0_USR_YEAR_H),
        .USR_YEAR_L         (`PG0_USR_YEAR_L),
        .USR_MONTH          (`PG0_USR_MONTH),
        .USR_DAY            (`PG0_USR_DAY),
        .USR_HOUR           (`PG0_USR_HOUR),
        .USR_MINUTES        (`PG0_USR_MINUTES),
        .USR_SECONDS        (`PG0_USR_SECONDS),
        .WIDTH_HIGH_2       (`PG0_WIDTH_HIGH_2),
        .WIDTH_HIGH_1       (`PG0_WIDTH_HIGH_1),
        .WIDTH_HIGH_0       (`PG0_WIDTH_HIGH_0),
        .WIDTH_PERIOD_2     (`PG0_WIDTH_PERIOD_2),
        .WIDTH_PERIOD_1     (`PG0_WIDTH_PERIOD_1),
        .WIDTH_PERIOD_0     (`PG0_WIDTH_PERIOD_0))
    pulse_gen_0(
        .i_clk                  (i_clk_10),
        .i_rst                  (w_rst),
        .i_wr                   (w_wr),
        .i_addr                 (w_addr),
        .i_data                 (w_data_write),
        .o_data                 (w_pg_0_data_read),
        .i_pps_raw              (i_pps_raw),
        .i_thunder_packet_dv    (w_thunder_packet_dv),
        .i_thunder_year		    ({w_thunder_year_h, w_thunder_year_l}),
        .i_thunder_month        (w_thunder_month),
        .i_thunder_day		    (w_thunder_day),
        .i_thunder_hour		    (w_thunder_hour),
        .i_thunder_minutes	    (w_thunder_minutes),
        .i_thunder_seconds	    (w_thunder_seconds),
        .o_pulse_out            (w_pulse_out_0)
    );

////////////////////////////////////////////////////////////////////////////
/// PULSE GENERATOR 1
////////////////////////////////////////////////////////////////////////////
	wire [`DATA_WIDTH-1:0]w_pg_1_data_read;
    wire w_pulse_out_1;

    pulse_generator_block #(
        .PULSE_ENA          (`PG1_PULSE_ENA),
        .USR_YEAR_H         (`PG1_USR_YEAR_H),
        .USR_YEAR_L         (`PG1_USR_YEAR_L),
        .USR_MONTH          (`PG1_USR_MONTH),
        .USR_DAY            (`PG1_USR_DAY),
        .USR_HOUR           (`PG1_USR_HOUR),
        .USR_MINUTES        (`PG1_USR_MINUTES),
        .USR_SECONDS        (`PG1_USR_SECONDS),
        .WIDTH_HIGH_2       (`PG1_WIDTH_HIGH_2),
        .WIDTH_HIGH_1       (`PG1_WIDTH_HIGH_1),
        .WIDTH_HIGH_0       (`PG1_WIDTH_HIGH_0),
        .WIDTH_PERIOD_2     (`PG1_WIDTH_PERIOD_2),
        .WIDTH_PERIOD_1     (`PG1_WIDTH_PERIOD_1),
        .WIDTH_PERIOD_0     (`PG1_WIDTH_PERIOD_0))
    pulse_gen_1(
        .i_clk                  (i_clk_10),
        .i_rst                  (w_rst),
        .i_wr                   (w_wr),
        .i_addr                 (w_addr),
        .i_data                 (w_data_write),
        .o_data                 (w_pg_1_data_read),
        .i_pps_raw              (i_pps_raw),
        .i_thunder_packet_dv    (w_thunder_packet_dv),
        .i_thunder_year		    ({w_thunder_year_h, w_thunder_year_l}),
        .i_thunder_month        (w_thunder_month),
        .i_thunder_day		    (w_thunder_day),
        .i_thunder_hour		    (w_thunder_hour),
        .i_thunder_minutes	    (w_thunder_minutes),
        .i_thunder_seconds	    (w_thunder_seconds),
        .o_pulse_out            (w_pulse_out_1)
    );

////////////////////////////////////////////////////////////////////////////
/// PULSE GENERATOR 2/
////////////////////////////////////////////////////////////////////////////
	wire [`DATA_WIDTH-1:0]w_pg_2_data_read;
    wire w_pulse_out_2;

    pulse_generator_block #(
        .PULSE_ENA          (`PG2_PULSE_ENA),
        .USR_YEAR_H         (`PG2_USR_YEAR_H),
        .USR_YEAR_L         (`PG2_USR_YEAR_L),
        .USR_MONTH          (`PG2_USR_MONTH),
        .USR_DAY            (`PG2_USR_DAY),
        .USR_HOUR           (`PG2_USR_HOUR),
        .USR_MINUTES        (`PG2_USR_MINUTES),
        .USR_SECONDS        (`PG2_USR_SECONDS),
        .WIDTH_HIGH_2       (`PG2_WIDTH_HIGH_2),
        .WIDTH_HIGH_1       (`PG2_WIDTH_HIGH_1),
        .WIDTH_HIGH_0       (`PG2_WIDTH_HIGH_0),
        .WIDTH_PERIOD_2     (`PG2_WIDTH_PERIOD_2),
        .WIDTH_PERIOD_1     (`PG2_WIDTH_PERIOD_1),
        .WIDTH_PERIOD_0     (`PG2_WIDTH_PERIOD_0))
    pulse_gen_2(
        .i_clk                  (i_clk_10),
        .i_rst                  (w_rst),
        .i_wr                   (w_wr),
        .i_addr                 (w_addr),
        .i_data                 (w_data_write),
        .o_data                 (w_pg_2_data_read),
        .i_pps_raw              (i_pps_raw),
        .i_thunder_packet_dv    (w_thunder_packet_dv),
        .i_thunder_year		    ({w_thunder_year_h, w_thunder_year_l}),
        .i_thunder_month        (w_thunder_month),
        .i_thunder_day		    (w_thunder_day),
        .i_thunder_hour		    (w_thunder_hour),
        .i_thunder_minutes	    (w_thunder_minutes),
        .i_thunder_seconds	    (w_thunder_seconds),
        .o_pulse_out            (w_pulse_out_2)
    );

////////////////////////////////////////////////////////////////////////////
/// PULSE GENERATOR 3
////////////////////////////////////////////////////////////////////////////
	wire [`DATA_WIDTH-1:0] w_pg_3_data_read;
    wire w_pulse_out_3;

    pulse_generator_block #(
        .PULSE_ENA          (`PG3_PULSE_ENA),
        .USR_YEAR_H         (`PG3_USR_YEAR_H),
        .USR_YEAR_L         (`PG3_USR_YEAR_L),
        .USR_MONTH          (`PG3_USR_MONTH),
        .USR_DAY            (`PG3_USR_DAY),
        .USR_HOUR           (`PG3_USR_HOUR),
        .USR_MINUTES        (`PG3_USR_MINUTES),
        .USR_SECONDS        (`PG3_USR_SECONDS),
        .WIDTH_HIGH_2       (`PG3_WIDTH_HIGH_2),
        .WIDTH_HIGH_1       (`PG3_WIDTH_HIGH_1),
        .WIDTH_HIGH_0       (`PG3_WIDTH_HIGH_0),
        .WIDTH_PERIOD_2     (`PG3_WIDTH_PERIOD_2),
        .WIDTH_PERIOD_1     (`PG3_WIDTH_PERIOD_1),
        .WIDTH_PERIOD_0     (`PG3_WIDTH_PERIOD_0))
    pulse_gen_3(
        .i_clk                  (i_clk_10),
        .i_rst                  (w_rst),
        .i_wr                   (w_wr),
        .i_addr                 (w_addr),
        .i_data                 (w_data_write),
        .o_data                 (w_pg_3_data_read),
        .i_pps_raw              (i_pps_raw),
        .i_thunder_packet_dv    (w_thunder_packet_dv),
        .i_thunder_year		    ({w_thunder_year_h, w_thunder_year_l}),
        .i_thunder_month        (w_thunder_month),
        .i_thunder_day		    (w_thunder_day),
        .i_thunder_hour		    (w_thunder_hour),
        .i_thunder_minutes	    (w_thunder_minutes),
        .i_thunder_seconds	    (w_thunder_seconds),
        .o_pulse_out            (w_pulse_out_3)
    );
////////////////////////////////////////////////////////////////////////////
/// MULTIPLEXER_DATA_READ
////////////////////////////////////////////////////////////////////////////

    mux_data_read mux_data(
        .i_clk               (i_clk_10),
        .i_rst               (w_rst),
        .i_pps_div_data_0    (w_pps_0_data_read),
        .i_pps_div_data_1    (w_pps_1_data_read),
        .i_pps_div_data_2    (w_pps_2_data_read),
        .i_pps_div_data_3    (w_pps_3_data_read),
        .i_thunder_data      (w_thunder_data_read),
        .i_pulse_gen_data_0  (w_pg_0_data_read),
        .i_pulse_gen_data_1  (w_pg_1_data_read),
        .i_pulse_gen_data_2  (w_pg_2_data_read),
        .i_pulse_gen_data_3  (w_pg_3_data_read),
        .i_main_memory_data  (w_main_memory_data),
        .o_data              (w_data_read)
    );
////////////////////////////////////////////////////////////////////////////
/// CHANNEL_0_MULTIPLEXER
////////////////////////////////////////////////////////////////////////////
    channel_mux mux_0(
        .i_clk               (i_clk_10),
        .i_rst               (w_rst),
        .i_pps_divided       (w_pps_divided_0),
        .i_pulse_generated   (w_pulse_out_0),
        .i_enable            (w_ch_ena[0]),
        .i_selector          (w_ch_sel[0]),
        .o_channel           (o_ch_0)
    );
////////////////////////////////////////////////////////////////////////////
/// CHANNEL_1_MULTIPLEXER
////////////////////////////////////////////////////////////////////////////
    channel_mux mux_1(
        .i_clk               (i_clk_10),
        .i_rst               (w_rst),
        .i_pps_divided       (w_pps_divided_1),
        .i_pulse_generated   (w_pulse_out_1),
        .i_enable            (w_ch_ena[1]),
        .i_selector          (w_ch_sel[1]),
        .o_channel           (o_ch_1)
    );
////////////////////////////////////////////////////////////////////////////
/// CHANNEL_2_MULTIPLEXER
////////////////////////////////////////////////////////////////////////////                    
    channel_mux mux_2(
        .i_clk               (i_clk_10),
        .i_rst               (w_rst),
        .i_pps_divided       (w_pps_divided_2),
        .i_pulse_generated   (w_pulse_out_2),
        .i_enable            (w_ch_ena[2]),
        .i_selector          (w_ch_sel[2]),
        .o_channel           (o_ch_2)
    );
////////////////////////////////////////////////////////////////////////////
/// CHANNEL_3_MULTIPLEXER
////////////////////////////////////////////////////////////////////////////
    channel_mux mux_3(
        .i_clk               (i_clk_10),
        .i_rst               (w_rst),
        .i_pps_divided       (w_pps_divided_3),
        .i_pulse_generated   (w_pulse_out_3),
        .i_enable            (w_ch_ena[3]),
        .i_selector          (w_ch_sel[3]),
        .o_channel           (o_ch_3)
    );

////////////////////////////////////////////////////////////////////////////
/// BLINKIN LED
////////////////////////////////////////////////////////////////////////////

/* parpadeoLED blink_led
(   .clock(i_clk_10),
    .reset(w_rst),
    .blink_led(o_led),   // User/boot LED next to power LED
    .salida_prueba()  // extra
);
*/

endmodule
