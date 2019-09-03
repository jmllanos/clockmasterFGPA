`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory - IGP
// test_bench: tb_spi_block
// Module to test: spi_block
// Project: Clock master
//
// Created by J. Llanos at 08/26/2019
// 
// Description: 
//      --Send SPI frames in the format of write and read registers
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_spi_block();

//INPUTS
reg clk10;
reg rst;
reg SCLK;
reg MOSI;
reg SSEL;
reg [7:0]data_read_bus;

//OUTPUS
wire MISO;
wire [7:0]addr_bus;
wire wr_enable_bus;
wire [7:0]data_write_bus;

     spi_block DUT (  
                    .i_clk(clk10),
                    .i_rst(rst),
                    //SPI connections
                    .i_MOSI(MOSI),
                    .i_SCLK(SCLK),
                    .i_SSEL(SSEL),
                    .o_MISO(MISO),
                    // BUS connections
                    .i_data_read_bus(data_read_bus),
                    .o_addr_bus(addr_bus),
                    .o_data_write_bus(data_write_bus),
                    .o_wr_enable_bus(wr_enable_bus)
                    );

//CLK PROCESS                    
  always 
begin
    clk10 = 1'b1; 
    #5; // high for 20 * timescale = 20 ns
    clk10 = 1'b0;
    #5; // low for 20 * timescale = 20 ns
end

//SCLK PROCESS
always
begin
   SCLK<=1'b1;
   #100;
   SCLK<=1'b0;
   #100; 
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
		send_byte(8'hC2); // - write add 42
		@(negedge clk10);
		data_read_bus<=8'h15; // - Data to read in bus
		send_byte(8'h02); // - data 02 
		send_byte(8'h0A); // - read add 0a 
		send_byte(8'hF1); // - data F1 
		send_byte(8'h02); // - read add 02
		send_byte(8'h01); // - data 01
		send_byte(8'hF0); // - Write add 70
		send_byte(8'h04); // - data 04
		send_byte(8'hF3); // - write add 73
		send_byte(8'hFF); // - data FF
		#10000
		// exit simulation
		$finish;  
	end



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
