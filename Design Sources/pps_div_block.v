`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Verilog Header Name: pps_div_block
// Project: Clock master
//
// Create by J.Llanos at 08/28/2019
//
// Description:
//    This block has inside the connection of the pps divider registers 
//    and pps divider. This allow use modularity for each channel
//
//////////////////////////////////////////////////////////////////////////////////


`include "address_map.vh"

module pps_div_block #(parameter PER_TRUE_ADDR =`PPS_DIV_0_PER_TRUE,
                       parameter DIV_NUM_ADDR  =`PPS_DIV_0_DIV_NUM,
                       parameter PHASE_0_ADDR  =`PPS_DIV_0_PHASE_0,
                       parameter PHASE_1_ADDR  =`PPS_DIV_0_PHASE_1,
                       parameter PHASE_2_ADDR  =`PPS_DIV_0_PHASE_2,
                       parameter WIDTH_ADDR    =`PPS_DIV_0_WIDTH,
                       parameter START_ADDR    =`PPS_DIV_0_START,
                       parameter STOP_ADDR     =`PPS_DIV_0_STOP
                       )
                    ( input i_clk_10,
                      input i_rst,
                      input[`ADDR_WIDTH-1:0] i_addr,
                      input[`DATA_WIDTH-1:0] i_data,
                      input i_wr,
                      input i_pps_raw,
                      output [`DATA_WIDTH-1:0] o_data,
                      output o_pps_divided

    );
       
 
  wire [`DATA_WIDTH-1:0] w_periodic_true; // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
  wire [`DATA_WIDTH-1:0] w_div_number; // The integer value you want to the divide the PPS signal 
  wire [`DATA_WIDTH*3-1:0] w_phase_us; // The delay or phase offset of the divider generated signal in microseconds 
  wire [`DATA_WIDTH-1:0] w_width_us; // The time width of the divider signal
  wire [`DATA_WIDTH-1:0] w_start; 
  wire [`DATA_WIDTH-1:0] w_stop;
     
     // Register for PPS DIVIDER configuration
    pps_div_registers #(.PER_TRUE_ADDR(PER_TRUE_ADDR),
                       .DIV_NUM_ADDR(DIV_NUM_ADDR),
                       .PHASE_0_ADDR(PHASE_0_ADDR),
                       .PHASE_1_ADDR(PHASE_1_ADDR),
                       .PHASE_2_ADDR(PHASE_2_ADDR),
                       .WIDTH_ADDR(WIDTH_ADDR),
                       .START_ADDR(START_ADDR),
                       .STOP_ADDR(STOP_ADDR)
                       )
           PPS_DIV_REG  ( .i_clk_10(i_clk_10),
                          .i_rst(i_rst),
                          .i_addr(i_addr),
                          .i_data(i_data),
                          .i_wr(i_wr),
                          .o_data(o_data),
                          .o_periodic_true(w_periodic_true), // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
                          .o_div_number(w_div_number), // The integer value you want to the divide the PPS signal 
                          .o_phase_us(w_phase_us), // The delay or phase offset of the divider generated signal in microseconds 
                          .o_width_us(w_width_us), // The time width of the divider signal
                          .o_start(w_start), 
                          .o_stop(w_stop)
                          );
    
    //Genetarion of PPS_DIVIDED
    pps_divider PPS_DIV (.i_clk_10(i_clk_10), // 10 mhz clock 
			.i_rst(i_rst), 
			.i_pps_raw(i_pps_raw), // pps signal input 
			.i_periodic_true(w_periodic_true), // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
			.i_div_number(w_div_number), // The integer value you want to the divide the PPS signal 
			.i_phase_us(w_phase_us), // The delay or phase offset of the divider generated signal in microseconds 
			.i_width_us(w_width_us), // The time width of the divider signal
			.i_start(w_start), 
			.i_stop(w_stop),
			.o_pps_divided(o_pps_divided)
			);
    
endmodule
