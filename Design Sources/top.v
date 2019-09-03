/**********************************************************

file: top.v
author: Eloise Perrochet
description:


**********************************************************/
`timescale 1ns / 1ps

// includes for design sub-modules
//`include "components/spi_slave/spi_slave.v"
//`include "components/regfile/regfile.v"
//`include "components/uart/uart_rx.v"
//`include "components/uart/uart_tx.v"
//`include "components/pps_edge_detect/pps_edge_detect.v"
//`include "components/pps_divider/pps_divider.v"
//`include "components/thunderbolt/thunderbolt.v"
//`include "components/pulse_generator/pulse_generator.v"

//includes for design sub-modules

//`include "spi_slave.v"
//`include "regfile.v"
//`include "uart_rx.v"
//`include "uart_tx.v"
//`include "pps_edge_detect.v"
//`include "pps_divider.v"
//`include "thunderbolt.v"
//`include "pulse_generator.v"

//`include "parpadeoLED.v" //prueba de que funciona


//`include "pll16_10.v" //**********************se agrego pll para bajar clock

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
                // Channel OUTPUTS
                output o_ch_0,
                output o_ch_1,
                output o_ch_2,
                output o_ch_3
	);

   wire [7:0] w_data_read;
   wire [7:0] w_data_write;
   wire [7:0] w_addr;
   wire w_wr;
   wire w_pps_divided_0;
   wire w_pps_divided_1;
   wire w_pps_divided_2;
   wire w_pps_divided_3;
   
   wire [7:0] w_pps_0_data_read;
   wire [7:0] w_pps_1_data_read;
   wire [7:0] w_pps_2_data_read;
   wire [7:0] w_pps_3_data_read;
   
   wire [7:0] w_main_memory_data;
    
    spi_block spi (  
            .i_clk(i_clk_10),
            .i_rst(i_rst),
            //SPI connections
            .i_MOSI(i_MOSI),
            .i_SCLK(i_SCLK),
            .i_SSEL(i_SSEL),
            .o_MISO(o_MISO),
            // BUS connections
            .i_data_read_bus(w_data_read),
            .o_addr_bus(w_addr),
            .o_data_write_bus(w_data_write),
            .o_wr_enable_bus(w_wr)
            );
            
     pps_div_block #(.PER_TRUE_ADDR(`PPS_DIV_0_PER_TRUE),
                             .DIV_NUM_ADDR (`PPS_DIV_0_DIV_NUM),
                             .PHASE_0_ADDR (`PPS_DIV_0_PHASE_0),
                             .PHASE_1_ADDR (`PPS_DIV_0_PHASE_1),
                             .PHASE_2_ADDR (`PPS_DIV_0_PHASE_2),
                             .PHASE_3_ADDR (`PPS_DIV_0_PHASE_3),
                             .WIDTH_ADDR   (`PPS_DIV_0_WIDTH),
                             .START_ADDR   (`PPS_DIV_0_START),
                             .STOP_ADDR    (`PPS_DIV_0_STOP)
                       )
                   pps_div_0 ( .i_clk_10(i_clk_10),
                      .i_rst(i_rst),
                      .i_addr(w_addr),
                      .i_data(w_data_write),
                      .i_wr(w_wr),
                      .i_pps_raw(i_pps_raw),
                      .o_data(w_pps_0_data_read),
                      .o_pps_divided(w_pps_divided_0) 
                      );
                      
      pps_div_block #(.PER_TRUE_ADDR(`PPS_DIV_1_PER_TRUE),
                             .DIV_NUM_ADDR (`PPS_DIV_1_DIV_NUM),
                             .PHASE_0_ADDR (`PPS_DIV_1_PHASE_0),
                             .PHASE_1_ADDR (`PPS_DIV_1_PHASE_1),
                             .PHASE_2_ADDR (`PPS_DIV_1_PHASE_2),
                             .PHASE_3_ADDR (`PPS_DIV_1_PHASE_3),
                             .WIDTH_ADDR   (`PPS_DIV_1_WIDTH),
                             .START_ADDR   (`PPS_DIV_1_START),
                             .STOP_ADDR    (`PPS_DIV_1_STOP)
                       )
                   pps_div_1 ( .i_clk_10(i_clk_10),
                      .i_rst(i_rst),
                      .i_addr(w_addr),
                      .i_data(w_data_write),
                      .i_wr(w_wr),
                      .i_pps_raw(i_pps_raw),
                      .o_data(w_pps_1_data_read),
                      .o_pps_divided(w_pps_divided_1) 
                      );
                      
    pps_div_block #(.PER_TRUE_ADDR(`PPS_DIV_1_PER_TRUE),
                             .DIV_NUM_ADDR (`PPS_DIV_2_DIV_NUM),
                             .PHASE_0_ADDR (`PPS_DIV_2_PHASE_0),
                             .PHASE_1_ADDR (`PPS_DIV_2_PHASE_1),
                             .PHASE_2_ADDR (`PPS_DIV_2_PHASE_2),
                             .PHASE_3_ADDR (`PPS_DIV_2_PHASE_3),
                             .WIDTH_ADDR   (`PPS_DIV_2_WIDTH),
                             .START_ADDR   (`PPS_DIV_2_START),
                             .STOP_ADDR    (`PPS_DIV_2_STOP)
                       )
                   pps_div_2 ( .i_clk_10(i_clk_10),
                      .i_rst(i_rst),
                      .i_addr(w_addr),
                      .i_data(w_data_write),
                      .i_wr(w_wr),
                      .i_pps_raw(i_pps_raw),
                      .o_data(w_pps_2_data_read),
                      .o_pps_divided(w_pps_divided_2) 
                      );  
                                        
    pps_div_block #(.PER_TRUE_ADDR(`PPS_DIV_3_PER_TRUE),
         .DIV_NUM_ADDR (`PPS_DIV_3_DIV_NUM),
         .PHASE_0_ADDR (`PPS_DIV_3_PHASE_0),
         .PHASE_1_ADDR (`PPS_DIV_3_PHASE_1),
         .PHASE_2_ADDR (`PPS_DIV_3_PHASE_2),
         .PHASE_3_ADDR (`PPS_DIV_3_PHASE_3),
         .WIDTH_ADDR   (`PPS_DIV_3_WIDTH),
         .START_ADDR   (`PPS_DIV_3_START),
         .STOP_ADDR    (`PPS_DIV_3_STOP)
                       )
                   pps_div_3 ( .i_clk_10(i_clk_10),
                      .i_rst(i_rst),
                      .i_addr(w_addr),
                      .i_data(w_data_write),
                      .i_wr(w_wr),
                      .i_pps_raw(i_pps_raw),
                      .o_data(w_pps_3_data_read),
                      .o_pps_divided(w_pps_divided_3) 
                      );
                      
          wire[3:0] w_ch_ena;
          wire[3:0] w_ch_sel;            
                      
          main_memory MM (.i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_addr(w_addr),
                    .i_data(w_data_write),
                    .o_data(w_main_memory_data),
                    .i_wr(w_wr),
                    .o_ch_ena(w_ch_ena),
                    .o_ch_sel(w_ch_sel)
                    );
 
 mux_data_read mux_data(.i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_pps_div_data_0(w_pps_0_data_read),
                    .i_pps_div_data_1(w_pps_1_data_read),
                    .i_pps_div_data_2(w_pps_2_data_read),
                    .i_pps_div_data_3(w_pps_3_data_read),
                    
                    .i_pulse_gen_data_0(8'd0),
                    .i_pulse_gen_data_1(8'd0),
                    .i_pulse_gen_data_2(8'd0),
                    .i_pulse_gen_data_3(8'd0),
                    .i_main_memory_data(w_main_memory_data),
                    .o_data(w_data_read)
                    );
 
 channel_mux mux_0(
                    .i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_pps_divided(w_pps_divided_0),
                    .i_pulse_generated(1'b1),
                    .i_enable(w_ch_ena[0]),
                    .i_selector(w_ch_sel[0]),
                    .o_channel(o_ch_0)
                    );
 channel_mux mux_1(
                    .i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_pps_divided(w_pps_divided_1),
                    .i_pulse_generated(1'b1),
                    .i_enable(w_ch_ena[1]),
                    .i_selector(w_ch_sel[1]),
                    .o_channel(o_ch_1)
                    );
                    
channel_mux mux_2(
                    .i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_pps_divided(w_pps_divided_2),
                    .i_pulse_generated(1'b1),
                    .i_enable(w_ch_ena[2]),
                    .i_selector(w_ch_sel[2]),
                    .o_channel(o_ch_2)
                    );
 
 channel_mux mux_3(
                    .i_clk(i_clk_10),
                    .i_rst(i_rst),
                    .i_pps_divided(w_pps_divided_3),
                    .i_pulse_generated(1'b1),
                    .i_enable(w_ch_ena[3]),
                    .i_selector(w_ch_sel[3]),
                    .o_channel(o_ch_3)
                    );

endmodule
