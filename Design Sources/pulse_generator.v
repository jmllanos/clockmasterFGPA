/*********************************************************************

file: pulse_generator.v
author: Eloise Perrochet (original)
description:
upgrade: Victor Vasquez
   - in sync with PPS
   - width_low (32 bits instead of 33)
   - pulses for microsecond reduced by 1, it was delayed once per microsecond
     and one wrong clk cycle value was at the end of high perdiod
     pulses at the next cycle started 2 clocks cycles late because of transition
     of states. Now the states wait for the N-1 width
   - all counters to 32-bit width
   - pulse_out waits for pps and its delayed 3 clock cycles max
   - signal in pulse_out is truly periodic
**********************************************************************/

module pulse_generator #(parameter CLKS_PER_1_US = 10)(
    input i_clk,
    input i_rst,
    // pps input
    input i_pps_raw,
    // enable register
    input [7:0] i_pulse_enable,
    // user config
    input [15:0] i_usr_year, // four digits of year
    input [7:0] i_usr_month, // month of the year (0-12)
    input [7:0] i_usr_day, // day of month (1-31)
    input [7:0] i_usr_hour, // hours (0-23)
    input [7:0] i_usr_minutes, // minutes (0-59)
    input [7:0] i_usr_seconds, // seconds (0-59)
    input [23:0] i_width_high, // microsecond width of the pulse
    input [23:0] i_width_period, //period of pulse
    // thunderbolt time of day
    input i_thunder_packet_dv, // thunderbolt data valid flag
    input [15:0] i_thunder_year,
    input [7:0] i_thunder_month,
    input [7:0] i_thunder_day,
    input [7:0] i_thunder_hour,
    input [7:0] i_thunder_minutes,
    input [7:0] i_thunder_seconds,
    // pulse
    output reg o_pulse_out
);

     reg    [1:0]r_pps_raw = 0;
	// ---------------------------------------------------
	// PPS detection logic
	// ---------------------------------------------------
	always @ (posedge i_clk) begin
		if (i_rst) begin
            r_pps_raw <= 0;
		end
		else begin
			r_pps_raw <= {r_pps_raw[0], i_pps_raw};
		end
	end   

	// present state and next state variables
	reg [3:0] r_state;
	reg [3:0] r_next_state;
	// state constants
	localparam
		s_COUNTDOWN_IDLE = 4'd0,
		s_YEAR = 4'd1,
		s_MONTH = 4'd2,
		s_DAY = 4'd3,
		s_HOUR = 4'd4,
		s_MINUTES = 4'd5,
		s_SECONDS = 4'd6,
		s_COUNT_MICRO = 4'd7,
		s_GET_READY_COUNTER = 4'd8;
	// counter logic
    reg [23:0] r_clk_counter = 0;
    reg [23:0] r_micro_counter = 0;

	// flag to make sure multiple pulses don't happen before the next thunderbolt packet is received
	reg r_pulse_valid_flag;
	always @(posedge i_clk) begin
		if (i_rst || !i_pulse_enable[0]) begin
			r_pulse_valid_flag <= 0;
		end
		else begin
			if (r_state == s_COUNT_MICRO && r_next_state == s_COUNTDOWN_IDLE) begin // transitioning states
				r_pulse_valid_flag <= 0;
			end
			else if (i_thunder_packet_dv) begin // thunder packet received
				r_pulse_valid_flag <= 1;
			end
		end
	end

	// ---------------------------------------------------
	// Countdown state machine
	// ---------------------------------------------------
	// state transition logic
	always @ (*) begin
		case (r_state)
			s_COUNTDOWN_IDLE: begin
				if(i_pulse_enable[0] && r_pulse_valid_flag) begin
					r_next_state = s_YEAR;
				end
				else begin
					r_next_state = s_COUNTDOWN_IDLE;
				end
			end
			s_YEAR: begin
				if (i_usr_year == i_thunder_year) begin
					r_next_state = s_MONTH;
				end
				else begin
					r_next_state = s_YEAR;
				end
			end
			s_MONTH: begin
				if (i_usr_month == i_thunder_month) begin
					r_next_state = s_DAY;
				end
				else begin
					r_next_state = s_MONTH;
				end
			end
			s_DAY: begin
				if (i_usr_day == i_thunder_day) begin
					r_next_state = s_HOUR;
				end
				else begin
					r_next_state = s_DAY;
				end
			end
			s_HOUR: begin
				if (i_usr_hour == i_thunder_hour) begin
					r_next_state = s_MINUTES;
				end
				else begin
					r_next_state = s_HOUR;
				end
			end
			s_MINUTES: begin
				if (i_usr_minutes == i_thunder_minutes) begin
					r_next_state = s_SECONDS;
				end
				else begin
					r_next_state = s_MINUTES;
				end
			end
			s_SECONDS: begin
				if (i_usr_seconds == i_thunder_seconds) begin
					r_next_state = s_GET_READY_COUNTER;
				end
				else begin
					r_next_state = s_SECONDS;
				end
			end

			s_GET_READY_COUNTER: begin
                if (r_pps_raw == 2'b01) begin
					r_next_state = s_COUNT_MICRO;
                end
			end
			
            s_COUNT_MICRO: begin
                if (i_pulse_enable == 0) begin
                    r_next_state = s_COUNTDOWN_IDLE;
                end
                else begin
                    r_next_state = s_COUNT_MICRO;
                end
			end

			default: begin
				r_next_state = s_COUNTDOWN_IDLE;
			end
		endcase
	end

	// sequential state transition
	always @ (posedge i_clk) begin
		if(i_rst || !i_pulse_enable[0]) begin
			r_state <= s_COUNTDOWN_IDLE;
		end
		else begin
			r_state <= r_next_state;
		end
	end

	always @ (posedge i_clk) begin
		if (i_rst || !i_pulse_enable[0] || r_state == s_GET_READY_COUNTER) begin
			r_micro_counter <= 0;
			r_clk_counter <= 0;
		end
		else begin

            if (r_state == s_COUNT_MICRO) begin
                if (r_clk_counter < CLKS_PER_1_US-1) begin
					r_clk_counter <= r_clk_counter + 1;
				end
				else begin
					r_clk_counter <= 0;
				end
			end
            
            if (r_state == s_COUNT_MICRO) begin
                if (r_clk_counter == CLKS_PER_1_US - 1) begin
					if (r_micro_counter < i_width_period - 1) begin
                        r_micro_counter <= r_micro_counter + 1;
                    end
                    else begin
                        r_micro_counter <= 0;
                    end
				end
			end
           
		end
	end

	// ---------------------------------------------------
	// output process
	// ---------------------------------------------------
	always @ (posedge i_clk) begin
		if (i_rst) begin
			o_pulse_out <= 0;
		end
		else begin
            o_pulse_out <= ((r_micro_counter < i_width_high) && (r_state == s_COUNT_MICRO));
		end
	end

endmodule