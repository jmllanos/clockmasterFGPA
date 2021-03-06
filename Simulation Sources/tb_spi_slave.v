`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory - IGP
// test_bench: tb_spi
// module to test: spi_slave
// Project: Clock master
//
// Created by J. Llanos at 08/26/2019
// 
// Description: 
//         --Simulate SPI recepction and transmission 
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_spi_slave();

//INPUTS
reg clk10;
reg rst;
reg SCLK;
reg MOSI;
reg [7:0]spi_data_tx;
reg SSEL;

//OUTPUTS
wire MISO;
wire [7:0]spi_data_rx;
wire spi_ready;
wire spi_busy;

spi_slave dut ( 
                 .i_clk(clk10), // fpga clock (for over-sampling the SPI bus)
				 .i_rst(rst), // reset
				 // SPI connections
				 .i_SCLK(SCLK), // slave clock from master
				 .i_SSEL(SSEL), // slave select
				 .i_MOSI(MOSI), // master out slave in
				 .o_MISO(MISO), // master in slave out
				 // SPI data rx/tx
				 .i_spi_data_tx(spi_data_tx),
				 .o_spi_data_rx(spi_data_rx),
				 // SPI signals
				 .o_spi_ready(spi_ready),
				 .o_spi_busy(spi_busy)
		    	  );


// CLK PROCESS
always 
begin
    clk10 = 1'b1; 
    #5; // high for 20 * timescale = 20 ns

    clk10 = 1'b0;
    #5; // low for 20 * timescale = 20 ns
end

// SCLK PROCESS
always
begin
   SCLK<=1'b1;
   #100;
   SCLK<=1'b0;
   #100; 
end


initial begin
		// initialization
		rst <= 0; 
		SSEL <= 0;
		#10000
		rst <= 1; 
		SSEL <= 1;
		MOSI <= 0;
		spi_data_tx<=8'hAA;
		 
		#10000
		// start transmission to DUT
		send_byte(8'hFF); // - random byte 
		send_byte(8'h12); // - random byte 
		send_byte(8'h5A); // - random byte 
		send_byte(8'h11); // - start byte 
		send_byte(8'h12); // - packet byte 1
		send_byte(8'hF1); // - packet byte 2
		send_byte(8'h00); // - packet byte 3
		send_byte(8'hF4); // - packet byte 4
		send_byte(8'hF3); // - packet byte 5 
		send_byte(8'hFF); // - random byte 
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

