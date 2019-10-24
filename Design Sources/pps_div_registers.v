`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Engineer: J. Llanos
// 
// Create Date: 08/22/2019 02:04:08 PM
// Design Name: 
// Module Name: pps_div_registers
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
//  addr      data
//|------------------|
//| pps divider      |
//|------------------|
//| 0x00  | per true |
//| 0x01  | div num  |
//| 0x02  | phase    |
//| 0x03  | phase    |
//| 0x04  | phase    |
//| 0x05  | phase lsb|
//| 0x06  | width    |
//| 0x07  | start    |
//| 0x08  | stop     |
//|-------|----------|
//

`include "address_map.vh"

module pps_div_registers #(parameter PER_TRUE_ADDR   =`PPS_DIV_0_PER_TRUE,
                           parameter DIV_NUM_ADDR    =`PPS_DIV_0_DIV_NUM,
                           parameter PHASE_0_ADDR    =`PPS_DIV_0_PHASE_0,
                           parameter PHASE_1_ADDR    =`PPS_DIV_0_PHASE_1,
                           parameter PHASE_2_ADDR    =`PPS_DIV_0_PHASE_2,
                           parameter WIDTH_ADDR      =`PPS_DIV_0_WIDTH,
                           parameter START_ADDR      =`PPS_DIV_0_START,
                           parameter STOP_ADDR       =`PPS_DIV_0_STOP
                           )
                        ( input i_clk_10,
                          input i_rst,
                          input[`ADDR_WIDTH-1:0] i_addr,
                          input[`DATA_WIDTH-1:0] i_data,
                          input i_wr,
                          output reg [`DATA_WIDTH-1:0] o_data,
                          output reg [`DATA_WIDTH-1:0] o_periodic_true, // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
                          output reg [`DATA_WIDTH-1:0] o_div_number, // The integer value you want to the divide the PPS signal 
                          output reg [`DATA_WIDTH*3-1:0] o_phase_us, // The delay or phase offset of the divider generated signal in microseconds 
                          output reg [`DATA_WIDTH-1:0] o_width_us, // The time width of the divider signal
                          output reg [`DATA_WIDTH-1:0] o_start, 
                          output reg [`DATA_WIDTH-1:0] o_stop
    );
    
    reg [`DATA_WIDTH-1:0] phase_us_0;
    reg [`DATA_WIDTH-1:0] phase_us_1;
    reg [`DATA_WIDTH-1:0] phase_us_2;

   always @(posedge i_clk_10)
    begin
     if(i_rst==1'b1) begin
       o_periodic_true  <=`DATA_WIDTH'h0;
       o_div_number     <=`DATA_WIDTH'h0;
       phase_us_0       <=`DATA_WIDTH'h0;
       phase_us_1       <=`DATA_WIDTH'h0;
       phase_us_2       <=`DATA_WIDTH'h0;
       o_width_us       <=`DATA_WIDTH'h0;
       o_start          <=`DATA_WIDTH'h0;
       o_stop           <=`DATA_WIDTH'h0;
     end
     else begin
        
         //writing process
         if(i_wr==1)begin
           case (i_addr)
                PER_TRUE_ADDR: o_periodic_true<=i_data;
                DIV_NUM_ADDR : o_div_number   <=i_data;
                PHASE_0_ADDR : phase_us_0     <=i_data;
                PHASE_1_ADDR : phase_us_1     <=i_data;
                PHASE_2_ADDR : phase_us_2     <=i_data;
                WIDTH_ADDR   : o_width_us     <=i_data;
                START_ADDR   : o_start        <=i_data;
                STOP_ADDR    : o_stop         <=i_data;
           endcase
          end
          else begin
          
          // Reading process
            case (i_addr)
                PER_TRUE_ADDR: o_data<=o_periodic_true;
                DIV_NUM_ADDR : o_data<=o_div_number;
                PHASE_0_ADDR : o_data<=phase_us_0;
                PHASE_1_ADDR : o_data<=phase_us_1;
                PHASE_2_ADDR : o_data<=phase_us_2;
                WIDTH_ADDR   : o_data<=o_width_us;
                START_ADDR   : o_data<=o_start;
                STOP_ADDR    : o_data<=o_stop;
                default      : o_data<=8'h0;
           endcase
          end
      o_phase_us={phase_us_2,phase_us_1,phase_us_0};
    end
   end
endmodule

