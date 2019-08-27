/*********************************************************************

file: pulse_generator.v
author: Eloise Perrochet
description:
upgrade: Victor Vasquez
   - in sync with PPS
   - pulses...

**********************************************************************/

module pulse_generator (
      input i_clk,
      input i_rst,
      input [7:0] i_pulse_enable,
      input i_pps_raw,
      // user config
      input [15:0] i_usr_year, // four digits of year
      input [7:0] i_usr_month, // month of the year (0-12)
      input [7:0] i_usr_day, // day of month (1-31)
      input [7:0] i_usr_hour, // hours (0-23)
      input [7:0] i_usr_minutes, // minutes (0-59)
      input [7:0] i_usr_seconds, // seconcds (0-59)
      input [31:0] i_usr_width_us, // milisecond width of the pulse
      input [32:0] i_periodic_width, //period of pulse
      // thunderbolt
      input i_thunder_packet_dv, // thunderbolt data valid flag
      input [15:0] i_thunder_year,
      input [7:0] i_thunder_month,
      input [7:0] i_thunder_day,
      input [7:0] i_thunder_hour,
      input [7:0] i_thunder_minutes,
      input [7:0] i_thunder_seconds,
      // pulse
      output o_pulse_out
     );

	// ---------------------------------------------------
	// PPS detection logic
	// ---------------------------------------------------

	// present state and next state variables
	reg [3:0] r_state;
	reg [3:0] r_next_state;

	// state constants
	parameter
		s_COUNTDOWN_IDLE = 4'd0,
		s_YEAR = 4'd1,
		s_MONTH = 4'd2,
		s_DAY = 4'd3,
		s_HOUR = 4'd4,
		s_MINUTES = 4'd5,
		s_SECONDS = 4'd6,
		s_COUNT_MICRO = 4'd7,
		s_PERIODIC = 4'd8,
		s_GET_READY_COUNTER = 4'd9;

	// counter logic
   parameter c_CLKS_PER_1_US = 10;///////////////////:..................
   reg [32:0] r_micro_counter;
   reg [32:0] r_clk_counter;

   //parameter TIME_PERIODIC =32'd2000000;//en useg
   reg [32:0] r_periodic_counter;

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
				if(i_pulse_enable && r_pulse_valid_flag) begin
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
					//r_next_state = s_COUNT_MICRO;
					r_next_state = s_GET_READY_COUNTER;
				end
				else begin
					r_next_state = s_SECONDS;
				end
			end

			s_GET_READY_COUNTER: begin
					r_next_state = s_COUNT_MICRO;
			end
			s_COUNT_MICRO: begin
				if (r_micro_counter == i_usr_width_us) begin
					//r_next_state = s_COUNTDOWN_IDLE;//lois
					r_next_state = s_PERIODIC;
				end
				else begin
					r_next_state = s_COUNT_MICRO;
				end
			end

			s_PERIODIC: begin

				if(r_periodic_counter == i_periodic_width) begin
					r_next_state = s_GET_READY_COUNTER;
				end

				else begin
					r_next_state = s_PERIODIC;
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
	//if (i_rst || !i_pulse_enable[0] || (r_state != s_COUNT_MICRO)) begin
		if (i_rst || !i_pulse_enable[0] || r_state == s_GET_READY_COUNTER) begin
			r_micro_counter <= 0;
			r_clk_counter <= 0;
			r_periodic_counter <= 0;
		end
		else begin

			if (r_state == s_COUNT_MICRO ) begin
				if (r_clk_counter < c_CLKS_PER_1_US) begin
					r_clk_counter <= r_clk_counter + 1;
				end
				else begin
					r_micro_counter <= r_micro_counter + 1;
					r_clk_counter <= 0;
				end
			end

			if (r_state == s_PERIODIC) begin
				if (r_clk_counter < c_CLKS_PER_1_US-1) begin
					r_clk_counter <= r_clk_counter + 1;
				end
				else begin
					r_periodic_counter <= r_periodic_counter+1;
					r_clk_counter <= 0;
				end

			end
		end
	end

	// output logic
	assign o_pulse_out = (r_state == s_COUNT_MICRO);

endmodule
