/*********************************************************************

file: pulse_generator_registers.v
author: Victor Vasquez
description:

**********************************************************************/

module pulse_generator_registers #(
    parameter PULSE_ENA      = 'h10,
    parameter USR_YEAR_H     = 'h11,
    parameter USR_YEAR_L     = 'h12,
    parameter USR_MONTH      = 'h13,
    parameter USR_DAY        = 'h14,
    parameter USR_HOUR       = 'h15,
    parameter USR_MINUTES    = 'h16,
    parameter USR_SECONDS    = 'h17,
    parameter WIDTH_HIGH_3   = 'h18,
    parameter WIDTH_HIGH_2   = 'h19,
    parameter WIDTH_HIGH_1   = 'h1A,
    parameter WIDTH_HIGH_0   = 'h1B,
    parameter WIDTH_PERIOD_3 = 'h1C,
    parameter WIDTH_PERIOD_2 = 'h1D,
    parameter WIDTH_PERIOD_1 = 'h1E,
    parameter WIDTH_PERIOD_0 = 'h1F
    )(
    input i_clk,
    input i_rst,
    // memory
    input	i_wr,
    input	[6:0] i_addr,
    input	[7:0] i_data,
    output reg [7:0] o_data = 8'h00,
    // address
    output reg [7:0] o_pulse_enable = 8'h00,
    output reg [7:0] o_usr_year_h = 8'h00, // four digits of year
    output reg [7:0] o_usr_year_l = 8'h00, // four digits of year
    output reg [7:0] o_usr_month = 8'h00, // month of the year (0-12)
    output reg [7:0] o_usr_day = 8'h00, // day of month (1-31)
    output reg [7:0] o_usr_hour = 8'h00, // hours (0-23)
    output reg [7:0] o_usr_minutes = 8'h00, // minutes (0-59)
    output reg [7:0] o_usr_seconds = 8'h00, // seconds (0-59)
    output reg [7:0] o_width_high_3 = 8'h00, // microsecond width of the pulse
    output reg [7:0] o_width_high_2 = 8'h00, // microsecond width of the pulse
    output reg [7:0] o_width_high_1 = 8'h00, // microsecond width of the pulse
    output reg [7:0] o_width_high_0 = 8'h00, // microsecond width of the pulse
    output reg [7:0] o_width_period_3 = 8'h00, //period of pulse
    output reg [7:0] o_width_period_2 = 8'h00, //period of pulse
    output reg [7:0] o_width_period_1 = 8'h00, //period of pulse
    output reg [7:0] o_width_period_0 = 8'h00 //period of pulse
);
	// ---------------------------------------------------
	// memory logic
	// ---------------------------------------------------
 	always @ (posedge i_clk) begin
		if (i_rst) begin
			o_data	<= 8'h00;
            o_pulse_enable  <= 8'h00;
            o_usr_year_h    <= 8'h00;
            o_usr_year_l    <= 8'h00;
            o_usr_month     <= 8'h00;
            o_usr_day       <= 8'h00;
            o_usr_hour      <= 8'h00;
            o_usr_minutes   <= 8'h00;
            o_usr_seconds   <= 8'h00;
            o_width_high_3  <= 8'h00;
            o_width_high_2  <= 8'h00;
            o_width_high_1  <= 8'h00;
            o_width_high_0  <= 8'h00;
            o_width_period_3<= 8'h00;
            o_width_period_2<= 8'h00;
            o_width_period_1<= 8'h00;
            o_width_period_0<= 8'h00;
		end
		else begin
            o_data <= 8'h00;
            case (i_addr)
                PULSE_ENA      : if (i_wr) o_pulse_enable    <= i_data;
                                 else      o_data <= o_pulse_enable;
                USR_YEAR_H     : if (i_wr) o_usr_year_h      <= i_data;
                                 else      o_data <= o_usr_year_h;
                USR_YEAR_L     : if (i_wr) o_usr_year_l      <= i_data;
                                 else      o_data <= o_usr_year_l;
                USR_MONTH      : if (i_wr) o_usr_month       <= i_data;
                                 else      o_data <= o_usr_month;
                USR_DAY        : if (i_wr) o_usr_day         <= i_data;
                                 else      o_data <= o_usr_day;
                USR_HOUR       : if (i_wr) o_usr_hour        <= i_data;
                                 else      o_data <= o_usr_hour;
                USR_MINUTES    : if (i_wr) o_usr_minutes     <= i_data;
                                 else      o_data <= o_usr_minutes;
                USR_SECONDS    : if (i_wr) o_usr_seconds     <= i_data;
                                 else      o_data <= o_usr_seconds;
                WIDTH_HIGH_3   : if (i_wr) o_width_high_3    <= i_data;
                                 else      o_data <= o_width_high_3;
                WIDTH_HIGH_2   : if (i_wr) o_width_high_2    <= i_data;
                                 else      o_data <= o_width_high_2;
                WIDTH_HIGH_1   : if (i_wr) o_width_high_1    <= i_data;
                                 else      o_data <= o_width_high_1;
                WIDTH_HIGH_0   : if (i_wr) o_width_high_0    <= i_data;
                                 else      o_data <= o_width_high_0;
                WIDTH_PERIOD_3 : if (i_wr) o_width_period_3  <= i_data;
                                 else      o_data <= o_width_period_3;
                WIDTH_PERIOD_2 : if (i_wr) o_width_period_2  <= i_data;
                                 else      o_data <= o_width_period_2;
                WIDTH_PERIOD_1 : if (i_wr) o_width_period_1  <= i_data;
                                 else      o_data <= o_width_period_1;
                WIDTH_PERIOD_0 : if (i_wr) o_width_period_0  <= i_data;
                                 else      o_data <= o_width_period_0;
            endcase
