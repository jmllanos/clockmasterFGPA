`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Verilog file Name: main_memory
// Project: Clock master
//
// Create by J.Llanos at 08/28/2019
//
// Description:
//   The main memory contain the registers that configure the channel outputs.
//    Also this memory has free space for future information like status, etc.
//
//
//////////////////////////////////////////////////////////////////////////////////

`include "address_map.vh"

module main_memory( input i_clk,
                    input i_rst,
                    input[`ADDR_WIDTH-1:0] i_addr,
                    input[`DATA_WIDTH-1:0] i_data,
                    output reg [`DATA_WIDTH-1:0] o_data,
                    input i_wr,
                    
                    output [3:0]o_ch_ena,
                    output [3:0]o_ch_sel
    );

    reg [`DATA_WIDTH-1:0] r_channel_ena;
    reg [`DATA_WIDTH-1:0] r_channel_sel;
    
    always@(posedge i_clk)
    begin
        if(i_rst==1'b1)begin
            r_channel_sel<=0;
            r_channel_ena<=0;
        end
        else begin
            if(i_wr==1)begin
                case(i_addr)
                  
                  `CH_MUX_ENABLE  : r_channel_ena<=i_data;
                  `CH_MUX_SELECTOR: r_channel_sel<=i_data;
                   
                endcase
            end
            else begin
                case(i_addr)
                  `CH_MUX_ENABLE  : o_data<=r_channel_ena;
                  `CH_MUX_SELECTOR: o_data<=r_channel_sel;
                  default         : o_data<=0;
                endcase
            end
        end
    end
    
   
    assign o_ch_ena=r_channel_ena[3:0];
    
    assign o_ch_sel=r_channel_sel[3:0];
    
     
endmodule
