/*********************************************************************

file: thunderbolt.v
author: Eloise Perrochet
description:

This module interfaces with the Thunderbolt GPS clock with UART and performs the following tasks -
1. configure the thunderbolt to output UTC time by sending the 8E-A2 packet: (DLE, x"8E", x"A2", x"01", DLE, ETX)
2. configure the thunderbolt to only output the AB byte by sending the 8E-A5 packet: (DLE, x"8E", x"A5", x"00", x"01", x"00", x"00", DLE, ETX);
3. continuously read from the thunderbolt to receive the 8F-AB timing packet once per second

**********************************************************************/

/*********************************************************************
file: thunderbol.v (version 2.0)
author: Arom Miranda
description:
-To send the initial packets to the ThunderB GPS the sequence of bytes are saved in a multiplexor and not in matrix registors
-An Algorithmic State Machine  (ASM) has been programmed instead of the old process for sending the initial packets (functioning ok)

Suggestions: Another ASM should be programmed for receiving the UTC, though the old process described in Loise version seems to work.

**********************************************************************/

/*********************************************************************
file: thunderbol.v (version 2.1)
author: Victor Vasquez
description:
- 'output reg [135:0] o_thunder_data' replaced by vectors of 8-bits representing time of day,
  these will go to pulse_generator blocks and to a register map
**********************************************************************/

	module thunderbolt (input i_clk,
						input i_rst,
						// rs232 connection
						input i_rx_thunder,  // serial from thunderbolt
						output o_tx_thunder, // serial to thunderbolt
						//output o_thunder_packet_dv, // flag to indicate that thunder packet data is valid
						output reg o_thunder_packet_dv,
						// data that contains contents of thunderbolt packet
						output reg   [7:0] o_thunder_year_h,
						output reg   [7:0] o_thunder_year_l,
						output reg   [7:0] o_thunder_month,
						output reg   [7:0] o_thunder_day,
						output reg   [7:0] o_thunder_hour,
						output reg   [7:0] o_thunder_minutes,
						output reg   [7:0] o_thunder_seconds
					   );

		// ---------------------------------------------------
		// sending thunderbolt configuration packets
		// ---------------------------------------------------

		// TSIP constants
		parameter c_DLE = 8'h10;
		parameter c_CMD_ID = 8'h8E;
		parameter c_ETX = 8'h03;



	reg [7:0] r_utc_cmd_packet [0:5]; // the 0x8E-A2 utc/gps timing config packet
	always @ ( * ) begin
	r_utc_cmd_packet[0] = c_DLE;
	r_utc_cmd_packet[1] = c_CMD_ID;
	r_utc_cmd_packet[2] = 8'hA2;
	r_utc_cmd_packet[3] = 8'h01;
	r_utc_cmd_packet[4] = c_DLE;
	r_utc_cmd_packet[5] = c_ETX;

	end


	reg [7:0] r_broadcast_cmd_packet [0:8]; // the 0x8E-A5 broadcast map config packet (should respond with 8F-A5)
	always @ ( * ) begin
		r_broadcast_cmd_packet[0] = c_DLE;
		r_broadcast_cmd_packet[1] = c_CMD_ID;
		r_broadcast_cmd_packet[2] = 8'hA5;
		r_broadcast_cmd_packet[3] = 8'h00;
		r_broadcast_cmd_packet[4] = 8'h01;
		r_broadcast_cmd_packet[5] = 8'h00;
		r_broadcast_cmd_packet[6] = 8'h00;
		r_broadcast_cmd_packet[7] = c_DLE;
		r_broadcast_cmd_packet[8] = c_ETX;
	end

	reg r_packet1_sent = 0; // flag to show that the first config packet has been sent
	reg r_packet2_sent = 0; // flag to show that the second config packet has been sent
	//reg [3:0] sent_index = 4'd0; // the index of the byte in the packet that is being sent

	//reg [6:0] sent_index = 6'b000000; // *******************************************************
	reg [8:0] sent_index=0;

	reg [7:0] r_utc_broadcast_cmd;
	always @ ( * ) begin
		case (sent_index)
			//8'd0: r_utc_broadcast_cmd<= c_DLE;
			8'd0: r_utc_broadcast_cmd<= c_CMD_ID;
			8'd1: r_utc_broadcast_cmd<= 8'hA2;
			8'd2: r_utc_broadcast_cmd<= 8'h01;
			8'd3: r_utc_broadcast_cmd<= c_DLE;
			8'd4: r_utc_broadcast_cmd<= c_ETX;
			8'd5: r_utc_broadcast_cmd<= c_DLE;
			8'd6: r_utc_broadcast_cmd<= c_CMD_ID;
			8'd7: r_utc_broadcast_cmd<= 8'hA5;
			8'd8: r_utc_broadcast_cmd<= 8'h00;
			8'd9: r_utc_broadcast_cmd<= 8'h01;
			8'd10: r_utc_broadcast_cmd<= 8'h00;
			8'd11: r_utc_broadcast_cmd<= 8'h00;
			8'd12: r_utc_broadcast_cmd<= c_DLE;
			8'd13: r_utc_broadcast_cmd<= c_ETX;
			default: r_utc_broadcast_cmd<=c_DLE;
		endcase

	end

	/*



	SE AGREGO LO DEL ULTIMO


	*/

	// ---------------------------------------------------
	// uart transmitter and receiver instantiation
	// ---------------------------------------------------

	parameter c_CLKS_PER_BIT = 1042; // 10*10^6 / 9600 = 1042

	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// -------------REMEMBER TO REMOVE FOR HARDWARE HERE AND IN  TB------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// this is just to make the uart faster for simulation purposes
	//parameter c_CLKS_PER_BIT = 87;
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------
	// ------------------------------------------------------------------------------------------


	wire [7:0] w_rx_byte;
	wire w_rx_dv; //*******************************************************************

	// receiver
	uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) receiver
			 (.i_Clock(i_clk),
			  .i_Rx_Serial(i_rx_thunder),
			  .o_Rx_DV(w_rx_dv),
		      .o_Rx_Byte(w_rx_byte)
			 );

	// transmitter
	reg r_tx_dv = 0;
	reg [7:0] r_tx_byte = 8'dx;
	wire w_tx_done;
	wire w_tx_active;

	uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) transmitter
			 (.i_Clock(i_clk),
			  .i_Tx_DV(r_tx_dv),
			  .i_Tx_Byte(r_tx_byte),
		      .o_Tx_Serial(o_tx_thunder),
		      .o_Tx_Active(w_tx_active),
			  .o_Tx_Done(w_tx_done)
			 );

