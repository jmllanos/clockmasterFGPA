/**********************************************************

file: top.v
author: Eloise Perrochet
description:

This is the top level module for the
 divider and pulse generator project.
This module instantiates and connects the internal Register File, SPI slave
interface, backchannel UART interface, Thunderbolt GPS clock interface,
Pulse generation, and PPS division modules.

Configuration settings for Pulse Generation and PPS Division can be changed
by modifying the contents of the system's internal register file. This can be
done by sending SPI packets with the following packet structure:

        byte 0                      byte 1                     byte 2
|-----------------------|----------------------------|------------------------|
|start byte (0xF0)      | address byte (0x00 - 0x20) |data byte (0x00 - 0xFF) |
|-----------------------|----------------------------|------------------------|

The following shows which addresses of the register file contain which
configuration settings for the system:

  addr      data
|------------------|
| pps divider      |
|------------------|
| 0x00  | per true |
| 0x01  | div num  |
| 0x02  | phase    |
| 0x03  | phase    |
| 0x04  | phase    |
| 0x05  | phase lsb|
| 0x06  | width    |
| 0x07  | start    |
| 0x08  | stop     |
|------------------|
| pulse generator  |
|------------------|
| 0x09  | year     |
| 0x0A  | year lsb |
| 0x0B  | month    |
| 0x0C  | day      |
| 0x0D  | hour     |
| 0x0E  | minutes  |
| 0x0F  | seconds  |
| 0x10  | width    |
| 0x11  | width    |
| 0x12  | width    |
| 0x13  | width lsb|
| 0x14  | pulse en |

added by Arom Miranda
| 0x15| periodic width
| 0x16| periodic width
| 0x17| periodic width
| 0x18| periodic width lsb
|-------|----------|

This system also has a backchannel UART which is useful for
setting up and debugging the system. The backchannel provides
a method for reading the contents of the Register File as well
as the data being read at any time from the Thunderbolt GPS
clock. To read the contents of the register file, send the
byte 0xAB to the backchannel. The UART will then send back the
entire contents of the File in order from lowest to highest
address. Similarly, the byte 0xAC sent to the backchannel will
cause the backchannel to send the last data packet that the
system has received from the Thunderbolt in the byte order
described in the Thunderbolt data sheet.

**********************************************************/
`timescale 1ns / 1ps

// includes for design sub-modules
//`include "components/spi_slave/spi_slave.v"
//`include "components/regfile/regfile.v"
//`include "components/uart/uart_rx.v"
//`include "components/uart/uart_tx.v"
//`include "components/pps_edge_detect/pps_edge_detect.v"
//`include "components/pps_divider/pps_divider.v"
//`include "components/thunderbolt/thunderbolt.v"
//`include "components/pulse_generator/pulse_generator.v"

//includes for design sub-modules

`include "spi_slave.v"
`include "regfile.v"
`include "uart_rx.v"
`include "uart_tx.v"
//`include "pps_edge_detect.v"
`include "pps_divider.v"
`include "thunderbolt.v"
`include "pulse_generator.v"

`include "parpadeoLED.v" //prueba de que funciona


