// timescale 
`timescale 1ns/1ps

// `includes for design modules
`include "top.v"

module tb_top(); 

	//--------------------------------
	// Test clock 
	//--------------------------------
	
	default_clk_gen #(.CLK_PERIOD_NS(1000)) tb_clk (.o_clk(tb_clk_10)); // 10 MHz clock
	
	//--------------------------------
	// DUT instantiation 
	//--------------------------------
	
	// inputs 
	reg rst; 
	wire sclk;
	default_clk_gen #(.CLK_PERIOD_NS(10000)) tb_sclk (.o_clk(sclk)); // 1 MHZ spi clock  
	reg ssel; 
	reg mosi;
	reg usr_rx; 
	reg thunder_rx; 
	wire pps_raw; 
	default_clk_gen #(.CLK_PERIOD_NS(50000000)) tb_pps (.o_clk(pps_raw)); // 1 HZ pps signal (using 5 kHz for testing)
	//outputs 
	wire miso; 
	wire led;
	wire usr_tx; 
	wire thunder_tx;  
	wire pulse_generated; 
	
	top DUT (.i_clk_10(tb_clk_10), 
		     .i_rst(rst), 
			 // SPI
			 .i_sclk(sclk),
			 .i_ssel(ssel), 
			 .i_mosi(mosi), 
			 .o_miso(miso), 
			 // UART
			 .i_usr_rx(usr_rx), 
			 .o_usr_tx(usr_tx),
			 // thunderbolt uart 
			 .i_thunder_rx(thunder_rx), 
			 .o_thunder_tx(thunder_tx),
			 // pps divider 
			 .i_pps_raw(pps_raw), 
			 .o_pps_divided_1(pps_divided),
			 // pulse generator 
			 .o_pulse_generated(pulse_generated)
			);
			
	// for UART packet input from thunderbolt 
	reg [7:0] thunder_seconds;
	reg [7:0] thunder_minutes; 
	reg [7:0] thunder_hour;
	reg [7:0] thunder_day;
	reg [7:0] thunder_month;
	reg [7:0] thunder_year0;
	reg [7:0] thunder_year1;
			
	//--------------------------------
	// waveform file generation 
	//--------------------------------
	initial
	begin
		$dumpfile ("wave_tb_top.vcd");
		$dumpvars;
	end
	
	//--------------------------------
	// Directed stimulus generation
	//--------------------------------
	
	// TODO 32 bit phase stuff is off 
  
	initial begin
		// initialization
		rst <= 1; 
		ssel <= 0;
		#1000000
		rst <= 0; 
		ssel <= 1;
		mosi <= 0;  
		// start of test cases
		
		#10000000 // make sure to wait enough time for the thunderbolt module to send two uart packets 
		
		// configure the regFile with pps settings 
		send_spi_packet(8'd0, 8'd1); // per true 
		send_spi_packet(8'd1, 8'd3); // div num
		send_spi_packet(8'd2, 8'd0); // phase 
		send_spi_packet(8'd3, 8'd0); 
		send_spi_packet(8'd4, 8'd0); 
		send_spi_packet(8'd5, 8'd2); 
		send_spi_packet(8'd6, 8'd4); // width 
		send_spi_packet(8'd7, 8'd1); // start 
		send_spi_packet(8'd8, 8'd1); // stop
		send_spi_packet(8'd8, 8'd0); // stop
		
		// configure the regFile with pulse generation settings 
		send_spi_packet(8'd9, 8'd20); // year 
		send_spi_packet(8'd10, 8'd20); // year lsb
		send_spi_packet(8'd11, 8'd2); // month 
		send_spi_packet(8'd12, 8'd25); // day 
		send_spi_packet(8'd13, 8'd10); // hour 
		send_spi_packet(8'd14, 8'd10); // minutes 
		send_spi_packet(8'd15, 8'd10); // seconds 
		send_spi_packet(8'd16, 8'd0); // width // 16 in dec is 10 in hex be careful 
		send_spi_packet(8'd17, 8'd0); // width 
		send_spi_packet(8'd18, 8'd99); // width 
		send_spi_packet(8'd19, 8'd99); // width lsb
		send_spi_packet(8'd20, 8'd1); // pulse enable
		
		// send a packet from the thunderbolt without matching configuration 
		thunder_seconds <= 8'd0; 
		thunder_minutes <= 8'd0; 
		thunder_hour <= 8'd0; 
		thunder_day <= 8'd0; 
		thunder_month <= 8'd0; 
		thunder_year0 <= 8'd0; 
		thunder_year1 <= 8'd0; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		// send a packet from the thunderbolt without matching configuration 
		thunder_seconds <= 8'd1; 
		thunder_minutes <= 8'd1; 
		thunder_hour <= 8'd1; 
		thunder_day <= 8'd1; 
		thunder_month <= 8'd1; 
		thunder_year0 <= 8'd1; 
		thunder_year1 <= 8'd1; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		// send a packet from the thunderbolt without matching configuration 
		thunder_seconds <= 8'd2; 
		thunder_minutes <= 8'd2; 
		thunder_hour <= 8'd2; 
		thunder_day <= 8'd2; 
		thunder_month <= 8'd2; 
		thunder_year0 <= 8'd2; 
		thunder_year1 <= 8'd2; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		// send a packet from the thunderbolt with matching configuration 
		thunder_seconds <= 8'd10; 
		thunder_minutes <= 8'd10; 
		thunder_hour <= 8'd10; 
		thunder_day <= 8'd25; 
		thunder_month <= 8'd2; 
		thunder_year0 <= 8'd20; 
		thunder_year1 <= 8'd20; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw); 
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		// send a packet from the thunderbolt without matching configuration 
		thunder_seconds <= 8'd3; 
		thunder_minutes <= 8'd3; 
		thunder_hour <= 8'd3; 
		thunder_day <= 8'd3; 
		thunder_month <= 8'd3; 
		thunder_year0 <= 8'd3; 
		thunder_year1 <= 8'd3; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		#3000000
		// backchannel uart 
		send_uart_byte(8'hAB); // report the regfile data 
		#3000000
		#3000000
		send_uart_byte(8'hAC); // report the thunderbolt data 
		#30000000
		send_uart_byte(8'hEE); // report ee 
		#30000000
		
		// configure the regFile with pps settings 
		send_spi_packet(8'd0, 8'd1); // per true 
		send_spi_packet(8'd1, 8'd1); // div num
		send_spi_packet(8'd2, 8'd0); // phase 
		send_spi_packet(8'd3, 8'd0); 
		send_spi_packet(8'd4, 8'd0); 
		send_spi_packet(8'd5, 8'd200); 
		send_spi_packet(8'd6, 8'd250); // width 
		send_spi_packet(8'd7, 8'd1); // start 
		send_spi_packet(8'd8, 8'd1); // stop
		send_spi_packet(8'd8, 8'd0); // stop
		#100000
		
		#300000000
		// exit simulation
		$finish;  
	end
	
	// task to send a byte over SPI
	task send_spi_byte; 
		input [7:0] spi_byte; 
		begin 
			// 1. The master pulls SSEL down to indicate to the slave that communication is starting (SSEL is active low)
			@(negedge sclk);
			ssel <= 0;
			// 2. The master toggles the clock eight times and sends 8 data bits on the mosi line
			mosi <= spi_byte[7];
			@(negedge sclk);
			mosi <= spi_byte[6]; 
			@(negedge sclk);
			mosi <= spi_byte[5]; 
			@(negedge sclk);
			mosi <= spi_byte[4]; 
			@(negedge sclk);
			mosi <= spi_byte[3]; 
			@(negedge sclk);
			mosi <= spi_byte[2]; 
			@(negedge sclk);
			mosi <= spi_byte[1]; 
			@(negedge sclk);
			mosi <= spi_byte[0];
			// 3. The master pulls SSEL up to indicate that the transfer is over
			@(negedge sclk);
			ssel <= 1;
		end 
	endtask
	
	task send_spi_packet; 
		input [7:0] addr; 
		input [7:0] data; 
		begin
			send_spi_byte(8'hF0); // start byte 
			send_spi_byte(addr); // address byte
			send_spi_byte(data); // data byte 
		end
	endtask 
	
    //parameter c_CLOCK_PERIOD_NS = 100; 1000
    //parameter c_CLKS_PER_BIT    = 1042; 87
    //parameter c_BIT_PERIOD      = 104200;  
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ---REMEMBER TO REMOVE FOR HARDWARE IN THUNDERBOLT MODULE ------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// this is just to make the uart faster for simulation purposes 
    parameter c_CLOCK_PERIOD_NS = 100;
    parameter c_CLKS_PER_BIT    = 1042;
    parameter c_BIT_PERIOD      = 104200; 
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	task send_uart_byte; 
		input [7:0] uart_byte; 
		integer j; 
		begin
	        // Send Start Bit
	        usr_rx <= 1'b0;
	        #(c_BIT_PERIOD);
			#1000
	        // Send Data Byte
	        for (j=0; j<8; j=j+1) begin
				usr_rx <= uart_byte[j]; 
				#(c_BIT_PERIOD);
			end
		    // Send Stop Bit
		    usr_rx <= 1'b1;
		    #(c_BIT_PERIOD);
		end
	endtask
	
	task send_thunder_byte; 
		input [7:0] thunder_byte; 
		integer j; 
		begin
	        // Send Start Bit
	        thunder_rx <= 1'b0;
	        #(c_BIT_PERIOD);
			#1000
	        // Send Data Byte
	        for (j=0; j<8; j=j+1) begin
				thunder_rx <= thunder_byte[j]; 
				#(c_BIT_PERIOD);
			end
		    // Send Stop Bit
		    thunder_rx <= 1'b1;
		    #(c_BIT_PERIOD);
		end
	endtask
	
	parameter c_TIM_ID = 8'h8F; 
	parameter c_TIM_SUBCODE = 8'hAB;
	task send_thunder_packet;
		input [7:0] thunder_seconds;
		input [7:0] thunder_minutes; 
		input [7:0] thunder_hour;
		input [7:0] thunder_day;
		input [7:0] thunder_month;
		input [7:0] thunder_year0;
		input [7:0] thunder_year1;
		begin
			send_thunder_byte(c_TIM_ID); 
			send_thunder_byte(c_TIM_SUBCODE);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(8'h00);
			send_thunder_byte(thunder_seconds); // seconds 
			send_thunder_byte(thunder_minutes); // minutes 
			send_thunder_byte(thunder_hour); // hours 
			send_thunder_byte(thunder_day); // day
			send_thunder_byte(thunder_month); // month 
			send_thunder_byte(thunder_year0); // year 
			send_thunder_byte(thunder_year1); // year 
		end
	endtask
	
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
			
	
	
	