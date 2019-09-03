/*********************************************************************

file: thunderbolt_registers.v
author: Victor Vasquez
description:

**********************************************************************/
`include "address_map.vh"//

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
            o_data <= 8'h00;
			if (i_wr == 1'b0) begin
                case (i_addr)
                    `THUNDER_YEAR_L	    : o_data <= i_thunder_year_l;
                    `THUNDER_YEAR_H	    : o_data <= i_thunder_year_h;
                    `THUNDER_MONTH	    : o_data <= i_thunder_month;
                    `THUNDER_DAY	    : o_data <= i_thunder_day;
                    `THUNDER_HOUR	    : o_data <= i_thunder_hour;
                    `THUNDER_MINUTES	: o_data <= i_thunder_minutes;
                    `THUNDER_SECONDS	: o_data <= i_thunder_seconds;
                endcase
			end
//			else begin
//				o_data <= `ERROR;
//			end
		end
	end

endmodule