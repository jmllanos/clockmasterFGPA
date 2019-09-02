`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2019 05:19:15 PM
// Design Name: 
// Module Name: transmision_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transmision_control #(parameter c_FILE_SIZE_BYTES=26,
                      parameter c_CMD_SEND_REG = 8'hAB,
                      parameter c_CMD_SEND_THUNDER = 8'hAC,
                      parameter c_CMD_EASTER_EGG = 8'hEE,
                      parameter c_TIM_PACKET_SIZE = 17)
                      
                    (input i_clk_10,
                    input i_rst,
                    output reg r_tx_dv,
                    output reg [7:0] r_tx_byte,
                    input w_tx_done,
                    input [7:0] w_rx_byte,
                    input w_rx_dv,
                    input[8*c_FILE_SIZE_BYTES-1:0] w_reg_vector,
                    input[135:0] w_thunder_data
                    );


// logic to send the contents of the reg file over the serial transmitter
wire [7:0] w_reg_matrix [0:c_FILE_SIZE_BYTES-1];
	// unpacking the reg vector
	genvar j;
	for (j=0; j<c_FILE_SIZE_BYTES; j=j+1) begin: REG_UNPACK // iterate over every byte in the regFile
		assign w_reg_matrix[j] = w_reg_vector[(j*8)+7:(j*8)];
	end

wire [7:0] w_thunder_matrix [0:c_TIM_PACKET_SIZE-1];
genvar k;
for (k=0; k<c_TIM_PACKET_SIZE; k=k+1) begin: THUNDER_UNPACK // iterate over the last 7 bytes in the packet starting at 10
 	assign w_thunder_matrix[k] = w_thunder_data[(k*8)+7:(k*8)];
end


reg [4:0] r_index = 0; // the index of the byte that is being sent
reg r_send_regfile = 0; // flag to trigger sending of the regfile over the uart
reg r_send_thunder = 0; // flag to trigger sending of the thunderbolt data over the uart
reg r_send_easter = 0;
wire [7:0] easter [0:1];
assign easter[0] = 8'hCA;
assign easter[1] = 8'hFE;

always @ (posedge i_clk_10) begin
		if (i_rst) begin
			r_tx_dv <= 0;
			r_tx_byte <= 8'hx;
			r_index <= 0;
			r_send_regfile <= 0;
		end
	    else begin
			if (r_send_regfile) begin // have received a command to send the regfile
				r_tx_dv <= 1; // transmit
				r_tx_byte <= w_reg_matrix[r_index]; // shift the byte to send
				if(w_tx_done) begin // transmission over
					if (r_index < 5'd20) begin // haven't reached end of regfile
						r_index <= r_index + 5'd1; // increment the index
					end
					else begin // reached end of regfile
						r_send_regfile <= 0; // reset the flag
						r_tx_dv <= 0; // don't transmit
						r_index <= 0; // reset the index
					end
				end
		end
			else if (r_send_thunder) begin // same logic but for thunderbolt matrix
				r_tx_dv <= 1;
				r_tx_byte <= w_thunder_matrix[r_index];
				if(w_tx_done) begin
					if (r_index < 5'd16) begin
						r_index <= r_index + 5'd1;
					end
					else begin
						r_send_thunder <= 0;
						r_tx_dv <= 0;
						r_index <= 0;
					end
				end
			end
			else if (r_send_easter) begin
				r_tx_dv <= 1;
				r_tx_byte <= easter[r_index];
				if(w_tx_done) begin
					if (r_index < 5'd1) begin
						r_index <= r_index + 5'd1;
					end
					else begin
						r_send_easter <= 0;
						r_tx_dv <= 0;
						r_index <= 0;
					end
				end
			end
			else begin // haven't received a command to send the regfile or thunder data
				r_tx_dv <= 0; // don't transmit
				if (w_rx_dv) begin // received a byte
					if (w_rx_byte == c_CMD_SEND_REG) begin // received a command to send the regfile
						r_send_regfile <= 1; // set the flag to send the contents of the regfile
						r_tx_byte <= c_CMD_SEND_REG;
					end
					else if (w_rx_byte == c_CMD_SEND_THUNDER) begin // received a command to send the thunder data
						r_send_thunder <= 1;
						r_tx_byte <= c_CMD_SEND_THUNDER;
					end
					else if (w_rx_byte == c_CMD_EASTER_EGG) begin // teehee
						r_send_easter <= 1;
						r_tx_byte <= c_CMD_EASTER_EGG;
					end
					else begin // received some other byte
						r_tx_dv <= 1; // transmit
						r_tx_byte <= w_rx_byte; // send an echo of the received byte
						r_send_regfile <= 0; // don't send the file
						r_send_thunder <= 0; // don't send the thunder data
						r_send_easter <= 0;
					end
				end
			end
		end
	end
   
endmodule
    

