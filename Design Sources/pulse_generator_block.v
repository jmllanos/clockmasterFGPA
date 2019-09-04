/*********************************************************************

file: pulse_generator_block.v
author: Victor Vasquez
description:

**********************************************************************/
`include "address_map.vh"

module pulse_generator_block #(
    parameter PULSE_ENA      = `PG0_PULSE_ENA,
    parameter USR_YEAR_H     = `PG0_USR_YEAR_H,
    parameter USR_YEAR_L     = `PG0_USR_YEAR_L,
    parameter USR_MONTH      = `PG0_USR_MONTH,
    parameter USR_DAY        = `PG0_USR_DAY,
    parameter USR_HOUR       = `PG0_USR_HOUR,
    parameter USR_MINUTES    = `PG0_USR_MINUTES,
    parameter USR_SECONDS    = `PG0_USR_SECONDS,
    parameter WIDTH_HIGH_3   = `PG0_WIDTH_HIGH_3,
    parameter WIDTH_HIGH_2   = `PG0_WIDTH_HIGH_2,
    parameter WIDTH_HIGH_1   = `PG0_WIDTH_HIGH_1,
    parameter WIDTH_HIGH_0   = `PG0_WIDTH_HIGH_0,
    parameter WIDTH_PERIOD_3 = `PG0_WIDTH_PERIOD_3,
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
    output  [`DATA_WIDTH-1:0] o_data,
    // pps input
    input i_pps_raw,
    // thunderbolt time of day
    input i_thunder_packet_dv,
    input [`DATA_WIDTH*2-1:0] i_thunder_year,
    input [`DATA_WIDTH-1:0] i_thunder_month,
    input [`DATA_WIDTH-1:0] i_thunder_day,
    input [`DATA_WIDTH-1:0] i_thunder_hour,
    input [`DATA_WIDTH-1:0] i_thunder_minutes,
    input [`DATA_WIDTH-1:0] i_thunder_seconds,
    // pulse
    output o_pulse_out
);

    wire[`DATA_WIDTH-1:0] w_pulse_enable;
    wire[`DATA_WIDTH-1:0] w_usr_year_h;
    wire[`DATA_WIDTH-1:0] w_usr_year_l;
    wire[`DATA_WIDTH-1:0] w_usr_month;
    wire[`DATA_WIDTH-1:0] w_usr_day;
    wire[`DATA_WIDTH-1:0] w_usr_hour;
    wire[`DATA_WIDTH-1:0] w_usr_minutes;
    wire[`DATA_WIDTH-1:0] w_usr_seconds;
    wire[`DATA_WIDTH-1:0] w_width_high_3;
    wire[`DATA_WIDTH-1:0] w_width_high_2;
    wire[`DATA_WIDTH-1:0] w_width_high_1;
    wire[`DATA_WIDTH-1:0] w_width_high_0;
    wire[`DATA_WIDTH-1:0] w_width_period_3;
    wire[`DATA_WIDTH-1:0] w_width_period_2;
    wire[`DATA_WIDTH-1:0] w_width_period_1;
    wire[`DATA_WIDTH-1:0] w_width_period_0;

    pulse_generator #(
        .CLKS_PER_1_US          (10))
    PG(
        .i_clk                  (i_clk),
        .i_rst                  (i_rst),
        .i_pps_raw              (i_pps_raw),
        .i_pulse_enable         (w_pulse_enable),
        .i_usr_year             ({w_usr_year_h, w_usr_year_l}),
        .i_usr_month            (w_usr_month),
        .i_usr_day              (w_usr_day),
        .i_usr_hour             (w_usr_hour),
        .i_usr_minutes          (w_usr_minutes),
        .i_usr_seconds          (w_usr_seconds),
        .i_width_high           ({w_width_high_3,
                                  w_width_high_2,
                                  w_width_high_1,
                                  w_width_high_0}),
        .i_width_period         ({w_width_period_3,
                                  w_width_period_2,
                                  w_width_period_1,
                                  w_width_period_0}),
        .i_thunder_packet_dv    (i_thunder_packet_dv),
        .i_thunder_year         (i_thunder_year),
        .i_thunder_month        (i_thunder_month),
        .i_thunder_day          (i_thunder_day),
        .i_thunder_hour         (i_thunder_hour),
        .i_thunder_minutes      (i_thunder_minutes),
        .i_thunder_seconds      (i_thunder_seconds),
        .o_pulse_out            (o_pulse_out)
    );

    pulse_generator_registers #(
        .PULSE_ENA          (PULSE_ENA),
        .USR_YEAR_H         (USR_YEAR_H),
        .USR_YEAR_L         (USR_YEAR_L),
        .USR_MONTH          (USR_MONTH),
        .USR_DAY            (USR_DAY),
        .USR_HOUR           (USR_HOUR),
        .USR_MINUTES        (USR_MINUTES),
        .USR_SECONDS        (USR_SECONDS),
        .WIDTH_HIGH_3       (WIDTH_HIGH_3),
        .WIDTH_HIGH_2       (WIDTH_HIGH_2),
        .WIDTH_HIGH_1       (WIDTH_HIGH_1),
        .WIDTH_HIGH_0       (WIDTH_HIGH_0),
        .WIDTH_PERIOD_3     (WIDTH_PERIOD_3),
        .WIDTH_PERIOD_2     (WIDTH_PERIOD_2),
        .WIDTH_PERIOD_1     (WIDTH_PERIOD_1),
        .WIDTH_PERIOD_0     (WIDTH_PERIOD_0))
    PGR(
        .i_clk              (i_clk),
        .i_rst              (i_rst),
        .i_wr               (i_wr),
        .i_addr             (i_addr),
        .i_data             (i_data),
        .o_data             (o_data),
        .o_pulse_enable     (w_pulse_enable),
        .o_usr_year_h       (w_usr_year_h),
        .o_usr_year_l       (w_usr_year_l),
        .o_usr_month        (w_usr_month),
        .o_usr_day          (w_usr_day),
        .o_usr_hour         (w_usr_hour),
        .o_usr_minutes      (w_usr_minutes),
        .o_usr_seconds      (w_usr_seconds),
        .o_width_high_3     (w_width_high_3),
        .o_width_high_2     (w_width_high_2),
        .o_width_high_1     (w_width_high_1),
        .o_width_high_0     (w_width_high_0),
        .o_width_period_3   (w_width_period_3),
        .o_width_period_2   (w_width_period_2),
        .o_width_period_1   (w_width_period_1),
        .o_width_period_0   (w_width_period_0) 
    );

endmodule