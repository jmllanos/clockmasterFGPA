`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory - IGP
// Module: spi_controller
// Project: Clock master
//
// Created by J. Llanos at 08/26/2019
// 
// Description: 
//
//            -The module decode the frame received from SPI_SLAVE module
//             to obtain the "W/R", "ADDRESS" and "DATA"
//            -Control the data to send in reading process,
//            -Send a ACKNOLEGDE signal in writing process,
//
// Dependencies: 
//              address_map.vh
//  
// Additional Comments:
//
//            -This module is base in the used in the radar controller v2.1
//             develop in Jicamarca Radio Observatory                                                               
//////////////////////////////////////////////////////////////////////////////////

`include "address_map.vh"

module spi_controller(
                     input i_clk,
                     input i_rst,
                     //SPI SLAVE DATA 
                     input [`DATA_WIDTH-1:0]    i_spi_data_rx,                  
                     output reg[`DATA_WIDTH-1:0]o_spi_data_tx,
                     
                     //SPI SLAVE signals
                     input i_spi_ready,
                     input i_spi_busy,
                    
                     // BUS CONNECTIONS
                     input [`DATA_WIDTH-1:0] i_data_read_bus,    
                     output reg[`ADDR_WIDTH-1:0] o_addr_bus,    
                     output reg[`DATA_WIDTH-1:0] o_data_write_bus, 
                     output reg o_wr_enable_bus                    
                     );
    
    //States of the FSM                 
    localparam WAIT_ADDR    =3'd0;
    localparam CAPTURE_ADDR =3'd1;
    localparam READ_DATA    =3'd2;
    localparam WRITE_DATA   =3'd3;
    localparam WAIT_DATA    =3'd4;
    
    reg [2:0]present_state;
    reg [2:0]next_state;
    reg r_wr_enable;
    
    ///////////////////////////////////
    //FSM
    //synchronization process
    always @(posedge i_clk)
    begin
        if(i_rst==1'b0)begin
            present_state<=WAIT_ADDR;
        end
        else 
        begin
            present_state<=next_state;
        end
    end
    ///////////////////////////////////////
    //Next state combinational logic
    always @(*)
    begin
        case(present_state)
        //Wait for the arrive of the address
        WAIT_ADDR: 
                if(i_spi_ready==1'b1)begin
                    next_state<=CAPTURE_ADDR;
                end
                else begin
                    next_state<=present_state;
                end
        // Capture the addr in a registers
        CAPTURE_ADDR:   
                if(r_wr_enable == 1'b1)begin
                    next_state<=WAIT_DATA;
                end
                else begin
                    next_state<=READ_DATA;
                end
        //READ DATA FROM THE BUS
        READ_DATA:
                if(i_spi_ready==1'b1)begin
                    next_state<=WAIT_ADDR;
                end
                else begin
                    next_state<=present_state;
                end
        // WAIT
        WAIT_DATA:
                if(i_spi_ready==1'b1)begin
                    next_state<=WRITE_DATA;
                end
                else begin
                    next_state<=present_state;
                end
        // WRITE DATA IN THE BUS
        WRITE_DATA: 
                next_state<=WAIT_ADDR;
        endcase
    end 
    
    ///////////////////////////////////
    //OUTPUTS LOGIC
    
    //address decodification logic
    always@(posedge i_clk)
     if(i_rst==1'b0)begin
        o_addr_bus=8'hFF;
        r_wr_enable=1'b0;
     end
     else if((i_spi_ready==1'b1) && (present_state==WAIT_ADDR)) begin
        o_addr_bus<={1'b0,i_spi_data_rx[`DATA_WIDTH-2:0]};
        r_wr_enable<=i_spi_data_rx[`DATA_WIDTH-1]; 
     end
    
    //write/read_enable_logic
    always@(posedge i_clk)
    if(i_rst==1'b0) begin
        o_wr_enable_bus<=1'b0;    
    end
    else if((present_state==WRITE_DATA) | (present_state==READ_DATA)) begin
        o_wr_enable_bus<=r_wr_enable;
    end
    else begin
        o_wr_enable_bus<=1'b0;
    end
       
    //data_write_logic
    always@(posedge i_clk)
    begin
        if(i_rst==1'b0) begin
            o_data_write_bus<=8'h00;
        end
        else if((i_spi_ready==1'b1) &&(present_state==WAIT_DATA)) begin
            o_data_write_bus<=i_spi_data_rx;
        end
    end
    
    //read_buffer_logic
    always@(posedge i_clk)
    begin
        if(i_rst==1'b0) begin
            o_spi_data_tx<=`ACK;
        end
        else if(present_state==READ_DATA) begin
            o_spi_data_tx<=i_data_read_bus;
        end
        else begin
            o_spi_data_tx<=`ACK;
        end
    end
    
endmodule
