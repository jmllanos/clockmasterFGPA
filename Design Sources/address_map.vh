//////////////////////////////////////////////////////////////////////////////////
// Jicamarca Radio Observatory
// Verilog Header Name: address_map
// Project: Clock master
//
// Create by J.Llanos at 08/28/2019
//
// Description:
//   Macros for:
//   -Address of the registers to configurate PPS Divider
//   -Configuration of ADDRESS and DATA bus width.
//   -Configuration of the value of the ACKNOLEDGE value to send via SPI in 
//    reading process.
//////////////////////////////////////////////////////////////////////////////////

`ifndef _ADDRESS_MAP_VH_
`define _ADDRESS_MAP_VH_
////////
//BUSSES CONFIGURATION
`define ADDR_WIDTH 8
`define DATA_WIDTH 8

//READ ACKNOLEDGE ANSWER
`define ACK 8'h60

/////////////////////////////////////
//MAIN MEMORY ADDRESSES
//TIME_OF_DAY
`define YEAR_L = 'h07; 
`define YEAR_H = 'h08;
`define MONTH  = 'h09;
`define DAY    = 'h0A;
`define HOUR   = 'h0B;
`define MINUTE = 'h0C;
`define SECOND = 'h08D;
//CHANNEL CONFIG
`define CH_MUX_SELECTOR = 'h0E;
`define CH_MUX_ENABLE   = 'h0F;

///////////////////////////////////////
//PPS DIVIDER 0
`define PPS_DIV_0_PER_TRUE ='h50;
`define PPS_DIV_0_DIV_NUM  ='h51;
`define PPS_DIV_0_PHASE_0  ='h52;
`define PPS_DIV_0_PHASE_1  ='h53;
`define PPS_DIV_0_PHASE_2  ='h54;
`define PPS_DIV_0_PHASE_3  ='h55;
`define PPS_DIV_0_WIDTH    ='h56;
`define PPS_DIV_0_START    ='h57;
`define PPS_DIV_0_STOP     ='h58;

//PPS DIVIDER 1
`define PPS_DIV_1_per_true ='h59;
`define PPS_DIV_1_DIV_NUM  ='h5A;
`define PPS_DIV_1_HASE_0   ='h5B;
`define PPS_DIV_1_PHASE_1  ='h5C;
`define PPS_DIV_1_PHASE_2  ='h5D;
`define PPS_DIV_1_PHASE_3  ='h5E;
`define PPS_DIV_1_WIDTH    ='h5F;
`define PPS_DIV_1_START    ='h60;
`define PPS_DIV_1_STOP     ='h61;

//PPS DIVIDER 2
`define PPS_DIV_2_per_true ='h62;
`define PPS_DIV_2_DIV_NUM  ='h63;
`define PPS_DIV_2_PHASE_0  ='h64;
`define PPS_DIV_2_PHASE_1  ='h65;
`define PPS_DIV_2_PHASE_2  ='h66;
`define PPS_DIV_2_PHASE_3  ='h67;
`define PPS_DIV_2_WIDTH    ='h68;
`define PPS_DIV_2_START    ='h69;
`define PPS_DIV_2_STOP     ='h6A;

//PPS DIVIDER 3
`define PPS_DIV_3_per_true ='h62;
`define PPS_DIV_3_DIV_NUM  ='h63;
`define PPS_DIV_3_PHASE_0  ='h64;
`define PPS_DIV_3_PHASE_1  ='h65;
`define PPS_DIV_3_PHASE_2  ='h66;
`define PPS_DIV_3_PHASE_3  ='h67;
`define PPS_DIV_3_WIDTH    ='h68;
`define PPS_DIV_3_START    ='h69;
`define PPS_DIV_3_STOP     ='h6A;

`endif
