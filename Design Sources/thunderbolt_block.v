/*********************************************************************

file: thunderbolt_block.v
author: Victor Vasquez
description:

**********************************************************************/

module thunderbolt_block (
    input i_clk,
    input i_rst,
    // memory
    input	i_wr,
    input	[6:0] i_addr,
    input	[7:0] i_data,
    output  [7:0] o_data,
    // rs232 connection
    input	i_rx_thunder,  // serial from thunderbolt
    output	o_tx_thunder, // serial to thunderbolt
    // flag to indicate that thunder packet data is valid
    output  o_thunder_packet_dv,
    // data that contains contents of thunderbolt packet
    output  [7:0] o_thunder_year_h,
    output  [7:0] o_thunder_year_l,
    output  [7:0] o_thunder_month,
    output  [7:0] o_thunder_day,
    output  [7:0] o_thunder_hour,
    output  [7:0] o_thunder_minutes,
    output  [7:0] o_thunder_seconds
);

    wire[7:0] w_thunder_year_h;
    wire[7:0] w_thunder_year_l;
    wire[7:0] w_thunder_month;
    wire[7:0] w_thunder_day;
    wire[7:0] w_thunder_hour;
    wire[7:0] w_thunder_minutes;
    wire[7:0] w_thunder_seconds;

    thunderbolt T(
        .i_clk              (i_clk),
        .i_rst					(i_rst),
        .i_rx_thunder			(i_rx_thunder),
        .o_tx_thunder			(o_tx_thunder),
        .o_thunder_packet_dv	(o_thunder_packet_dv),
        .o_thunder_year_h		(w_thunder_year_h),
        .o_thunder_year_l		(w_thunder_year_l),
        .o_thunder_month		(w_thunder_month),
        .o_thunder_day			(w_thunder_day),
        .o_thunder_hour			(w_thunder_hour),
        .o_thunder_minutes		(w_thunder_minutes),
        .o_thunder_seconds		(w_thunder_seconds)
    );

    thunderbolt_registers TR(
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_wr               (i_wr),
        .i_addr             (i_addr),
        .i_data             (i_data),
        .o_data             (o_data),
        .i_thunder_year_h	(w_thunder_year_h),
        .i_thunder_year_l	(w_thunder_year_l),
        .i_thunder_month	(w_thunder_month),
        .i_thunder_day		(w_thunder_day),
        .i_thunder_hour		(w_thunder_hour),
        .i_thunder_minutes	(w_thunder_minutes),
        .i_thunder_seconds	(w_thunder_seconds) 
    );

assign o_thunder_year_h     = w_thunder_year_h;
assign o_thunder_year_l     = w_thunder_year_l;
assign o_thunder_month      = w_thunder_month;
assign o_thunder_day        = w_thunder_day;
assign o_thunder_hour       = w_thunder_hour;
assign o_thunder_minutes    = w_thunder_minutes;
assign o_thunder_seconds    = w_thunder_seconds;

endmodule