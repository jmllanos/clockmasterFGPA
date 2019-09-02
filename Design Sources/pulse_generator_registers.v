/*********************************************************************

file: pulse_generator_registers.v
author: Victor Vasquez
description:

**********************************************************************/

module pulse_generator_registers (
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
            o_pulse_enable  <= 0;
            o_usr_year_h    <= 0;
            o_usr_year_l    <= 0;
            o_usr_month     <= 0;
            o_usr_day       <= 0;
            o_usr_hour      <= 0;
            o_usr_minutes   <= 0;
            o_usr_seconds   <= 0;
            o_width_high_3  <= 0;
            o_width_high_2  <= 0;
            o_width_high_1  <= 0;
            o_width_high_0  <= 0;
            o_width_period_3<= 0;
            o_width_period_2<= 0;
            o_width_period_1<= 0;
            o_width_period_0<= 0;
		end
		else begin
			if (i_wr == 1'b0) begin
                case (i_addr)
                    8'h06	: o_data <= o_pulse_enable;
                    8'h07	: o_data <= o_usr_year_h;
                    8'h08	: o_data <= o_usr_year_l;
                    8'h09	: o_data <= o_usr_month;
                    8'h0A	: o_data <= o_usr_day;
                    8'h0B	: o_data <= o_usr_hour;
                    8'h0C	: o_data <= o_usr_minutes;
                    8'h0D	: o_data <= o_usr_seconds;
                    8'h1D	: o_data <= o_width_high_3;
                    8'h2D	: o_data <= o_width_high_2;
                    8'h3D	: o_data <= o_width_high_1;
                    8'h4D	: o_data <= o_width_high_0;
                    8'h5D	: o_data <= o_width_period_3;
                    8'h6D	: o_data <= o_width_period_2;
                    8'h7D	: o_data <= o_width_period_1;
                    8'h8D	: o_data <= o_width_period_0;
                    default	: o_data <= 8'h00;//......
                endcase
		    end
			else begin
                case (i_addr)
                    8'h06	: o_pulse_enable    <= i_data;
                    8'h07	: o_usr_year_h      <= i_data;
                    8'h08	: o_usr_year_l      <= i_data;
                    8'h09	: o_usr_month       <= i_data;
                    8'h0A	: o_usr_day         <= i_data;
                    8'h0B	: o_usr_hour        <= i_data;
                    8'h0C	: o_usr_minutes     <= i_data;
                    8'h0D	: o_usr_seconds     <= i_data;
                    8'h1D	: o_width_high_3    <= i_data;
                    8'h2D	: o_width_high_2    <= i_data;
                    8'h3D	: o_width_high_1    <= i_data;
                    8'h4D	: o_width_high_0    <= i_data;
                    8'h5D	: o_width_period_3  <= i_data;
                    8'h6D	: o_width_period_2  <= i_data;
                    8'h7D	: o_width_period_1  <= i_data;
                    8'h8D	: o_width_period_0  <= i_data;
                    //default	: ;
                endcase
			end
		end
	end

endmodule