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
| 0x08  | stop 	   |
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

added by Juan Llanos
| 0x19| Channel selector
 
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

//`include "spi_slave.v"
//`include "regfile.v"
//`include "uart_rx.v"
//`include "uart_tx.v"
//`include "pps_edge_detect.v"
//`include "pps_divider.v"
//`include "thunderbolt.v"
//`include "pulse_generator.v"

//`include "parpadeoLED.v" //prueba de que funciona


//`include "pll16_10.v" //**********************se agrego pll para bajar clock



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
		parpadeoLED #(.div_cantidad(div_cantidad)) 
		                  ledblink (.clock(i_clk_10),
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
	spi_slave SPISLAVE (   .i_clk(i_clk_10), 
	                       .i_rst(i_rst), 
	                       .i_SCLK(i_sclk),
					 	   .i_SSEL(i_ssel), 
					 	   .i_MOSI(i_mosi),
					 	   .o_MISO(o_miso),
						   .o_packet_received(w_spi_packet_rec),
					 	   .o_packet_data_received(w_packet_data)
						  );


	//assign o_miso=0;



	// ---------------------------------------------------
	// RegFile
	// ---------------------------------------------------

	// IOs
	parameter c_FILE_SIZE_BYTES = 26;
	wire r_write;
	wire [7:0] r_wr_addr;
	wire [7:0] r_wr_byte;
	//reg r_read;
	//reg [7:0] r_rd_addr;
	wire [7:0] w_rd_byte;
	wire [c_FILE_SIZE_BYTES*8-1:0] w_reg_vector;

	// module instantiation
	regfile #(.FILE_SIZE_BYTES(c_FILE_SIZE_BYTES))
       FILE (.i_clk(i_clk_10),
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
regfile_control  #(.FILE_SIZE_BYTES(26))
     file_control(
            .i_clk_10(i_clk_10),
            .w_spi_packet_rec(w_spi_packet_rec),
            .w_packet_data(w_packet_data),
            .r_wr_byte(r_wr_byte),
            .r_wr_addr(r_wr_addr),
            .r_write(r_write)
    );


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


	// Thunderbolt Communication
	//--------------------------------
	

	// IOs
	wire w_thunder_packet_dv;
	//wire [0:167] w_thunder_data; //**********AROM
	wire [135:0] w_thunder_data;
	// module instantiation
	thunderbolt THUBLT (.i_clk(i_clk_10),
                        .i_rst(i_rst),
					    .i_rx_thunder(i_thunder_rx),
					    .o_tx_thunder(o_thunder_tx),
					    .o_thunder_packet_dv(w_thunder_packet_dv),
					    .o_thunder_data(w_thunder_data)
					);

	// local 2d array to unpack the thunderbolt data
//	parameter c_TIM_PACKET_SIZE = 21; //*************AROM
	parameter c_TIM_PACKET_SIZE = 17;
	wire [7:0] w_thunder_matrix [0:c_TIM_PACKET_SIZE-1]; // matrix to hold the timing packet bytes
	// unpacking the packet

	genvar k;
	for (k=0; k<c_TIM_PACKET_SIZE; k=k+1) begin: THUNDER_UNPACK // iterate over the last 7 bytes in the packet starting at 10
		assign w_thunder_matrix[k] = w_thunder_data[(k*8)+7:(k*8)];
	end

	//assign w_thunder_matrix[16] =
	// wires to provide a parallel connection to the thunderbolt packet data bytes
	wire [15:0] w_thunder_year;
	wire [7:0] w_thunder_month;
	wire [7:0] w_thunder_day;
	wire [7:0] w_thunder_hour;
	wire [7:0] w_thunder_minutes;
	wire [7:0] w_thunder_seconds;

	assign w_thunder_year[7:0] = w_thunder_matrix[16];
    assign w_thunder_year[15:8] = w_thunder_matrix[15];
    assign w_thunder_month = w_thunder_matrix[14];
    assign w_thunder_day = w_thunder_matrix[13];
    assign w_thunder_hour = w_thunder_matrix[12];
    assign w_thunder_minutes = w_thunder_matrix[11];
    assign w_thunder_seconds = w_thunder_matrix[10];


	//--------------------------------
	// Pulse generator
	//--------------------------------
    wire pulse_generated;
	// module instantiation
	pulse_generator PULSEGEN (.i_clk(i_clk_10),
							  .i_rst(i_rst),
							  .i_pulse_enable(w_pulse_enable),
							  // from user
							  .i_usr_year(w_usr_year),
							  .i_usr_month(w_usr_month),
					          .i_usr_day(w_usr_day),
							  .i_usr_hour(w_usr_hour),
							  .i_usr_minutes(w_usr_minutes),
							  .i_usr_seconds(w_usr_seconds),
							  .i_usr_width_us(w_usr_width),
		     					.i_periodic_width(w_periodic_width),
							  // from thunderbolt
							  .i_thunder_packet_dv(w_thunder_packet_dv),
							  .i_thunder_year(w_thunder_year),
							  .i_thunder_month(w_thunder_month),
							  .i_thunder_day(w_thunder_day),
							  .i_thunder_hour(w_thunder_hour),
							  .i_thunder_minutes(w_thunder_minutes),
							  .i_thunder_seconds(w_thunder_seconds),
							  // pulse output
							  .o_pulse_out(o_pulse_generated)
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
	wire pps_divided_1;
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

	// ---------------------------------------------------
	// Backchannel UART
	// ---------------------------------------------------

	parameter c_CLKS_PER_BIT = 1042; // 10*10^6 / 9600 = 1042

	// ------------------------------------------------------------------------------------------
	// ---------------------------------https://stackoverflow.com/questions/34239645/adding-header-files-in-verilog---------------------------------------------------------
	// -------------REMEMBER TO REMOVE FOR HARDWARE HERE AND IN THUNDERBOLT MODULE---------------
	// ------------------------------------------------------------------------------------------
	// this is just to make the uart faster for simulation purposes
	//parameter c_CLKS_PER_BIT = 87;
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------

	// receiver module instantiation
	wire w_rx_dv;
	wire [7:0] w_rx_byte;
	uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT))
        receiver (.i_Clock(i_clk_10),
                  .i_Rx_Serial(i_usr_rx),
                  .o_Rx_DV(w_rx_dv),
                  .o_Rx_Byte(w_rx_byte)
                 );

	// transmitter module instantiation
	wire r_tx_dv;
	wire [7:0] r_tx_byte;
	wire w_tx_active;
	wire w_tx_done;
	uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) 
	 transmitter (.i_Clock(i_clk_10),
                  .i_Tx_DV(r_tx_dv),
                  .i_Tx_Byte(r_tx_byte),
                  .o_Tx_Serial(o_usr_tx),
                  .o_Tx_Active(w_tx_active),
                  .o_Tx_Done(w_tx_done)
                 );

	// logic to send the contents of the reg file over the serial transmitter
	parameter c_CMD_SEND_REG = 8'hAB;
	parameter c_CMD_SEND_THUNDER = 8'hAC;
	parameter c_CMD_EASTER_EGG = 8'hEE;
	reg [4:0] r_index = 0; // the index of the byte that is being sent
	reg r_send_regfile = 0; // flag to trigger sending of the regfile over the uart
	reg r_send_thunder = 0; // flag to trigger sending of the thunderbolt data over the uart
	reg r_send_easter = 0;
	wire [7:0] easter [0:1];
	assign easter[0] = 8'hCA;
	assign easter[1] = 8'hFE;
	

transmision_control trans_control (.i_clk_10(i_clk_10),
                    .i_rst(i_rst),
                    .r_tx_dv(r_tx_dv),
                    .r_tx_byte(r_tx_byte),
                    .w_tx_done(w_tx_done),
                    .w_rx_byte(w_rx_byte),
                    .w_rx_dv(w_rx_dv),
                    .w_reg_vector(w_reg_vector),
                    .w_thunder_data(w_thunder_data)
);
	

endmodule