/*			if (i_wr == 1'b0) begin
                o_data <= 8'h00;
                case (i_addr)
                    PULSE_ENA      : o_data <= o_pulse_enable;
                    USR_YEAR_H     : o_data <= o_usr_year_h;
                    USR_YEAR_L     : o_data <= o_usr_year_l;
                    USR_MONTH      : o_data <= o_usr_month;
                    USR_DAY        : o_data <= o_usr_day;
                    USR_HOUR       : o_data <= o_usr_hour;
                    USR_MINUTES    : o_data <= o_usr_minutes;
                    USR_SECONDS    : o_data <= o_usr_seconds;
                    WIDTH_HIGH_3   : o_data <= o_width_high_3;
                    WIDTH_HIGH_2   : o_data <= o_width_high_2;
                    WIDTH_HIGH_1   : o_data <= o_width_high_1;
                    WIDTH_HIGH_0   : o_data <= o_width_high_0;
                    WIDTH_PERIOD_3 : o_data <= o_width_period_3;
                    WIDTH_PERIOD_2 : o_data <= o_width_period_2;
                    WIDTH_PERIOD_1 : o_data <= o_width_period_1;
                    WIDTH_PERIOD_0 : o_data <= o_width_period_0;
                endcase
		    end
			else begin
                case (i_addr)
                    PULSE_ENA      : o_pulse_enable    <= i_data;
                    USR_YEAR_H     : o_usr_year_h      <= i_data;
                    USR_YEAR_L     : o_usr_year_l      <= i_data;
                    USR_MONTH      : o_usr_month       <= i_data;
                    USR_DAY        : o_usr_day         <= i_data;
                    USR_HOUR       : o_usr_hour        <= i_data;
                    USR_MINUTES    : o_usr_minutes     <= i_data;
                    USR_SECONDS    : o_usr_seconds     <= i_data;
                    WIDTH_HIGH_3   : o_width_high_3    <= i_data;
                    WIDTH_HIGH_2   : o_width_high_2    <= i_data;
                    WIDTH_HIGH_1   : o_width_high_1    <= i_data;
                    WIDTH_HIGH_0   : o_width_high_0    <= i_data;
                    WIDTH_PERIOD_3 : o_width_period_3  <= i_data;
                    WIDTH_PERIOD_2 : o_width_period_2  <= i_data;
                    WIDTH_PERIOD_1 : o_width_period_1  <= i_data;
                    WIDTH_PERIOD_0 : o_width_period_0  <= i_data;
                endcase
			end*/
		end
	end

endmodule