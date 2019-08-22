/***************************************************

file: regfile.v
author: Eloise Perrochet
description:

This regfile can store FILE_SIZE_BYTES bytes
NOTE: the maximum allowed FILE_SIZE_BYTES is 32

to write
--------
Hold the i_write line high to signal a data write operation.
Then the Register File writes one value to the register at
location i_wr_addr with the value i_wr_byte.

to read
--------
hold i_read line high to signal a data read operation.
Then the Reigster File outputs the register o_rd_byte
at the location i_rd_addr.
o_rd_byte is only valid while i_read is high and i_write is low

*******************************************************/


/***************************************************
file: regfile.v (version 2)
author: Arom Miranda
description:
Now the regfile is for 24 bytes (4 included to save period pulse out configuration)
*******************************************************/

module regfile #(parameter FILE_SIZE_BYTES = 25) // default 24 bytes in the regfile
			   (input i_clk,
	 	 	    input i_rst,
				// writing
				input i_write,
				input [7:0] i_wr_addr, // address of register to write to
				input [7:0] i_wr_byte, // byte to write to the regfile
				// reading
				input i_read,
				input [7:0] i_rd_addr,
				output reg [7:0] o_rd_byte,
				// parallel connection to registers that map to pps divider and pulse generator values
				output [FILE_SIZE_BYTES*8-1:0] o_reg_vector
			    );

	reg [7:0] reg_file [0:(FILE_SIZE_BYTES-1)]; // the actual reg file

	// logic to handle read and write operations
	integer i;
	always @ (posedge i_clk) begin
		if (i_rst) begin
			for (i = 0; i < FILE_SIZE_BYTES; i = i + 1) begin
 				reg_file[i] <= 8'd0;
			end
	  		o_rd_byte <= 8'dx;
		end
		else begin
			if (i_write) begin // write operation
				reg_file [i_wr_addr] <= i_wr_byte;
			end
			else if (i_read) begin // read operation
				o_rd_byte <= reg_file[i_rd_addr];
			end
			else begin // not reading or writing
  		  		o_rd_byte <= 8'dx;
			end
		end
	end

	// this output vector provides a direct parallel connection to the registers that contain values for the
	// pps divider and pulse generator
	assign o_reg_vector = { /* pulse generator registers */
							reg_file[24], reg_file[23], reg_file[22], reg_file[21],
							reg_file[20], reg_file[19], reg_file[18], reg_file[17],
							reg_file[16], reg_file[15], reg_file[14], reg_file[13],
							reg_file[12], reg_file[11], reg_file[10], reg_file[9],
							/* pps divider registers */
							reg_file[8], reg_file[7],
							reg_file[6], reg_file[5], reg_file[4], reg_file[3], reg_file[2],
							reg_file[1], reg_file[0]
						  };

endmodule
