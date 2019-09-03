`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2019 10:29:17 AM
// Design Name: 
// Module Name: tb_top_spi_main_memory
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
`include "address_map.vh"

module tb_top_spi_main_memory( );


reg clk;
reg rst;
reg pps_raw;
reg MOSI;
reg SCLK;
reg SSEL;

wire MISO;
wire [3:0]enable;
wire [3:0]selector;

 top_spi_main_memory DUT(
                            .i_clk_10(clk),
                            .i_rst(rst),
                            
                            .i_MOSI(MOSI),
                            .i_SCLK(SCLK),
                            .i_SSEL(SSEL),
                            .o_MISO(MISO),
                            .o_enable(enable),
                            .o_selector(selector)
                 );
always 
begin
    clk = 1'b1; 
    #50; // high for 20 * timescale = 20 ns
    clk = 1'b0;
    #50; // low for 20 * timescale = 20 ns
end

//SCLK PROCESS
always
begin
   SCLK<=1'b1;
   #150;
   SCLK<=1'b0;
   #150; 
end

always
begin
   pps_raw<=1'b1;
   #150;
   pps_raw<=1'b0;
   #999850; 
end

initial begin
		// initialization
		rst <= 1; 
		SSEL <= 0;
		#10000
		rst <= 0; 
		SSEL <= 1;
		MOSI <= 0;
		 
		#10000
		// start of test cases
		write_data(`CH_MUX_SELECTOR,'h81);
		write_data(`CH_MUX_ENABLE,'h42);
		read_data(`CH_MUX_SELECTOR,'h63);
		read_data(`CH_MUX_ENABLE,'h63);
		
		#1000000
//		write_data(`PPS_DIV_0_STOP,'d1);
//		#100
		// exit simulation
		$finish;  
	end

task write_data;
    input [7:0] address;
    input [7:0] data;
    begin
        send_byte('h80 | address);
        send_byte(data);
    end
endtask

task read_data;
    input [7:0] address;
    input [7:0] data;
    begin
        send_byte(address);
        send_byte(data);
    end
endtask


task send_byte; 
		input [7:0] byte; 
		begin 
			// 1. The master pulls SSEL down to indicate to the slave that communication is starting (SSEL is active low)
			@(negedge SCLK);
			SSEL <= 0;
			// 2. The master toggles the clock eight times and sends 8 data bits on the MOSI line
			MOSI <= byte[7];
			@(negedge SCLK);
			MOSI <= byte[6]; 
			@(negedge SCLK);
			MOSI <= byte[5]; 
			@(negedge SCLK);
			MOSI <= byte[4]; 
			@(negedge SCLK);
			MOSI <= byte[3]; 
			@(negedge SCLK);
			MOSI <= byte[2]; 
			@(negedge SCLK);
			MOSI <= byte[1]; 
			@(negedge SCLK);
			MOSI <= byte[0];
			// 3. The master pulls SSEL up to indicate that the transfer is over
			@(negedge SCLK);
			SSEL <= 1;
		end 
	endtask   
endmodule