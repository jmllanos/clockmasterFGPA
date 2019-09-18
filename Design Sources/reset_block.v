/*********************************************************************
Victor Vasquez
description: one global reset out of manual reset, power on reset and
             software reset
**********************************************************************/

module reset_block (
    input   i_clk,
    input   i_rst_man,
    input   i_rst_por,
    input   i_rst_sw,
    output reg o_rst
);

always @ (posedge i_clk) begin
    o_rst   <= i_rst_man | i_rst_por | i_rst_sw;
end

endmodule