`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2019 04:25:36 PM
// Design Name: 
// Module Name: regfile_control
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


module regfile_control #(parameter FILE_SIZE_BYTES=26)
            (
            input i_clk_10,
            input w_spi_packet_rec,
            input [15:0] w_packet_data,
            output reg [7:0] r_wr_byte,
            output reg [7:0] r_wr_addr,
            output reg r_write
    );
       
// logic to write to the regfile when a SPI packet has been received
always @ (posedge i_clk_10) begin
    if (w_spi_packet_rec && w_packet_data[15:8] <  FILE_SIZE_BYTES) begin // received a packet and packet has a valid address
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
endmodule
