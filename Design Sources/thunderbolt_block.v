/*********************************************************************

file: thunderbolt_block.v
author: Victor Vasquez
description:

**********************************************************************/
`include "address_map.vh"

module thunderbolt_block (
    input i_clk,
    input i_rst,
    input i_pps_raw,
    // memory
    input	i_wr,
    input	[`ADDR_WIDTH-1:0] i_addr,
    input	[`DATA_WIDTH-1:0] i_data,
    output  [`DATA_WIDTH-1:0] o_data,
    // rs232 connection
    input	i_rx_thunder,  // serial from thunderbolt
    output	o_tx_thunder, // serial to thunderbolt
    // flag to indicate that thunder packet data is valid
    output  o_thunder_packet_dv,
    // data that contains contents of thunderbolt packet
    output  [`DATA_WIDTH-1:0] o_thunder_year_h,
    output  [`DATA_WIDTH-1:0] o_thunder_year_l,
    output  [`DATA_WIDTH-1:0] o_thunder_month,
    output  [`DATA_WIDTH-1:0] o_thunder_day,
    output  [`DATA_WIDTH-1:0] o_thunder_hour,
    output  [`DATA_WIDTH-1:0] o_thunder_minutes,
    output  [`DATA_WIDTH-1:0] o_thunder_seconds
);

    wire[`DATA_WIDTH-1:0] w_thunder_year_h;
    wire[`DATA_WIDTH-1:0] w_thunder_year_l;
    wire[`DATA_WIDTH-1:0] w_thunder_month;
    wire[`DATA_WIDTH-1:0] w_thunder_day;
    wire[`DATA_WIDTH-1:0] w_thunder_hour;
    wire[`DATA_WIDTH-1:0] w_thunder_minutes;
    wire[`DATA_WIDTH-1:0] w_thunder_seconds;

    thunderbolt T(
        .i_clk                  (i_clk),
        .i_rst                  (i_rst),
        .i_pps_raw              (i_pps_raw),
        .i_rx_thunder           (i_rx_thunder),
        .o_tx_thunder		    (o_tx_thunder),
        .o_thunder_packet_dv    (o_thunder_packet_dv),
        .o_thunder_year_h	    (w_thunder_year_h),
        .o_thunder_year_l	    (w_thunder_year_l),
        .o_thunder_month	    (w_thunder_month),
        .o_thunder_day		    (w_thunder_day),
        .o_thunder_hour		    (w_thunder_hour),
        .o_thunder_minutes	    (w_thunder_minutes),
        .o_thunder_seconds	    (w_thunder_seconds)
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