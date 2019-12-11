//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory - IGP
// Module: spi_slave
// Project: Clock master
//
// Created by J. Llanos at 08/26/2019
// 
// Description:
//            -Module to implement SPI protocol
//            -SPI as Slave device 
//              
// Dependencies: 
//              address_map.vh
//
// Additional Comments:
//            -This module is base in the used in the radar controller v2.1
//             develop in Jicamarca Radio Observatory.
//            -This base in the spi_slave module developed by Eloise Perrochet.                                                              
//////////////////////////////////////////////////////////////////////////////////



module spi_slave #(parameter SPI_DATA_SIZE=8)
                 (input i_clk, // fpga clock (for over-sampling the SPI bus)
				 input i_rst, // reset
				 // SPI connections
				 input i_SCLK, // slave clock from master
				 input i_SSEL, // slave select
				 input i_MOSI, // master out slave in
				 output reg o_MISO, // master in slave out
				 // SPI data rx/tx
				 input [SPI_DATA_SIZE-1:0] i_spi_data_tx,
				 output reg [SPI_DATA_SIZE-1:0] o_spi_data_rx,
				 // SPI signals
				 output o_spi_ready,
				 output o_spi_busy
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
	wire w_SCLK_fallingedge;

	assign w_SCLK_risingedge = (r_SCLK[2:1]==2'b01);  // now we can detect i_SCLK rising edges
	assign w_SCLK_fallingedge = (r_SCLK[2:1]==2'b10);  // and falling edges

	// same thing for i_SSEL
	reg [2:0] r_SSEL;

	always @(posedge i_clk)
	begin
		r_SSEL <= {r_SSEL[1:0], i_SSEL};
	end

	wire w_SSEL_active;
	wire w_SSEL_inactive;
	
	assign w_SSEL_active = ~r_SSEL[1];  // i_SSEL is active low
    assign w_SSEL_inactive = r_SSEL[1];
    
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

	
	reg [7:0] r_byte_data_received;
    reg r_spi_ready;
  
  //--------------------------------------------------------------------------------------------------
	// receiving data from the SPI bus
	//--------------------------------------------------------------------------------------------------
    //Receive_logic
	always @(posedge i_clk)
	begin
	 if(i_rst==1'b1) 
	   begin
	       r_bitcnt<=3'b000;
	       r_byte_data_received<=`DATA_WIDTH'h0;
	       o_spi_data_rx<=3'b000;
	       r_spi_ready<=1'b0;
	   end
	 else begin
           if(w_SSEL_inactive) begin
                r_bitcnt <= 3'b000;
           end
           else if(w_SCLK_risingedge) begin
                r_bitcnt <= r_bitcnt + 3'b001;
                // implement a shift-left register (since we receive the data MSB first)
                r_byte_data_received <= {r_byte_data_received[`DATA_WIDTH-2:0], w_MOSI_data};
                if(r_bitcnt==3'b111) begin
                    r_bitcnt<=3'b000;
                end
            end
            // Data received status
           if(r_bitcnt==3'b111)begin
                if(w_SSEL_active)begin
                    if (w_SCLK_risingedge==1'b1) begin
                        r_spi_ready<=1'b1;
                        o_spi_data_rx<={r_byte_data_received[6:0], w_MOSI_data};
                    end
                    else begin
                        r_spi_ready<=1'b0;	  	        
                    end
                end
                else begin
                    r_spi_ready<=1'b0;
                end
            end
            else begin
                r_spi_ready<=1'b0;
            end
	  end  	
	end
	    
    assign o_spi_ready=r_spi_ready;
    
    reg [7:0] buffer_out;
    
    
    
    //Transmission_logic
    always @(posedge i_clk)
    begin
       if(i_rst==1'b1) begin
	      buffer_out<=`DATA_WIDTH'h0;
	   end
	   else if (w_SSEL_active) begin
          if (r_bitcnt==3'b000) begin
              if (w_SCLK_risingedge) begin
                  buffer_out<=i_spi_data_tx;
              end
           end
           else if(w_SCLK_fallingedge) begin
              buffer_out<={buffer_out[`DATA_WIDTH-2:0],1'b0};
           end 
           
          o_MISO<=buffer_out[7]; 
	   end
    end
    
   
    
    //--------------------------------------------------------------------------------------------------
	// SPI status
	//--------------------------------------------------------------------------------------------------
    //spi_busy_logic
    reg r_spi_busy;
    always @(posedge i_clk)
    begin
      if (i_rst==1'b1) begin
            r_spi_busy<=1'b1;
      end
      else begin
        r_spi_busy<=~(r_SSEL[0] & r_SSEL[1]);
      end      
    end
    
    assign o_spi_busy=r_spi_busy;
    
endmodule