//********************************************************



//********************************************************
//-- fsm state
reg [2:0] state;
reg [2:0] next_state;

localparam PRE_INI = 0;
localparam INI = 1;
localparam TXCAR = 2;
localparam NEXTCAR = 3;
localparam STOP = 4;

reg cena;                //-- Counter enable

always @(posedge i_clk)begin
  if (i_rst)
    sent_index = 0;
  else if (cena) begin
    sent_index = sent_index + 1;
		r_tx_byte <= r_utc_broadcast_cmd;
	end
end

//-- Transition between states
always @(posedge i_clk) begin
	if (i_rst)
		state <= PRE_INI;
	else
		state <= next_state;
end



//-- Control signal generation and next states ASM for transmitting packets
always @(*) begin
  next_state = state;
  r_tx_dv = 0;
  cena = 0;

  case (state)
    //-- Initial state. Start the trasmission
		PRE_INI: begin
			r_tx_dv = 0;
			r_packet1_sent = 0;
			r_packet2_sent = 0;
			if ((!r_packet1_sent) || (!r_packet2_sent)) begin
				next_state = INI;
			end
		end
    INI: begin
   	  //sent_index = 0;
      r_tx_dv = 1;
      next_state = TXCAR;
    end

    //-- Wait until one car is transmitted
    TXCAR: begin
      if (w_tx_done)
        next_state = NEXTCAR;
    end

    //-- Increment the character counter
    //-- Finish when it is the last character
    NEXTCAR: begin
      cena = 1;
      if (sent_index ==14)
        next_state = STOP;
      else
        next_state = INI;
    end
		STOP: begin
		r_packet1_sent = 1;
		r_packet2_sent = 1;

		r_tx_dv = 0;
		end
  endcase
end



/*************************************************
always @ (posedge i_clk, posedge i_rst) begin
	if (i_rst) begin
		r_packet1_sent <= 0;
		r_packet2_sent <= 0;
		sent_index <= 0;
		r_tx_dv <= 0;
	end
	else begin
		if ((!r_packet1_sent) || (!r_packet1_sent)) begin
				r_tx_dv <=1;
				r_tx_byte<=r_utc_broadcast_cmd[sent_index];
				if(sent_index<15)begin
						if(w_tx_done) begin
							sent_index <=sent_index+1;
						end

				end
				else begin
					r_packet1_sent <= 1;
					r_packet2_sent <= 1;
					sent_index <= 0;
					r_tx_dv <= 0;
				end
		end
	end

end
*/

