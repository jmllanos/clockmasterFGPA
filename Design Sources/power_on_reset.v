/*********************************************************************
Victor Vasquez
description: power on reset of 16 clock cycles
**********************************************************************/

module power_on_reset(
    input   i_clk,
    output reg o_por = 1'b1
);

reg [3:0]r_counter = 4'h0;

always @ (posedge i_clk) begin
    if (r_counter < 4'hf) begin
        o_por       <= 1'b1;
        r_counter   <= r_counter + 4'h1;
    end
    else begin
        o_por   <= 1'b0;
    end
end

endmodule