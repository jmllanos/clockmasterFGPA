`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2019 05:21:16 PM
// Design Name: 
// Module Name: tb_top
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

`include"address_map.vh"

module tb_top();

wire clk;
reg rst;

//SPI
wire SCLK;
reg SSEL;
reg MOSI;
wire MISO;

//trimble 
reg pps_raw;
reg  thunder_rx;
wire thunder_tx;

//channel_OUTPUTS
wire ch_0;
wire ch_1;
wire ch_2;
wire ch_3;


reg [7:0] thunder_seconds;
reg [7:0] thunder_minutes;
reg [7:0] thunder_hour;
reg [7:0] thunder_day;
reg [7:0] thunder_month;
reg [7:0] thunder_year0;
reg [7:0] thunder_year1;

top DUT( 
        .i_clk_10(clk),
        .i_rst(rst),
        .i_pps_raw(pps_raw),
         // SPI
        .i_MOSI(MOSI),
        .i_SCLK(SCLK),
        .i_SSEL(SSEL),
        .o_MISO(MISO),
        // UART
        .i_rx(thunder_rx),
        .o_tx(thunder_tx),
        // Channel OUTPUTS
        .o_ch_0(ch_0),
        .o_ch_1(ch_1),
        .o_ch_2(ch_2),
        .o_ch_3(ch_3)
);

default_clk_gen #(.CLK_PERIOD_NS(100)) tb_clk (.o_clk(clk)); // 10 MHz clock

default_clk_gen #(.CLK_PERIOD_NS(10000)) tb_sclk (.o_clk(SCLK)); // 1 MHZ

//default_clk_gen #(.CLK_PERIOD_NS(50000000)) tb_pps (.o_clk(pps_raw)); // 1

initial begin
        pps_raw   <= 0;
        #13333;
        forever begin
            pps_raw  <= 1;
            #2000
            pps_raw   <= 0;
            #24998000;
        end
    end

initial begin
		// initialization
		rst <= 1; 
		SSEL <= 0;
		thunder_rx<=1;
		#1000
		rst <= 0; 
		SSEL <= 1;
		MOSI <= 0;
		#1000
		
		
		// start of test cases
		// Configuration_PPS0
		write_data(`PPS_DIV_0_START,   'd1);
		write_data(`PPS_DIV_0_STOP,    'd1);
		write_data(`PPS_DIV_0_PER_TRUE,'h1);
		write_data(`PPS_DIV_0_DIV_NUM, 'h1);
		write_data(`PPS_DIV_0_PHASE_0, 'h0);
		write_data(`PPS_DIV_0_PHASE_1, 'h0);
		write_data(`PPS_DIV_0_PHASE_2, 'h0);
		write_data(`PPS_DIV_0_PHASE_3, 'h0);
		write_data(`PPS_DIV_0_WIDTH,   'd20);
		write_data(`PPS_DIV_0_STOP,    'd0);
		
		// Configuration_PPS1
		write_data(`PPS_DIV_1_START,   'd1);
		write_data(`PPS_DIV_1_STOP,    'd1);
		write_data(`PPS_DIV_1_PER_TRUE,'h1);
		write_data(`PPS_DIV_1_DIV_NUM, 'h2);
		write_data(`PPS_DIV_1_PHASE_0, 'h0);
		write_data(`PPS_DIV_1_PHASE_1, 'h0);
		write_data(`PPS_DIV_1_PHASE_2, 'h0);
		write_data(`PPS_DIV_1_PHASE_3, 'h0);
		write_data(`PPS_DIV_1_WIDTH,   'd40);
		write_data(`PPS_DIV_1_STOP,    'd0);
		
		// Configuration_PPS2
		write_data(`PPS_DIV_2_START,   'd1);
		write_data(`PPS_DIV_2_STOP,    'd1);
		write_data(`PPS_DIV_2_PER_TRUE,'h1);
		write_data(`PPS_DIV_2_DIV_NUM, 'h4);
		write_data(`PPS_DIV_2_PHASE_0, 'h0);
		write_data(`PPS_DIV_2_PHASE_1, 'h0);
		write_data(`PPS_DIV_2_PHASE_2, 'h0);
		write_data(`PPS_DIV_2_PHASE_3, 'h0);
		write_data(`PPS_DIV_2_WIDTH,   'd80);
		write_data(`PPS_DIV_2_STOP,    'd0);
		
		// Configuration_PPS3
	    write_data(`PPS_DIV_3_START,   'd1);
		write_data(`PPS_DIV_3_STOP,    'd1);
		write_data(`PPS_DIV_3_PER_TRUE,'h1);
		write_data(`PPS_DIV_3_DIV_NUM, 'h8);
		write_data(`PPS_DIV_3_PHASE_0, 'h0);
		write_data(`PPS_DIV_3_PHASE_1, 'h0);
		write_data(`PPS_DIV_3_PHASE_2, 'h0);
		write_data(`PPS_DIV_3_PHASE_3, 'h0);
		write_data(`PPS_DIV_3_WIDTH,   'd160);
		write_data(`PPS_DIV_3_STOP,    'd0);
	   
	   //Pulse generator 0 configuration	
		write_data(`PG0_PULSE_ENA,     'h01);
		write_data(`PG0_USR_YEAR_H,    'he4);
		write_data(`PG0_USR_YEAR_L,    'h07);
		write_data(`PG0_USR_MONTH,     'd07);
		write_data(`PG0_USR_DAY,       'd15);
		write_data(`PG0_USR_HOUR,      'd11);
		write_data(`PG0_USR_MINUTES,   'd55);
		write_data(`PG0_USR_SECONDS,   'd29);
		write_data(`PG0_WIDTH_HIGH_3,  'd00);
		write_data(`PG0_WIDTH_HIGH_2,  'd00);
		write_data(`PG0_WIDTH_HIGH_1,  'd00);
		write_data(`PG0_WIDTH_HIGH_0,  'd02);
		write_data(`PG0_WIDTH_PERIOD_3,'d00);
		write_data(`PG0_WIDTH_PERIOD_2,'d00);
		write_data(`PG0_WIDTH_PERIOD_1,'d00);
		write_data(`PG0_WIDTH_PERIOD_0,'d08);
			
		// Channel Mux configuration
		// Enable
		write_data(`CH_MUX_SELECTOR,   'b0001);
		write_data(`CH_MUX_ENABLE,     'b1111);
		// Selector
		
		
		thunder_seconds <= 8'd27; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		thunder_seconds <= 8'd28; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		thunder_seconds <= 8'd29; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		thunder_seconds <= 8'd30; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		thunder_seconds <= 8'd31; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		
		thunder_seconds <= 8'd32; 
		thunder_minutes <= 8'd55; 
		thunder_hour    <= 8'd11; 
		thunder_day     <= 8'd15; 
		thunder_month   <= 8'd07; 
		thunder_year0   <= 8'he4; 
		thunder_year1   <= 8'h07; // 16 in dec is 10 in hex be careful 
		@(negedge pps_raw);
		send_thunder_packet(thunder_seconds, thunder_minutes, thunder_hour, thunder_day, thunder_month, thunder_year0, thunder_year1);
		
		
		
		#1000000
		read_data(`PPS_DIV_3_DIV_NUM, 'h8);
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


	// this is just to make the uart faster for simulation purposes 
    parameter c_CLOCK_PERIOD_NS = 1000;
    parameter c_CLKS_PER_BIT    = 1042;
    parameter c_BIT_PERIOD      = 104200; 

	
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
			send_thunder_byte(8'h10);
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
			send_thunder_byte(8'h10);
			send_thunder_byte(8'h03);
		
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