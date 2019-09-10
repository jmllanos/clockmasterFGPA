/*********************************************************************

file: pulse_generator_registers.v
author: Victor Vasquez
description:

**********************************************************************/

`include "address_map.vh"

module pulse_generator_registers #(
    parameter PULSE_ENA      = `PG0_PULSE_ENA,
    parameter USR_YEAR_H     = `PG0_USR_YEAR_H,
    parameter USR_YEAR_L     = `PG0_USR_YEAR_L,
    parameter USR_MONTH      = `PG0_USR_MONTH,
    parameter USR_DAY        = `PG0_USR_DAY,
    parameter USR_HOUR       = `PG0_USR_HOUR,
    parameter USR_MINUTES    = `PG0_USR_MINUTES,
    parameter USR_SECONDS    = `PG0_USR_SECONDS,
    parameter WIDTH_HIGH_2   = `PG0_WIDTH_HIGH_2,
    parameter WIDTH_HIGH_1   = `PG0_WIDTH_HIGH_1,
    parameter WIDTH_HIGH_0   = `PG0_WIDTH_HIGH_0,
    parameter WIDTH_PERIOD_2 = `PG0_WIDTH_PERIOD_2,
    parameter WIDTH_PERIOD_1 = `PG0_WIDTH_PERIOD_1,
    parameter WIDTH_PERIOD_0 = `PG0_WIDTH_PERIOD_0
    )(
    input i_clk,
    input i_rst,
    // memory
    input	i_wr,
    input	[`ADDR_WIDTH-1:0] i_addr,
    input	[`DATA_WIDTH-1:0] i_data,
    output reg [`DATA_WIDTH-1:0] o_data,
    // address
    output reg [`DATA_WIDTH-1:0] o_pulse_enable,
    output reg [`DATA_WIDTH-1:0] o_usr_year_h, // four digits of year
    output reg [`DATA_WIDTH-1:0] o_usr_year_l, // four digits of year
    output reg [`DATA_WIDTH-1:0] o_usr_month, // month of the year (0-12)
    output reg [`DATA_WIDTH-1:0] o_usr_day, // day of month (1-31)
    output reg [`DATA_WIDTH-1:0] o_usr_hour, // hours (0-23)
    output reg [`DATA_WIDTH-1:0] o_usr_minutes, // minutes (0-59)
    output reg [`DATA_WIDTH-1:0] o_usr_seconds, // seconds (0-59)
    output reg [`DATA_WIDTH-1:0] o_width_high_2, // microsecond width of the pulse
    output reg [`DATA_WIDTH-1:0] o_width_high_1, // microsecond width of the pulse
    output reg [`DATA_WIDTH-1:0] o_width_high_0, // microsecond width of the pulse
    output reg [`DATA_WIDTH-1:0] o_width_period_2, //period of pulse
    output reg [`DATA_WIDTH-1:0] o_width_period_1, //period of pulse
    output reg [`DATA_WIDTH-1:0] o_width_period_0 //period of pulse
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
            o_width_high_2  <= 8'h00;
            o_width_high_1  <= 8'h00;
            o_width_high_0  <= 8'h00;
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
                WIDTH_HIGH_2   : if (i_wr) o_width_high_2    <= i_data;
                                 else      o_data <= o_width_high_2;
                WIDTH_HIGH_1   : if (i_wr) o_width_high_1    <= i_data;
                                 else      o_data <= o_width_high_1;
                WIDTH_HIGH_0   : if (i_wr) o_width_high_0    <= i_data;
                                 else      o_data <= o_width_high_0;
                WIDTH_PERIOD_2 : if (i_wr) o_width_period_2  <= i_data;
                                 else      o_data <= o_width_period_2;
                WIDTH_PERIOD_1 : if (i_wr) o_width_period_1  <= i_data;
                                 else      o_data <= o_width_period_1;
                WIDTH_PERIOD_0 : if (i_wr) o_width_period_0  <= i_data;
                                 else      o_data <= o_width_period_0;
            endcase
		end
	end

endmodule