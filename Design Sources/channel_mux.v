`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2019 01:34:30 PM
// Design Name: 
// Module Name: channel_mux
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


module channel_mux(
                    input i_clk,
                    input i_rst,
                    input i_pps_divided,
                    input i_pulse_generated,
                    input i_enable,
                    input i_selector,
                    output reg o_channel
                    );
   always@(posedge i_clk)
   begin
   if(i_rst==1'b1)begin
      o_channel<=1'b0;  
   end
   else begin
        if(i_enable==1)begin
            case (i_selector)
                    1'b0: o_channel<=i_pps_divided;
                    1'b1: o_channel<=i_pulse_generated;
            endcase
         end 
    end
   end 
endmodule
