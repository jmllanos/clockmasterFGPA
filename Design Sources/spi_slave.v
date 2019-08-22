/*********************************************************************

file: spi_slave.v
author: Eloise Perrochet
description: slave module for SPI interface

signals:
i_SCLK: serial clock
i_MOSI: master out slave in
o_MISO: master in slave out
i_SSEL: slave select

protocol:
Endianness: MSB
Pull down i_SSEL during all transmission

------------            ----------
|          |--i_SCLK-->|	     |
|   MCU    |--i_MOSI-->|  FPGA   |
| (master) |<--o_MISO--| (slave) |
|          |--i_SSEL-->|         |
------------           -----------

NOTE: currently the MISO line is tied to ground. The slave is only
receiving data from the master over SPI and is doing all transmission over UART.
The SPI transmission logic is commented out below. It can be implemented
in the future for this project.

NOTE: Much of this SPI logic was created based on code from:
https://www.fpga4fun.com/SPI3.html

**********************************************************************/

module spi_slave(input i_clk, // fpga clock (for over-sampling the SPI bus)
				 input i_rst, // reset
				 input i_SCLK, // slave clock from master
				 input i_SSEL, // slave select
				 // slave receive
				 input i_MOSI, // master out slave in
				 // slave transmit
				 output o_MISO, // master in slave out
				 // output packet info
				 output reg o_packet_received,
				 output reg [15:0] o_packet_data_received
				);

	//--------------------------------------------------------------------------------------------------
	// sample/synchronize the SPI signals (i_SCLK, i_SSEL and i_MOSI) using the FPGA clock and shift registers.
	//--------------------------------------------------------------------------------------------------

	// sync i_SCLK to the FPGA clock using a 3-bits shift register
	reg [2:0] r_SCLK;

	always @(posedge i_clk)
	begin
		r_SCLK <= {r_SCLK[1:0], i_SCLK};
	end

	wire w_SCLK_risingedge;
	//wire w_SCLK_fallingedge;

	assign w_SCLK_risingedge = (r_SCLK[2:1]==2'b01);  // now we can detect i_SCLK rising edges
	//assign w_SCLK_fallingedge = (r_SCLK[2:1]==2'b10);  // and falling edges

	// same thing for i_SSEL
	reg [2:0] r_SSEL;

	always @(posedge i_clk)
	begin
		r_SSEL <= {r_SSEL[1:0], i_SSEL};
	end

	wire w_SSEL_active;
	//wire w_SSEL_startmessage;
	//wire w_SSEL_endmessage;

	assign w_SSEL_active = ~r_SSEL[1];  // i_SSEL is active low
	//assign w_SSEL_startmessage = (r_SSEL[2:1]==2'b10);  // message starts at falling edge
	//assign w_SSEL_endmessage = (r_SSEL[2:1]==2'b01);  // message stops at rising edge

	// and for MOSI
	reg [1:0] r_MOSI;
	always @(posedge i_clk)
	begin
		r_MOSI <= {r_MOSI[0], i_MOSI};
	end

	wire w_MOSI_data;
	assign w_MOSI_data = r_MOSI[1];

	//--------------------------------------------------------------------------------------------------
	// receiving data from the SPI bus
	//--------------------------------------------------------------------------------------------------

	// we handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
	reg [2:0] r_bitcnt;

	reg r_byte_received;  // high when a byte has been received
	reg [7:0] r_byte_data_received;

	always @(posedge i_clk)
	begin
		if(~w_SSEL_active)
	    	r_bitcnt <= 3'b000;
	  	else if(w_SCLK_risingedge)
	  	begin
	  		r_bitcnt <= r_bitcnt + 3'b001;
			// implement a shift-left register (since we receive the data MSB first)
	   		r_byte_data_received <= {r_byte_data_received[6:0], w_MOSI_data};
	  	end
	end

	always @(posedge i_clk)
	begin
		r_byte_received <= w_SSEL_active && w_SCLK_risingedge && (r_bitcnt==3'b111);
	end

	//--------------------------------------------------------------------------------------------------
	// SPI packet filling
	//--------------------------------------------------------------------------------------------------

	// packet structure: | start byte | address byte | data byte |

	parameter c_START_BYTE = 8'hF0;
	// NOTE: two start bytes transmitted in a row will be detected as an invalid sequence

	reg [7:0] r_prev_byte;
	reg [7:0] r_prev_prev_byte;
	reg [7:0] r_prev_prev_prev_byte;
	reg [7:0] r_addr_buffer;
	always @ (posedge i_clk) begin
		if (i_rst) begin
			r_addr_buffer <= 8'dx;
			o_packet_received <= 1'd0;
			o_packet_data_received <= 16'dx;
		end
		else begin
			o_packet_received <= 0;
			o_packet_data_received <= 16'dx;
			if(r_byte_received) begin
				r_prev_byte <= r_byte_data_received;
				r_prev_prev_byte <= r_prev_byte;
				r_prev_prev_prev_byte <= r_prev_prev_byte;
				if (r_byte_data_received == c_START_BYTE && r_prev_byte == c_START_BYTE) begin // invalid sequence
					//; // do nothing
				end
				else if (r_prev_byte == c_START_BYTE) begin // current byte is an address byte
					r_addr_buffer <= r_byte_data_received; // set address byte
				end
				else if (r_prev_prev_byte == c_START_BYTE) begin // current byte is a data byte
					o_packet_received <= 1; // hold packet received high for one clock cycle
					o_packet_data_received <= {r_addr_buffer, r_byte_data_received}; // set the output packet
				end
				else begin // some other random byte was received
					//; // do nothing
				end
			end
		end
	end

	//--------------------------------------------------------------------------------------------------
	// transmission part
	//--------------------------------------------------------------------------------------------------

	assign o_MISO = 0; // temporarily tie MISO to ground
/*
	reg [7:0] r_byte_data_sent;

	reg [7:0] r_cnt;

	always @(posedge i_clk)
	begin
		if(w_SSEL_startmessage) r_cnt<=r_cnt+8'h1;  // count the messages
	end

	always @(posedge i_clk)
	begin
		if(w_SSEL_active)
		begin
			if(w_SSEL_startmessage)
			begin
		    	r_byte_data_sent <= r_cnt;  // first byte sent in a message is the message count
			end
		  	else if(w_SCLK_fallingedge)
		   begin
		    	if(r_bitcnt==3'b000)
				begin
		      		r_byte_data_sent <= 8'h00;  // after that, we send 0s
				end
		    	else
				begin
		      		r_byte_data_sent <= {r_byte_data_sent[6:0], 1'b0};
				end
		  	end
		end
	end

	assign o_MISO = r_byte_data_sent[7];  // send MSB first
	// we assume that there is only one slave on the SPI bus
	// so we don't bother with a tri-state buffer for o_MISO
	// otherwise we would need to tri-state o_MISO when i_SSEL is inactive
*/

endmodule
