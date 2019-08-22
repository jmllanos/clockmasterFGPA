/*

file: spi_slave_tv.v
description: test bench for slave module for SPI interface 

*/ 

// timescale 
`timescale 1ns/1ps

// `includes for design modules
`include "spi_slave.v"

// `defines for colored output 
`define display_red $write("%c[0m",27); $write("%c[1;31m",27); $display 
`define end_of_color $write("%c[0m",27); 

module tb_spi_slave();  

	//--------------------------------
	// Test clock 
	//--------------------------------
	
	default_clk_gen #(.CLK_PERIOD_NS(100)) tb_fpgaclk (.o_clk(clk10)); // 10 MHz clock 
	
	//--------------------------------
	// DUT io declarations
	//--------------------------------
	
	// DUT inputs 
	wire SCLK; 
	reg SSEL;
	reg MOSI; 
	reg rst; 

	default_clk_gen #(.CLK_PERIOD_NS(1000)) tb_sclk (.o_clk(SCLK)); // 1 MHZ clock 
	
	// DUT outputs 
	wire MISO;
	wire LED; 
	wire packet_received; 
	wire [39:0] packet_data;

	//--------------------------------
	// DUT instantiation 
	//--------------------------------

	spi_slave dut ( //inputs 
					.i_clk(clk10),
					.i_rst(rst),
			 		.i_SCLK(SCLK), 
					.i_SSEL(SSEL), 
					.i_MOSI(MOSI),
			 		// outputs 
			 		.o_MISO(MISO),
			 		.o_LED(LED),
					.o_packet_received(packet_received), 
					.o_packet_data_received(packet_data)
		    	  );
									 
	//--------------------------------
	// waveform file generation 
	//--------------------------------
	initial
	begin
		$dumpfile ("wave_spi_tb.vcd");
		$dumpvars;
	end
	
	//--------------------------------
	// Directed stimulus generation
	//--------------------------------
  
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
	
	// task to send a byte over SPI
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
	
	//--------------------------------
	// Response displays 
	//--------------------------------
	
	/*
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	initial 
		begin 
			$display("\n\n\n");
			//$display(" ");
			//$display(" ");
	    	$display("SSEL MOSI MISO LED SCLK received     data    | time ");
			$monitor(" %b    %b    %b    %b   %b    %b       %h    | %0d" ,SSEL, MOSI, MISO, LED, SCLK, packet_received, packet_data, $time);
		end
	*/
endmodule



module default_clk_gen #(parameter CLK_PERIOD_NS = 100)
						(output reg o_clk);
		
    initial
    begin
        o_clk = 1'b0;
        forever
        begin
            #(CLK_PERIOD_NS / 2) o_clk = ~o_clk;  
        end
    end

endmodule
