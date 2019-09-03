`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2019 09:55:42 AM
// Design Name: 
// Module Name: tb_mux_data_read
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


module tb_mux_data_read();

reg clk;
reg rst;
reg [7:0]pps_0_data;
reg [7:0]pps_1_data;
reg [7:0]pps_2_data;
reg [7:0]pps_3_data;

reg [7:0]main_memory_data;

wire[7:0]o_data_read;

mux_data_read mux_data(.i_clk(clk),
                    .i_rst(rst),
                    .i_pps_div_data_0(pps_0_data),
                    .i_pps_div_data_1(pps_1_data),
                    .i_pps_div_data_2(pps_2_data),
                    .i_pps_div_data_3(pps_3_data),
                    
                    .i_pulse_gen_data_0(8'd0),
                    .i_pulse_gen_data_1(8'd0),
                    .i_pulse_gen_data_2(8'd0),
                    .i_pulse_gen_data_3(8'd0),
                    .i_main_memory_data(main_memory_data),
                    .o_data(o_data_read)
                    );
                    
always
begin
 clk<=1'b1;
 #10;
 clk<=1'b0;
 #10;
end

initial begin

rst<=1'b1;
main_memory_data<=8'd0;
pps_0_data<=8'd0;
pps_1_data<=8'd0;
pps_2_data<=8'd0;
pps_3_data<=8'd12;

#40

rst<=1'b0;

#100;

pps_0_data<=8'd0;
pps_1_data<=8'd52;
pps_2_data<=8'd0;
pps_3_data<=8'd0;

#100;

pps_0_data<=8'd0;
pps_1_data<=8'd0;
pps_2_data<=8'd21;
pps_3_data<=8'd0;

#100;

pps_0_data<=8'd0;
pps_1_data<=8'd0;
pps_2_data<=8'd0;
pps_3_data<=8'd31;
#100;

pps_0_data<=8'd0;
pps_1_data<=8'd0;
pps_2_data<=8'd0;
pps_3_data<=8'd0;
main_memory_data<=8'd10;
#100;
$finish;
end
endmodule
