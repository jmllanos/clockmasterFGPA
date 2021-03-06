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
file: thunderbol.v (version 3.0)
author: Victor Vasquez
description:
- 'output reg [135:0] o_thunder_data' replaced by vectors of 8-bits representing time of day,
  these will go to pulse_generator blocks and to a register map
- correction to send process to send first byte 8'h10
- correction of sent_index counter to reset and response at the correct second
- enable with pps to sync processes, new process
!!!!!!Architecture is poorly writen. This block should be redesigned!!!!!!!!!!
**********************************************************************/

	module thunderbolt (
        input 	i_clk,
        input 	i_rst,
        input   i_pps_raw,
        // rs232 connection
        input	i_rx_thunder,  // serial from thunderbolt
        output	o_tx_thunder, // serial to thunderbolt
        // flag to indicate that thunder packet data is valid
        output reg o_thunder_packet_dv,
        // data that contains contents of thunderbolt packet
        output reg [7:0] o_thunder_year_h,
        output reg [7:0] o_thunder_year_l,
        output reg [7:0] o_thunder_month,
        output reg [7:0] o_thunder_day,
        output reg [7:0] o_thunder_hour,
        output reg [7:0] o_thunder_minutes,
        output reg [7:0] o_thunder_seconds
       );

		// ---------------------------------------------------
		// sending thunderbolt configuration packets
		// ---------------------------------------------------

		// TSIP constants
		parameter c_DLE = 8'h10;
		parameter c_CMD_ID = 8'h8E;
		parameter c_ETX = 8'h03;

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
            //
			8'd5: r_utc_broadcast_cmd<= c_DLE;
			8'd6: r_utc_broadcast_cmd<= c_CMD_ID;
			8'd7: r_utc_broadcast_cmd<= 8'hA5;
			8'd8: r_utc_broadcast_cmd<= 8'h00;
			8'd9: r_utc_broadcast_cmd<= 8'h01;
			8'd10: r_utc_broadcast_cmd<= 8'h00;
			8'd11: r_utc_broadcast_cmd<= 8'h00;
			8'd12: r_utc_broadcast_cmd<= c_DLE;
			8'd13: r_utc_broadcast_cmd<= c_ETX;
			//VVVVVVVVVVVVVVVdefault: r_utc_broadcast_cmd<=c_DLE;
		endcase

	end
   
     reg    [1:0]r_pps_raw = 0;
	// ---------------------------------------------------
	// PPS detection logic
	// ---------------------------------------------------
	always @ (posedge i_clk) begin
		if (i_rst) begin
            r_pps_raw <= 0;
		end
		else begin
			r_pps_raw <= {r_pps_raw[0], i_pps_raw};
		end
	end
    
    localparam STAGE_0 = 2'h0;// wait 1st pps
    localparam STAGE_1 = 2'h1;// wait 2nd pps and send config packets
    localparam STAGE_2 = 2'h2;// wait 3rd pps and start listening

    reg [1:0]component_stage = 0;
    
    always @ (posedge i_clk) begin
		if (i_rst) begin
            component_stage <= STAGE_0;
		end
        if (r_pps_raw == 2'b01) begin
            case (component_stage)
                STAGE_0: component_stage <= STAGE_1;
                STAGE_1: component_stage <= STAGE_2;
            endcase
        end
	end

	// ---------------------------------------------------
	// uart transmitter and receiver instantiation
	// ---------------------------------------------------

	parameter c_CLKS_PER_BIT = 1042; // 10*10^6 / 9600 = 1042

	wire [7:0] w_rx_byte;
	wire w_rx_dv; //*******************************************************************

	// receiver
	uart_rx #(.CLKS_PER_BIT	(c_CLKS_PER_BIT)) receiver
			 (.i_Clock		(i_clk),
			  .i_rst		(i_rst),
			  .i_Rx_Serial	(i_rx_thunder),
			  .o_Rx_DV		(w_rx_dv),
		      .o_Rx_Byte	(w_rx_byte)
			 );

	// transmitter
	reg r_tx_dv = 0;
	reg [7:0] r_tx_byte = c_DLE;// necessary so the mux of r_utc_broadcast_cmd can do what it is supossed to
	wire w_tx_done;
	wire w_tx_active;

	uart_tx #(.CLKS_PER_BIT	(c_CLKS_PER_BIT)) transmitter
			 (.i_Clock		(i_clk),
			  .i_rst		(i_rst),
			  .i_Tx_DV		(r_tx_dv),
			  .i_Tx_Byte	(r_tx_byte),
		      .o_Tx_Serial	(o_tx_thunder),
		      .o_Tx_Active	(w_tx_active),
			  .o_Tx_Done	(w_tx_done)
			 );

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
    if (i_rst) begin
        sent_index = 0;
        r_tx_byte = c_DLE;//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    end
    else if (cena && (component_stage == STAGE_1)) begin
        sent_index = sent_index + 1'b1;
        r_tx_byte <= r_utc_broadcast_cmd;
	end
end

//-- Transition between states
always @(posedge i_clk) begin
	if (i_rst)
		state <= PRE_INI;
	else if (component_stage == STAGE_1)
		state <= next_state;
end

//-- Control signal generation and next states ASM for transmitting packets
always @(*) begin
    next_state = state;
    r_tx_dv = 0;
    cena = 0;
    if (component_stage == STAGE_1) begin
        case (state)
            //-- Initial state. Start the trasmission
            PRE_INI: begin
                r_tx_dv = 0;
                next_state = INI;
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
                cena = 1;////????????????????????
                if (sent_index ==14)////??????????????
                    next_state = STOP;
                else
                    next_state = INI;
            end
            STOP: begin
                r_tx_dv = 0;
            end
        endcase
    end  
end

	// ---------------------------------------------------
	// receiving a thunderbolt timing packet
	// ---------------------------------------------------

	parameter c_TIM_ID = 8'h8F;
	parameter c_TIM_SUBCODE = 8'hAB;
	parameter c_TIM_PACKET_SIZE = 21;

	reg [7:0] r_prev_rx_byte; // previous data byte received

	reg [7:0] r_byte_vector [c_TIM_PACKET_SIZE-1:0]; // timing packet byte vector
	reg [7:0] r_byte_vector_next [c_TIM_PACKET_SIZE-1:0]; // timing packet byte vector

	reg [7:0] r_rec_index; // position of byte inside incoming packet
	reg r_stuffing_flag = 0; // for accounting for stuffing bytes
	reg r_receiving_flag = 0;

	always @ (posedge i_clk) begin
		if (i_rst) begin // reset or the config packets have not yet been sent
			r_rec_index <= 0;
			r_prev_rx_byte <= 8'd0;//*******************************************
			o_thunder_packet_dv <= 0;
            o_thunder_year_l	<= 8'h0;
            o_thunder_year_h	<= 8'h0;
            o_thunder_month 	<= 8'h0;
            o_thunder_day 		<= 8'h0;
            o_thunder_hour 		<= 8'h0;
            o_thunder_minutes 	<= 8'h0;
            o_thunder_seconds 	<= 8'h0;
		end
		else if (component_stage == STAGE_2) begin///***************+++++++++++++++++++++++
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
					r_rec_index <= r_rec_index + 8'b1;
					// stuffing byte logic
					if ((w_rx_byte == c_DLE) && (r_prev_rx_byte == c_DLE)) begin // received two DLE bytes in a row
						if (r_stuffing_flag == 0) begin // prev byte was not a stuffing byte
							r_rec_index <= r_rec_index;// - 8'b1; // get rid of stuffing byte by decrementing the byte index
							r_stuffing_flag <= 1;
						end
						else begin // prev byte was a stuffing byte
							r_stuffing_flag <= 0;
						end
					end
					else begin // received a byte that was not DLE
						r_stuffing_flag <= 0; // reset the stuffing flag
					end
				end
			end
			//else begin // has not received a byte++++++++++++++++++++++++++++++++++
				o_thunder_packet_dv <= 0; // packet data not valid (because should only be valid for one clock cycle)
				// detecting the end of the package
				if (r_rec_index == c_TIM_PACKET_SIZE - 2) begin // reached end of package VVVVVVVVVVVVVVVVVVVV++++++++++++++++++++++++++++++++++
					r_receiving_flag	<= 0; // reset receiving flag
					r_rec_index 		<= 0; // reset the byte index
					r_stuffing_flag 	<= 0;
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
			//end
		end
	end

endmodule