`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2019 04:54:49 PM
// Design Name: 
// Module Name: mux_address
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


module mux_data_read(
                    input i_clk,
                    input i_rst,
                    input [7:0]i_pps_div_data_0,
                    input [7:0]i_pps_div_data_1,
                    input [7:0]i_pps_div_data_2,
                    input [7:0]i_pps_div_data_3,
                    
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
            o_data <= w_pps | w_pulse | i_main_memory_data; 
             
        end
    end
endmodule
