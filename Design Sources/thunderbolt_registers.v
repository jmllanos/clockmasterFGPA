/*********************************************************************

file: thunderbolt_registers.v
author: Victor Vasquez
description:

**********************************************************************/

module thunderbolt_registers (
    input i_clk,
    input i_rst,
    // memory
    input	i_wr,
    input	[6:0] i_addr,
    input	[7:0] i_data,
    output reg [7:0] o_data = 8'h00,
    // address
    input   [7:0] i_thunder_year_h,
    input   [7:0] i_thunder_year_l,
    input   [7:0] i_thunder_month,
    input   [7:0] i_thunder_day,
    input   [7:0] i_thunder_hour,
    input   [7:0] i_thunder_minutes,
    input   [7:0] i_thunder_seconds
);

	always @ (posedge i_clk) begin
		if (i_rst) begin
			o_data	<= 8'h00;
		end
		else begin
			if (i_wr == 1'b0) begin
                case (i_addr)
                    8'h07	: o_data <= i_thunder_year_l;
                    8'h08	: o_data <= i_thunder_year_h;
                    8'h09	: o_data <= i_thunder_month;
                    8'h0A	: o_data <= i_thunder_day;
                    8'h0B	: o_data <= i_thunder_hour;
                    8'h0C	: o_data <= i_thunder_minutes;
                    8'h0D	: o_data <= i_thunder_seconds;
                    default	: o_data <= 8'h00;
                endcase
			end
			else begin
				o_data <= 8'hCC;//codigo error
			end
		end
	end

endmodule