`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Verilog File Name: mux_data_read
// Project: Clock master
//
// Create by J.Llanos at 08/28/2019
//
// Description: 
//    This module recieves as input all the "outputs data" of the registers 
//    of the modules. 
//    An OR gate it is apply between all the input
//    When a module has an address out of it ranges the output data is a vector
//    of '0'.
//    When the OR gate it is apply only the desire register's data out
//    this module
//
////////////////////////////////////////////////////////////////////////////////////

module mux_data_read(
                    input i_clk,
                    input i_rst,
                    input [7:0]i_pps_div_data_0,
                    input [7:0]i_pps_div_data_1,
                    input [7:0]i_pps_div_data_2,
                    input [7:0]i_pps_div_data_3,
                    input [7:0]i_thunder_data,
                    input [7:0]i_pulse_gen_data_0,
                    input [7:0]i_pulse_gen_data_1,
                    input [7:0]i_pulse_gen_data_2,
                    input [7:0]i_pulse_gen_data_3,
                    
                    input [7:0]i_main_memory_data,
                    output reg [7:0] o_data 
                   );
    
    reg [7:0] w_pps;
    reg [7:0] w_pulse;
    always @(posedge i_clk)
    begin
        if(i_rst==1'b1)begin
           o_data<=8'h0;
        end
        else begin
            w_pps  =i_pps_div_data_0|i_pps_div_data_1|i_pps_div_data_2|i_pps_div_data_3;
            w_pulse=i_pulse_gen_data_0|i_pulse_gen_data_1|i_pulse_gen_data_2|i_pulse_gen_data_3;
            o_data <= w_pps | w_pulse | i_main_memory_data | i_thunder_data; 
             
        end
    end
endmodule