`include "pll16_10.v" //**********************se agrego pll para bajar clock

module top (
			input i_clk_10,//********************se descomenta para usar generador revisar pines igual
			//input CLK, //**************************
			input i_rst,
			// SPI
			input i_sclk,
			input i_ssel,
			input i_mosi,
			output o_miso,
			// user UART
			input i_usr_rx,
			output o_usr_tx,
			// thunderbolt UART
			input i_thunder_rx,
			output o_thunder_tx,
			// pps divider
			input i_pps_raw,
			output o_pps_divided_1,
			// pulse generator
			output o_pulse_generated,

			// led that proves it's working
			output LED

		    );


  //-------------------------------------------------------
		// LED cada 3seg


    parameter div_cantidad = 20000000; //constante
		parpadeoLED #(.div_cantidad(div_cantidad)) ledblink
										(.clock(i_clk_10),
										.blink_led(LED),
										.reset(i_rst),
										.salida_prueba()
										);

					/*
		parameter div_cantidad = 20000000;
		reg [30:0] blink_counter;
		reg r_led;
		always @(posedge i_clk_10)
    begin
          if (blink_counter == div_cantidad-1)
            begin
              blink_counter <= 0;
              r_led = !r_led;
            end
          else
            blink_counter <= blink_counter+1;

    end
    assign LED = r_led;


					*/

	//-------------------------------------------------------

	// ---------------------------------------------------
	// PLL para bajar frecuencia
	// ---------------------------------------------------
/*
	wire i_clk_10;
	pll16_10 pll16_10_inst(.REFERENCECLK(CLK),
                       .PLLOUTCORE(i_clk_10),
                       .PLLOUTGLOBAL(PIN_23),
                       .RESET());


*/
	// ---------------------------------------------------


	// ---------------------------------------------------
	// SPI slave
	// ---------------------------------------------------

	// IOs
	wire w_spi_packet_rec;
	wire [15:0] w_packet_data;

	// module instantiation
	spi_slave SPISLAVE (.i_clk(i_clk_10), .i_rst(i_rst), .i_SCLK(i_sclk),
					 	   .i_SSEL(i_ssel), .i_MOSI(i_mosi),
					 	   .o_MISO(o_miso),
						   .o_packet_received(w_spi_packet_rec),
					 	   .o_packet_data_received(w_packet_data)
						  );
	//assign o_miso=0;


	// ---------------------------------------------------
	// RegFile
	// ---------------------------------------------------

	// IOs
	parameter c_FILE_SIZE_BYTES = 25;
	reg r_write;
	reg [7:0] r_wr_addr;
	reg [7:0] r_wr_byte;
	//reg r_read;
	//reg [7:0] r_rd_addr;
	wire [7:0] w_rd_byte;
	wire [199:0] w_reg_vector;

	// module instantiation
	regfile #(.FILE_SIZE_BYTES(c_FILE_SIZE_BYTES)) FILE
			 (.i_clk(i_clk_10),
			 .i_rst(i_rst),
			 // writing
		     .i_write(r_write),
			 .i_wr_addr(r_wr_addr),
			 .i_wr_byte(r_wr_byte),
			 // reading
			 .i_read(/*r_read*/),
			 .i_rd_addr(/*r_rd_addr*/),
			 .o_rd_byte(/*w_rd_byte*/),
			 // parallel connection to registers that map to pps divider and pulse generator values
			 .o_reg_vector(w_reg_vector)
			);

	// logic to write to the regfile when a SPI packet has been received
	always @ (posedge i_clk_10) begin
		if (w_spi_packet_rec && w_packet_data[15:8] < 8'd25) begin // received a packet and packet has a valid address
			r_wr_byte <= w_packet_data[7:0];  // set data - last byte of packet
			r_wr_addr <= w_packet_data[15:8]; // set address - first byte of packet
			r_write <= 1; // write
		end
		else begin
			r_wr_byte <= 8'dx;
			r_wr_addr <= 8'dx;
			r_write <= 0;
		end
	end

	// local 2d array to provide a parallel connection to the regFile registers
	wire [7:0] w_reg_matrix [0:c_FILE_SIZE_BYTES-1];
	// unpacking the reg vector
	genvar j;
	for (j=0; j<c_FILE_SIZE_BYTES; j=j+1) begin: REG_UNPACK // iterate over every byte in the regFile
		assign w_reg_matrix[j] = w_reg_vector[(j*8)+7:(j*8)];
	end

	// wires to connect registers from the regfile
	// for the pps divider
	wire [7:0] w_periodic_true;
	wire [7:0] w_div_number;
	wire [31:0] w_phase_us;
	wire [7:0] w_width_us;
	wire [7:0] w_start;
	wire [7:0] w_stop;
	assign w_periodic_true = w_reg_matrix[0];
	assign w_div_number = w_reg_matrix[1];
	assign w_phase_us[31:24] = w_reg_matrix[2];
	assign w_phase_us[23:16] = w_reg_matrix[3];
	assign w_phase_us[15:8] = w_reg_matrix[4];
	assign w_phase_us[7:0] = w_reg_matrix[5];
	assign w_width_us = w_reg_matrix[6];
	assign w_start = w_reg_matrix[7];
	assign w_stop = w_reg_matrix[8];
	// for the pulse generator
	wire [15:0] w_usr_year;
	wire [7:0] w_usr_month;
	wire [7:0] w_usr_day;
	wire [7:0] w_usr_hour;
	wire [7:0] w_usr_minutes;
	wire [7:0] w_usr_seconds;
	wire [31:0] w_usr_width;
	wire [7:0] w_pulse_enable;
	wire [32:0] w_periodic_width;

	assign w_usr_year[15:8] = w_reg_matrix[9];
	assign w_usr_year[7:0] = w_reg_matrix[10];
	assign w_usr_month = w_reg_matrix[11];
	assign w_usr_day = w_reg_matrix[12];
	assign w_usr_hour = w_reg_matrix[13];
	assign w_usr_minutes = w_reg_matrix[14];
	assign w_usr_seconds = w_reg_matrix[15];
	assign w_usr_width[31:24] = w_reg_matrix[16];
	assign w_usr_width[23:16] = w_reg_matrix[17];
	assign w_usr_width[15:8] = w_reg_matrix[18];
	assign w_usr_width[7:0] = w_reg_matrix[19];
	assign w_pulse_enable = w_reg_matrix[20];

	//extra
	assign w_periodic_width[31:24] = w_reg_matrix[21];
	assign w_periodic_width[23:16] = w_reg_matrix[22];
	assign w_periodic_width[15:8] = w_reg_matrix[23];
	assign w_periodic_width[7:0] = w_reg_matrix[24];
	//--------------------------------
	// Thunderbolt Communication
	//--------------------------------

	// IOs
	wire w_thunder_packet_dv;
	//wire [0:167] w_thunder_data; //**********AROM
	wire [135:0] w_thunder_data;
	
	//assign w_thunder_matrix[16] =
	// wires to provide a parallel connection to the thunderbolt packet data bytes
	wire [7:0]	w_thunder_year_h;
	wire [7:0]	w_thunder_year_l;
	wire [7:0]	w_thunder_month;
	wire [7:0]	w_thunder_day;
	wire [7:0]	w_thunder_hour;
	wire [7:0]	w_thunder_minutes;
	wire [7:0]	w_thunder_seconds;
	
	// module instantiation
	thunderbolt THUBLT (.i_clk					(i_clk_10),
						.i_rst					(i_rst),
						.i_rx_thunder			(i_thunder_rx),
						.o_tx_thunder			(o_thunder_tx),
						.o_thunder_packet_dv	(w_thunder_packet_dv),
						.o_thunder_year_h		(w_thunder_year_h),
						.o_thunder_year_l		(w_thunder_year_l),
						.o_thunder_month		(w_thunder_month),
						.o_thunder_day			(w_thunder_day),
						.o_thunder_hour			(w_thunder_hour),
						.o_thunder_minutes		(w_thunder_minutes),
						.o_thunder_seconds		(w_thunder_seconds)
					);

	//--------------------------------
	// Pulse generator
	//--------------------------------

	// module instantiation
	pulse_generator PULSEGEN (.i_clk				(i_clk_10),
							  .i_rst				(i_rst),
							  .i_pulse_enable		(w_pulse_enable),
							  // from user
							  .i_usr_year			(w_usr_year),
							  .i_usr_month			(w_usr_month),
					          .i_usr_day			(w_usr_day),
							  .i_usr_hour			(w_usr_hour),
							  .i_usr_minutes		(w_usr_minutes),
							  .i_usr_seconds		(w_usr_seconds),
							  .i_usr_width_us		(w_usr_width),
								.i_periodic_width	(w_periodic_width),
							  // from thunderbolt
							  .i_thunder_packet_dv	(w_thunder_packet_dv),
							  .i_thunder_year		({w_thunder_year_h, w_thunder_year_l}),
							  .i_thunder_month		(w_thunder_month),
							  .i_thunder_day		(w_thunder_day),
							  .i_thunder_hour		(w_thunder_hour),
							  .i_thunder_minutes	(w_thunder_minutes),
							  .i_thunder_seconds	(w_thunder_seconds),
							  // pulse output
							  .o_pulse_out			(o_pulse_generated)
							 );

	// ---------------------------------------------------
	// PPS divider
	// ---------------------------------------------------

	/*
	// --- REMOVE FOR HARDWARE -------
	// normally pps signal is coming from the thunderbolt.
	// for testing purposes I am creating a pps signal based on the
	// internal 10 MHz clock instead
	parameter PPS_PERIOD = 10000; // for simulation because 1 s period takes too long to load
	// parameter PPS_PERIOD = 10000000; // 1 Hz
	reg i_pps_raw_TESTING;
	reg [63:0] counter;
	always @(posedge i_clk_10) begin
		if (i_rst) begin
			counter <= 64'd0;
		end
		else begin
			if (counter < PPS_PERIOD) begin
				counter <= counter + 1;
				i_pps_raw_TESTING <= 0;
			end
			else begin
				counter <= 64'd0;
				i_pps_raw_TESTING <= 1;
			end
		end
	end
	// ---------------------
	*/

	// module instantiation
	pps_divider PPSDIV (.i_clk_10(i_clk_10),
						.i_rst(i_rst),
						.i_pps_raw(i_pps_raw),
				        .i_periodic_true(w_periodic_true),
						.i_div_number(w_div_number),
						.i_phase_us(w_phase_us),
					 	.i_width_us(w_width_us),
					 	.i_start(w_start),
					 	.i_stop(w_stop),
					 	.o_pps_divided(o_pps_divided_1)
				   	    );

endmodule