/*
	always @ (posedge i_clk,posedge i_rst) begin
		if (i_rst) begin
			r_packet1_sent <= 0;
			r_packet2_sent <= 0;
			sent_index <= 0;
			r_tx_dv <= 0;w_reg_matrix

		end
		// send two command packets as soon as system is taken out of reset
		else begin

			if (!r_packet1_sent) begin // packet 1 has not been sent
				r_tx_dv <= 1; // continuously transmit bytes
				r_tx_byte <= r_utc_cmd_packet[sent_index];
				if(sent_index < 6) begin

					if(w_tx_done)begin
						sent_index <= sent_index + 1; // increment the index
					end
				end
				else begin
					r_packet1_sent <= 1;
					r_tx_dv <= 0; // stop transmission
					sent_index <= 0; // reset the index
				end
			end

			else if (!r_packet2_sent) begin // same logic for the second command packet
				r_tx_dv <= 1; // continuously transmit bytes
				r_tx_byte <= r_broadcast_cmd_packet[sent_index];
				if(sent_index < 9) begin
					if(w_tx_done)begin
						sent_index <= sent_index + 1; // increment the index
					end
				end
				else begin
					r_tx_byte <= 8'dx;
					r_packet2_sent <= 1;
					r_tx_dv <= 0; // stop transmission
					sent_index <= 0; // reset the index
				end
			end
		end
	end

*/
	// ---------------------------------------------------
	// receiving a thunderbolt timing packet
	// ---------------------------------------------------


	//********************************************************
	//-- asm state
	reg [2:0] state_rx;
	reg [2:0] next_state_rx;

	localparam PRE_INI_RX = 0;
	localparam INI_RX = 1;
	localparam RXCAR = 2;
	localparam NEXT_RXCAR = 3;
	localparam STOP_RX = 4;

	reg [7:0] cena_rx;                //-- Counter enable rx
	reg r_thunder_packet_dv;
	reg r_thunder_packet_dv_next;

	reg [0:167]r_thunder_data;
	reg [0:167]r_thunder_data_next;
	reg [7:0] prueba;

	parameter c_TIM_ID = 8'h8F;
	parameter c_TIM_SUBCODE = 8'hAB;
	parameter c_TIM_PACKET_SIZE = 21;

	reg [7:0] r_prev_rx_byte; // previous data byte received

	reg [7:0] r_byte_vector [c_TIM_PACKET_SIZE-1:0]; // timing packet byte vector
	reg [7:0] r_byte_vector_next [c_TIM_PACKET_SIZE-1:0]; // timing packet byte vector

	reg [7:0] r_rec_index; // position of byte inside incoming packet
	reg [7:0] r_rec_index_next;
	reg r_stuffing_flag = 0; // for accounting for stuffing bytes
	reg r_receiving_flag = 0;

	// TODO check parallel if blocks potential issues
