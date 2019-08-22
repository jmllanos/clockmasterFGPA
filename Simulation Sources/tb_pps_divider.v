/*********************************************************************
tb_pps_divider 

description: testbench for pps divider
**********************************************************************/

// includes for design modules
//`include "components/pps_edge_detect/pps_edge_detect.v"

module tb_pps_divider(); 

	//--------------------------------
	// Test clock 
	//--------------------------------
	
	wire clk10; 
	default_clk_gen #(.CLK_PERIOD_NS(100)) tb_clk (.o_clk(clk10)); // 10 MHz clock 
	
	//--------------------------------
	// DUT io declarations
	//--------------------------------
	
	// DUT inputs 
	reg rst; 
	reg [7:0] periodic_true; 
	reg [7:0] div_number; 
	reg [31:0] phase_us; 
	reg [7:0] width_us; 
	reg [7:0] start; 
	reg [7:0] stop;  
	wire pps_raw; 
	default_clk_gen #(.CLK_PERIOD_NS(100000)) tb_pps (.o_clk(pps_raw)); // 1 Hz signal 
	
	// DUT outputs
	wire pps_divided; 
	
	// for waveforms 
	reg [31:0] which_test = 32'd0;  
	
	//--------------------------------
	// DUT instantiation 
	//--------------------------------
	
	pps_divider DUT (.i_clk_10(clk10), // 10 mhz clock 
					 .i_rst(rst), // reset 
					 .i_pps_raw(pps_raw), 
				     .i_periodic_true(periodic_true),
					 .i_div_number(div_number), // The integer value you want to the divide the PPS signal 
					 .i_phase_us(phase_us), // The delay or phase offset of the divider generated signal in microseconds 
					 .i_width_us(width_us), // The time width of the divider signal
					 .i_start(start), 
					 .i_stop(stop),
					 .o_pps_divided(pps_divided)
					);
						 
	//--------------------------------
	// waveform file generation 
	//--------------------------------
	
	initial
	begin
		$dumpfile ("wave_pps_divider.vcd");
		$dumpvars;
	end
	
	//--------------------------------
	// Directed stimulus generation
	//--------------------------------
  
	initial begin
		
		// initialization
		#1000000
		rst = 1'b1;
		rst = 1'b0;
		stop = 8'd1;
		start = 8'd1; 
		#1000000
		
		// test 1 - periodic, no phase, 20 us width
		periodic_true = 8'd1; 
		div_number = 8'd1; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		#1000000
		stop = 8'd1; 
		#100
		
		
		// test 2 - not periodic phase is 1 
		periodic_true = 8'd0; 
		div_number = 8'd1; 
		phase_us = 32'd1; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd2; 
		#1000000
		stop = 8'd1; 
		#100
		
		// test 3 - phase of 0 us  width 200 
		periodic_true = 8'd1;
		phase_us = 32'd0;
		width_us = 8'd200;
		stop = 8'd0; 
		which_test = 32'd3; 
		#1000000
		stop = 8'd1; 
		#100
		// test 4 - width is 0 phase is 1 
		periodic_true = 8'd1;
		phase_us = 32'd1; 
		width_us = 8'd0; 
		stop = 8'd0; 
		which_test = 32'd4;  
		#1000000
		stop = 8'd1; 
		#100
		// test 5 - width is 50 phase is 50 
		periodic_true = 8'd1;
		phase_us = 32'd50; 
		width_us = 8'd50;
		stop = 8'd0; 
		which_test = 32'd5; 
		#1000000
		stop = 8'd1; 
		#100
		// test 6 - div_number is 1
		periodic_true = 8'd1;
		div_number = 8'd1; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd6; 
		#1000000
		stop = 8'd1; 
		#100
		// test 7 - div_number is 2
		periodic_true = 8'd1;
		div_number = 8'd2; 
		phase_us = 32'd0; 
		width_us = 8'd20; 
		stop = 8'd0; 
		which_test = 32'd7; 
		#1000000
		stop = 8'd1; 
		#100
		// test 8 - div_number is 3
		periodic_true = 8'd1;
		div_number = 8'd3; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd8; 
		#1000000
		stop = 8'd1; 
		#100
		// test 9 - div_number is 4
		periodic_true = 8'd1;
		div_number = 8'd4; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd9; 
		#1000000
		stop = 8'd1; 
		#100
		// test 10 - div_number is 6
		periodic_true = 8'd1;
		div_number = 8'd6; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd10; 
		#1000000
		stop = 8'd1; 
		#100
		// test n - back to original settings
		periodic_true = 8'd1; 
		div_number = 8'd1; 
		phase_us = 32'd0; 
		width_us = 8'd20;
		stop = 8'd0; 
		which_test = 32'd100; 
		#1000000
		stop = 8'd1; 
		#100
		
		// exit simulation
		#1000000
		$finish;
	end 
	
	//--------------------------------
	// Response displays 
	//--------------------------------
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
endmodule 


/*********************************************************************
default_clk_gen

description: clock generation module for testbench 
**********************************************************************/


module default_clk_gen #(parameter CLK_PERIOD_NS = 100)
						(output wire o_clk);
	
	// signal declaration 
	reg r_clk = 1'b0; 
	
	// clock generation logic 
    initial
    begin
        forever
        begin
            #(CLK_PERIOD_NS / 2) r_clk = ~r_clk;  
        end
    end
	
	// output 
	assign o_clk = r_clk; 

endmodule

