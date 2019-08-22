`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2019 01:47:38 PM
// Design Name: 
// Module Name: pps_div_block
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module pps_div_block #(parameter base_addr=8'h10,
                       parameter final_addr=8'h19)
                    ( input i_clk_10,
                      input i_rst,
                      input[7:0] i_addr,
                      input[7:0] i_data,
                      input i_wr,
                      input i_pps_raw,
                      output [7:0] o_data,
                      output o_pps_divided

    );
       
 
  wire [7:0] periodic_true; // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
  wire [7:0] div_number; // The integer value you want to the divide the PPS signal 
  wire [31:0] phase_us; // The delay or phase offset of the divider generated signal in microseconds 
  wire [7:0] width_us; // The time width of the divider signal
  wire [7:0] start; 
  wire [7:0] stop;
     
    pps_div_registers#(.base_addr(base_addr),
                       .final_addr(final_addr))
           PPS_DIV_REG  ( .i_clk_10(i_clk_10),
                          .i_rst(i_rst),
                          .i_addr(i_addr),
                          .i_data(i_data),
                          .i_wr(i_wr),
                          .o_data(o_data),
                          .o_periodic_true(periodic_true), // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
                          .o_div_number(div_number), // The integer value you want to the divide the PPS signal 
                          .o_phase_us(phase_us), // The delay or phase offset of the divider generated signal in microseconds 
                          .o_width_us(width_us), // The time width of the divider signal
                          .o_start(start), 
                          .o_stop(stop)
                          );
    
    pps_divider PPS_DIV (.i_clk_10(i_clk_10), // 10 mhz clock 
			.i_rst(i_rst), // reset 
			.i_pps_raw(i_pps_raw), // pps signal input 
			.i_periodic_true(periodic_true), // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
			.i_div_number(div_number), // The integer value you want to the divide the PPS signal 
			.i_phase_us(phase_us), // The delay or phase offset of the divider generated signal in microseconds 
			.i_width_us(width_us), // The time width of the divider signal
			.i_start(start), 
			.i_stop(start),
			.o_pps_divided(o_pps_divided)
			);
    
endmodule
