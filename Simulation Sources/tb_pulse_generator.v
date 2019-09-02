/*********************************************************************

file: tb_pulse_generator.v
author: Victor Vasquez
description:

**********************************************************************/
`timescale 1ns / 1ns

module tb_pulse_generator();

   // DUT inputs
   reg r_clk;
   reg r_rst;
   reg [7:0] r_pulse_enable;
   reg r_pps_raw;
   // user config
   reg [15:0] r_usr_year; // four digits of year
   reg [7:0] r_usr_month; // month of the year (0-12)
   reg [7:0] r_usr_day; // day of month (1-31)
   reg [7:0] r_usr_hour; // hours (0-23)
   reg [7:0] r_usr_minutes; // minutes (0-59)
   reg [7:0] r_usr_seconds; // seconcds (0-59)
   reg [31:0] r_width_high; // microsecond width of the pulse
   reg [31:0] r_width_period; //period of pulse
   // thunderbolt
   reg r_thunder_packet_dv; // thunderbolt data valid flag (only one cycle)
   reg [15:0] r_thunder_year;
   reg [7:0] r_thunder_month;
   reg [7:0] r_thunder_day;
   reg [7:0] r_thunder_hour;
   reg [7:0] r_thunder_minutes;
   reg [7:0] r_thunder_seconds;
   // DUT outputs
   // pulse
   wire w_pulse_out;

    pulse_generator #(
        .CLKS_PER_1_US       (10))
    DUT (
        .i_clk               (r_clk),
        .i_rst               (r_rst),
        .i_pulse_enable      (r_pulse_enable),
        .i_pps_raw           (r_pps_raw),
        .i_usr_year          (r_usr_year),
        .i_usr_month         (r_usr_month),
        .i_usr_day           (r_usr_day),
        .i_usr_hour          (r_usr_hour),
        .i_usr_minutes       (r_usr_minutes),
        .i_usr_seconds       (r_usr_seconds),
        .i_width_high        (r_width_high),
        .i_width_period         (r_width_period),
        .i_thunder_packet_dv (r_thunder_packet_dv),
        .i_thunder_year      (r_thunder_year),
        .i_thunder_month     (r_thunder_month),
        .i_thunder_day       (r_thunder_day),
        .i_thunder_hour      (r_thunder_hour),
        .i_thunder_minutes   (r_thunder_minutes),
        .i_thunder_seconds   (r_thunder_seconds),
        .o_pulse_out         (w_pulse_out)
   );

   //--------------------------------
	// waveform file generation 
	//--------------------------------
	initial begin
		$dumpfile ("wave_thunder.vcd");
		$dumpvars;
	end

	//--------------------------------
	// Clock generation
	//--------------------------------
   always #50 r_clk = ~r_clk;
   
	//--------------------------------
	// stimulus generation
	//--------------------------------
   initial begin
      r_rst = 1;
      #10
      r_clk = 0;
      r_rst = 0;
      r_usr_year        = 16'd2020;
      r_usr_month       = 8'd7;
      r_usr_day         = 8'd15;
      r_usr_hour        = 8'd11;
      r_usr_minutes     = 8'd55;
      r_usr_seconds     = 8'd30;
      r_width_high      = 32'd2;
      r_width_period       = 33'd8; //period of pulse
      r_pulse_enable    = 1;
      r_thunder_packet_dv = 0;
      #500000 $finish;
   end

    initial begin
        r_pps_raw   = 0;
        #13333;
        forever begin
            r_pps_raw   = 1;
            #200
            r_pps_raw   = 0;
            #99800;
        end
    end
    
   initial begin
      r_thunder_year        = 16'd0;
      r_thunder_month       = 8'd0;
      r_thunder_day         = 8'd0;
      r_thunder_hour        = 8'd0;
      r_thunder_minutes     = 8'd0;
      r_thunder_seconds     = 8'd0;
      #20000// previously transcurred 800
      r_thunder_year        = 16'd2020;
      r_thunder_month       = 8'd7;
      r_thunder_day         = 8'd15;
      r_thunder_hour        = 8'd11;
      r_thunder_minutes     = 8'd55;
      r_thunder_seconds     = 8'd28;
      r_thunder_packet_dv   = 1;
      #100//..............
      r_thunder_packet_dv   = 0;
      //
      //#100000
      #99900
      r_thunder_seconds     = 8'd29;
      r_thunder_packet_dv   = 1;
      #100//..........................
      r_thunder_packet_dv   = 0;
      //
      //#100000
      #99900
      r_thunder_seconds     = 8'd30;
      r_thunder_packet_dv   = 1;
      #100//.............
      r_thunder_packet_dv   = 0;
      //
      //#100000
      #99900
      r_thunder_seconds     = 8'd31;
      r_thunder_packet_dv   = 1;
      #100//.................
      r_thunder_packet_dv   = 0;
   end
   
endmodule
