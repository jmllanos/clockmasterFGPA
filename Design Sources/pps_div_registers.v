`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
//| 0x08  | stop 	 |
//|-------|----------|
//

module pps_div_registers #(parameter base_addr=8'h10,
                           parameter final_addr=8'h19)

                        ( input i_clk_10,
                          input i_rst,
                          input[7:0] i_addr,
                          input[7:0] i_data,
                          input i_wr,
                          output reg [7:0] o_data,
                          output reg [7:0] o_periodic_true, // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
                          output reg [7:0] o_div_number, // The integer value you want to the divide the PPS signal 
                          output reg [31:0] o_phase_us, // The delay or phase offset of the divider generated signal in microseconds 
                          output reg [7:0] o_width_us, // The time width of the divider signal
                          output reg [7:0] o_start, 
                          output reg [7:0] o_stop
    );
    
    reg [7:0] phase_us_0;
    reg [7:0] phase_us_1;
    reg [7:0] phase_us_2;
    reg [7:0] phase_us_3;
    
   always @(posedge i_clk_10)
    begin
        if((i_addr<final_addr) && (i_addr>base_addr))begin
         //writing process
         if(i_wr==1)begin
           case (i_addr)
                base_addr:  o_periodic_true=i_data;
                base_addr+1:o_div_number=i_data;
                base_addr+2:phase_us_0=i_data;
                base_addr+3:phase_us_1=i_data;
                base_addr+4:phase_us_2=i_data;
                base_addr+5:phase_us_3=i_data;
                base_addr+6:o_width_us=i_data;
                base_addr+7:o_start=i_data;
                base_addr+8:o_stop=i_data;
           endcase
          end
          else begin
          // Reading process
            case (i_addr)
                base_addr:  o_data=o_periodic_true;
                base_addr+1:o_data=o_div_number;
                base_addr+2:o_data=phase_us_0;
                base_addr+3:o_data=phase_us_1;
                base_addr+4:o_data=phase_us_2;
                base_addr+5:o_data=phase_us_3;
                base_addr+6:o_data=o_width_us;
                base_addr+7:o_data=o_start;
                base_addr+8:o_data=o_stop;
           endcase
          end
        end
      o_phase_us={phase_us_3,phase_us_2,phase_us_1,phase_us_0};
    end
endmodule
