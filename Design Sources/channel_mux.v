`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Verilog File Name: channel_mux
// Project: Clock master
//
// Create by J.Llanos at 08/28/2019
//
// Description:
//   Channel Output, this multiplexor choose between
//   the Frequency divider or the pulse generator.
//
////////////////////////////////////////////////////////////////////////////////////


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
        if(i_enable==1'b1)begin
            case (i_selector)
                    1'b0: o_channel<=i_pps_divided;
                    1'b1: o_channel<=i_pulse_generated;
            endcase
         end
         else begin
            o_channel<=1'b0;
         end 
    end
   end 
endmodule
