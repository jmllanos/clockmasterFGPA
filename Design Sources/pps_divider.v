/*********************************************************************
Jicamarca Radio Observatory

file: pps_divider.v
author: Eloise Perrochet 
description: 

Change added by J.Llanos at 08/28/2019
parameterization of data width (bits)


**********************************************************************/
`include "address_map.vh"

module pps_divider ( input i_clk_10, // 10 mhz clock 
			         input i_rst, // reset 
			         input i_pps_raw, // pps signal input 
			         input [`DATA_WIDTH-1:0]  i_periodic_true, // A flag that determines if the divider output will be periodic or if it will generate for just a time interval
			         input [`DATA_WIDTH-1:0]  i_div_number, // The integer value you want to the divide the PPS signal 
			         input [`DATA_WIDTH*3-1:0] i_phase_us, // The delay or phase offset of the divider generated signal in microseconds 
			         input [`DATA_WIDTH-1:0]  i_width_us, // The time width of the divider signal
			         input [`DATA_WIDTH-1:0]  i_start, 
			         input [`DATA_WIDTH-1:0]  i_stop,
			         output o_pps_divided
			   	   );

	
	reg [`DATA_WIDTH*3-1:0] r_phase_counter = `DATA_WIDTH*3'd0; 
	reg [`DATA_WIDTH-1:0] r_width_counter = `DATA_WIDTH'd0;
	reg [`DATA_WIDTH-1:0] r_div_counter = `DATA_WIDTH'd0;
	
	wire w_phase_count_done; 
	wire w_width_count_done; 
	wire w_div_count_done; 



	// ---------------------------------------------------
	// Internal declarations
	// --------------------------------------------------- 
	
	// output logic 
	reg r_pps_divided;
	
	// state machine constants 
	localparam 
		s_IDLE = 4'd0,
		s_HOLD_FOR_RISING_EDGE_PPS = 4'd1,
		s_PHASE_COUNT = 4'd2, 
		s_WIDTH_COUNT = 4'd3,
		s_DIV_COUNT = 4'd4,
		s_HOLD_NOT_PERIODIC = 4'd5;
		
	// present state and next state for FSM
	reg [3:0] r_state_pps = 4'd0; 
	reg [3:0] r_next_state_pps = 4'd0; 
	
	// ---------------------------------------------------
	// Edge detection logic 
	// ---------------------------------------------------
	
	/*
	// using this method requires one clock cycle for edge detection 
	// store previous pps value 
	reg r_prev_pps_raw = 0;  
	always @(posedge i_clk_10) begin
		if (i_rst || !i_start || i_stop) begin
			r_prev_pps_raw <= 0; 
		end
		else begin
			r_prev_pps_raw <= i_pps_raw; 
		end
	end
	// rising edge logic 
	wire w_pps_rising_edge;
	assign w_pps_rising_edge = (r_prev_pps_raw == 0 && i_pps_raw == 1); 
	*/ 
	
	// using this method requires two clock cycles for edge detection 
	// however using a shift register helps with metastability issues 
	// shift register 
	reg [1:0] r_pps_shift = 2'b00;  
	always @(posedge i_clk_10) begin
		if (i_rst || !i_start || i_stop) begin
			r_pps_shift <= 2'b00;
		end
		else begin
			r_pps_shift <= {r_pps_shift[0], i_pps_raw}; 
		end
	end
	// rising edge logic 
	wire w_pps_rising_edge;
	assign w_pps_rising_edge = (r_pps_shift == 2'b01); 
	
	// ---------------------------------------------------
	// Finite state machine 
	// ---------------------------------------------------
	
	// combo logic for next state changes 
	always @ (*)
	begin
		case (r_state_pps)
			s_IDLE: 
			begin
				if (i_start && !i_stop) begin
					r_next_state_pps = s_HOLD_FOR_RISING_EDGE_PPS; 
				end
				else begin
					r_next_state_pps = s_IDLE; 
				end
			end
			s_HOLD_FOR_RISING_EDGE_PPS:
			begin 
				if (w_pps_rising_edge) begin
					if (i_phase_us == 0) begin // skip phase count 
						if (i_width_us == 0) begin // skip width count 
							r_next_state_pps = s_HOLD_FOR_RISING_EDGE_PPS;
						end
						else begin
							r_next_state_pps = s_WIDTH_COUNT;
						end
					end
					else begin
						r_next_state_pps = s_PHASE_COUNT;
					end
				end 
				else begin
					r_next_state_pps = s_HOLD_FOR_RISING_EDGE_PPS; 
				end
			end
			s_PHASE_COUNT: 
			begin
				if (w_phase_count_done) begin
					if (i_width_us == 0) begin // skip width count 
						r_next_state_pps = s_HOLD_FOR_RISING_EDGE_PPS; 
					end
					else begin
						r_next_state_pps = s_WIDTH_COUNT; 
					end
				end 
				else begin
					r_next_state_pps = s_PHASE_COUNT; 
				end
			end
			s_WIDTH_COUNT: 
			begin
				if (w_width_count_done) begin
					if (i_periodic_true) begin
						r_next_state_pps = s_DIV_COUNT; 
					end
					else begin
						r_next_state_pps = s_HOLD_NOT_PERIODIC; 
					end
				end 
				else begin
					r_next_state_pps = s_WIDTH_COUNT; 
				end
			end
			s_DIV_COUNT:
			begin
				if (w_div_count_done) begin
					r_next_state_pps = s_HOLD_FOR_RISING_EDGE_PPS; 
				end
				else
				begin
					r_next_state_pps = s_DIV_COUNT; 
				end
			end
			s_HOLD_NOT_PERIODIC: 
			begin
				if (i_stop) begin
					r_next_state_pps = s_IDLE; 
				end
				else begin	
					r_next_state_pps = s_HOLD_NOT_PERIODIC; // stay in not periodic wait state 
				end
			end
			default:
			begin
				r_next_state_pps = s_IDLE; // default next state: go to idle 
			end
		endcase 	
	end
	
	// logic for incrementing counters
	// counters for state changes 
	
	
	assign w_phase_count_done = (r_phase_counter >= i_phase_us); 
	assign w_width_count_done = (r_width_counter >= i_width_us); 
	assign w_div_count_done = (i_div_number == 0) ? 1'b1 : (r_div_counter >= i_div_number - 1); // set the count done to 1 if the div number is 0 
	
	// for accurate time base 
	localparam c_CLKS_PER_1_US = 10; 
	reg [31:0] r_clk_counter; 
	
	always @ (posedge i_clk_10) 
	begin
		if (r_state_pps == s_HOLD_FOR_RISING_EDGE_PPS) begin
			r_phase_counter <=`DATA_WIDTH*3'd0; 
			r_width_counter <= `DATA_WIDTH'd0; 
			r_div_counter <= `DATA_WIDTH'd0;
			r_clk_counter <= 32'd0;  
		end
		if (r_state_pps == s_PHASE_COUNT) begin 
			if (r_clk_counter < c_CLKS_PER_1_US - 1) begin
				r_clk_counter <= r_clk_counter + 32'd1; 
			end
			else begin
				r_phase_counter <= r_phase_counter + `DATA_WIDTH*3'd1;
				r_clk_counter <= 32'd0;
			end
		end 
		if (r_state_pps == s_WIDTH_COUNT) begin
			if (r_clk_counter < c_CLKS_PER_1_US - 1) begin
				r_clk_counter <= r_clk_counter + 32'd1;   
			end
			else begin
				r_width_counter <= r_width_counter + `DATA_WIDTH'd1;
				r_clk_counter <= 32'd0;
			end
		end
		if (r_state_pps == s_DIV_COUNT) begin
			if (w_pps_rising_edge) begin
				r_div_counter <= r_div_counter + `DATA_WIDTH'd1;
			end 
		end
	end
	
	// seq logic for present state changes 
	always @ (posedge i_clk_10)
	begin
		if (i_rst || i_stop)
			r_state_pps <= s_IDLE; // synchronous reset state 
		else 
			r_state_pps <= r_next_state_pps;
	end
	
	// ---------------------------------------------------
	// Output logic 
	// ---------------------------------------------------
	
	always @ (*) begin
		// width count and get rid of any extra clock cycles 
		if ((r_next_state_pps == s_WIDTH_COUNT) || (r_state_pps == s_WIDTH_COUNT && r_next_state_pps != s_DIV_COUNT && r_next_state_pps != s_HOLD_NOT_PERIODIC)) begin 
			r_pps_divided = 1'b1; 
		end 
		else begin
			r_pps_divided = 1'b0; 
		end
	end
	
	assign o_pps_divided = r_pps_divided; 
	
									
endmodule



