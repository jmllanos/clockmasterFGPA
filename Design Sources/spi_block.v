`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Module Name: spi_block
// Project: Clock master
// Create by J.Llanos at 08/26/2019
//  
// Description:
//            This module allow read and write registers using SPI protocol
//            -----------------------------
//            | frame1      | frame2      |
//             ----------------------------
//            | w/r & addr  | data(8bits) |
//             ----------------------------
//
//             w/r: write/read enable(1bit), write(1) read(0)  
//             addr: register address(7bits)
//             data: data(8bits) to write in register, 
//                     in case of reading commad does not care
//
// Dependencies: 
//              spi_controller.v
//              spi_slave.v
//              address_map.vh
//
// Additional Comments:
//          --This module is base in the used in the radar controller v2.1
//            develop in Jicamarca Radio Observatory     
//////////////////////////////////////////////////////////////////////////////////

`include "address_map.vh"

module spi_block 
            (  
            input i_clk,
            input i_rst,
            //SPI connections
            input i_MOSI,
            input i_SCLK,
            input i_SSEL,
            output o_MISO,
            // BUS connections
            input [`DATA_WIDTH-1:0]i_data_read_bus,
            output [`ADDR_WIDTH-1:0]o_addr_bus,
            output [`DATA_WIDTH-1:0]o_data_write_bus,
            output o_wr_enable_bus
            );
    
    wire [`DATA_WIDTH-1:0] w_spi_data_rx;
    wire [`DATA_WIDTH-1:0] w_spi_data_tx;
    wire w_spi_ready;
    wire w_spi_busy;
       
      spi_slave #(.SPI_DATA_SIZE(`DATA_WIDTH))
             SPI_SLAVE(
                .i_clk(i_clk), // fpga clock (for over-sampling the SPI bus)
				.i_rst(i_rst),
				// SPI CONNECTIONS 
				.i_SCLK(i_SCLK), 
				.i_SSEL(i_SSEL), 
				.i_MOSI(i_MOSI), // master out slave in
				.o_MISO(o_MISO), // master in slave out
				 //SPI DATA rx/tx 
				 .i_spi_data_tx(w_spi_data_tx),
				 .o_spi_data_rx(w_spi_data_rx), 
				 //SPI signals
				 .o_spi_ready(w_spi_ready),
				 .o_spi_busy(w_spi_busy)
             );
             
    // to decode SPI received frame
    // to select data to send via SPI
    spi_controller spi_control  ( 
                                 .i_clk(i_clk),
                                 .i_rst(i_rst),
                                 //SPI DATA rx/tx
                                 .i_spi_data_rx(w_spi_data_rx),                  
                                 .o_spi_data_tx(w_spi_data_tx),
                                 //SPI signals
                                 .i_spi_ready(w_spi_ready),
                                 .i_spi_busy(w_spi_busy),
                                 // BUS CONNECTIONS 
                                 .i_data_read_bus(i_data_read_bus), 
                                 .o_addr_bus(o_addr_bus),       
                                 .o_data_write_bus(o_data_write_bus), 
                                 .o_wr_enable_bus(o_wr_enable_bus)        
                                 );
endmodule
