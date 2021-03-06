/**********************************************************

file: top.v
author: Eloise Perrochet
description:

Update by V. Vasquez at 09/2019

This is the file to synthetize on iCEcube

This file call all the files of the design 

The module spi_slabe.v is not working properly, the module
SPI_slave.vhd is used instated.

**********************************************************/
`timescale 1ns / 1ps

//includes for design sub-modules

`include "spi_block.v"
//`include "spi_slave.v"
`include "spi_controller.v"
`include "thunderbolt_block.v"
`include "thunderbolt.v"
`include "uart_rx.v"
`include "uart_tx.v"
`include "thunderbolt_registers.v"
`include "pps_div_block.v"
`include "pps_divider.v"
`include "pps_div_registers.v"
`include "pulse_generator_block.v"
`include "pulse_generator.v"
`include "pulse_generator_registers.v"
`include "main_memory.v"
`include "mux_data_read.v"
`include "channel_mux.v"
//`include "SPI_slave.vhd"
`include "power_on_reset.v"
`include "reset_block.v"

`include "top.v"