/*
	//-- Transition between states for receiving
	always @(posedge i_clk) begin
		if (i_rst) begin
			state_rx <= PRE_INI_RX;
			r_rec_index<=0;
			r_thunder_packet_dv <=0;
			r_thunder_data <= 0;
		end
		else begin
			state_rx <= next_state_rx;
			r_rec_index <= r_rec_index_next;
			r_thunder_packet_dv <= r_thunder_packet_dv_next;
			r_thunder_data <=r_thunder_data_next;
			//r_byte_vector[c_TIM_PACKET_SIZE-1:0] <= r_byte_vector_next[c_TIM_PACKET_SIZE-1:0];
		end
	end

	always @(*) begin
		next_state_rx = state_rx;
		r_rec_index_next =r_rec_index;
		r_thunder_packet_dv_next = r_thunder_packet_dv;
		r_thunder_data_next = r_thunder_data;
		//r_byte_vector_next = r_byte_vector;

		cena_rx = 0;

		case(state_rx)
			PRE_INI_RX: begin
				//r_rec_index = 0;
				r_prev_rx_byte = 8'dx;
				r_thunder_packet_dv_next = 0;
				r_rec_index_next =0;

				if ( !r_packet1_sent || !r_packet2_sent) begin
					next_state_rx = INI;
				end
			end
			INI_RX: begin
				if (w_rx_dv) begin
					next_state_rx = RXCAR;
				end
				else next_state_rx = INI_RX;
			end

			RXCAR: begin
				cena_rx = 1;

				if (r_rec_index_next == 168) begin //if received 21 packets end
						next_state_rx = STOP_RX;
				end
				else begin
						r_thunder_data_next[r_rec_index+:8]= w_rx_byte;
						r_rec_index_next = r_rec_index+8;
						next_state_rx = INI_RX;

				end
			end

			STOP_RX: begin
					r_thunder_packet_dv_next = 1;
					/*r_thunder_data_next [0:167] = {8'h44, 8'h00, 8'hBB,
							 8'h5, 8'hC0, 8'h30,
							 8'hA5, 8'hBB, 8'hE8,
							 8'h2F, 8'h04, 8'h03,
							 8'hF5, 8'h14, 8'h23,
							 8'h85, 8'h74, 8'h01,
						8'hFF, 8'hEE, 8'hCC };
					next_state_rx = PRE_INI_RX;

					/*

					o_thunder_data = {r_byte_vector[18], r_byte_vector[17], r_byte_vector[16],
										 r_byte_vector[15], r_byte_vector[14], r_byte_vector[13],
										 r_byte_vector[12], r_byte_vector[11], r_byte_vector[10],
										 r_byte_vector[9], r_byte_vector[8], r_byte_vector[7],
										 r_byte_vector[6], r_byte_vector[5], r_byte_vector[4],
										 r_byte_vector[3], r_byte_vector[2]}; // set output data vector
						next_state_rx = PRE_INI_RX;*/
					/*o_thunder_data <= {r_byte_vector[16], r_byte_vector[15], r_byte_vector[14],
									   r_byte_vector[13], r_byte_vector[12], r_byte_vector[11],
									   r_byte_vector[10], r_byte_vector[9], r_byte_vector[8],
									   r_byte_vector[7], r_byte_vector[6], r_byte_vector[5],
									   r_byte_vector[4], r_byte_vector[3], r_byte_vector[2],
									   r_byte_vector[1], r_byte_vector[0]}; // set output data vector
			end

		endcase
	end

assign o_thunder_packet_dv = r_thunder_packet_dv;
assign o_thunder_data = r_thunder_data;

*/



	always @ (posedge i_clk) begin
		if (i_rst || !r_packet1_sent || !r_packet2_sent) begin // reset or the config packets have not yet been sent
			r_rec_index <= 0;
			r_prev_rx_byte <= 8'dx;
			o_thunder_packet_dv <= 0;
		end
		else begin
			if (w_rx_dv) begin // byte has been received from thunderbolt
				r_prev_rx_byte <= w_rx_byte;  // set the previous byte received
				// detect if id and subcode bytes have been received which indicates the start of a package
				if (w_rx_byte == c_TIM_SUBCODE && r_prev_rx_byte == c_TIM_ID) begin // ID is previous byte and subcode is current byte
					r_receiving_flag <= 1; // indicates receiving a timing packet
					r_byte_vector[0] <= w_rx_byte; // set the 0 index of the byte vector to the subcode byte
					r_rec_index <= 1; // set the receive index (bc the subcode is at index 0)
				end
				// fill the timing packet byte vector with incoming bytes and get rid of stuffing bytes
				if (r_receiving_flag) begin // package is being received
					r_byte_vector[r_rec_index] <= w_rx_byte; // set the byte at the correct location in the received byte vector
					r_rec_index <= r_rec_index + 1;
					// stuffing byte logic
					if (w_rx_byte == c_DLE) begin // byte received is DLE byte
						if (r_prev_rx_byte == c_DLE) begin // received two DLE bytes in a row
							if (r_stuffing_flag == 0) begin // prev byte was not a stuffing byte
								r_rec_index <= r_rec_index - 1; // get rid of stuffing byte by decrementing the byte index
								r_stuffing_flag <= 1;
							end
							else begin // prev byte was a stuffing byte
								r_stuffing_flag <= 0;
							end
						end
					end
					else begin // received a byte that was not DLE
						r_stuffing_flag <= 0; // reset the stuffing flag
					end
				end
			end
			else begin // has not received a byte
				o_thunder_packet_dv <= 0; // packet data not valid (because should only be valid for one clock cycle)
				// detecting the end of the package
				if (r_rec_index == c_TIM_PACKET_SIZE) begin // reached end of package
					r_receiving_flag <= 0; // reset receiving flag
					r_rec_index <= 0; // reset the byte index
					o_thunder_packet_dv <= 1; // set data valid flag
					// matching data to output
					o_thunder_year_l	<= r_byte_vector[16];
					o_thunder_year_h	<= r_byte_vector[15];
					o_thunder_month 	<= r_byte_vector[14];
					o_thunder_day 		<= r_byte_vector[13];
					o_thunder_hour 		<= r_byte_vector[12];
					o_thunder_minutes 	<= r_byte_vector[11];
					o_thunder_seconds 	<= r_byte_vector[10]; 
				end
			end
		end
	end

endmodule