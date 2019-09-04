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
// 
// v1.1 by Victor Vasquez
//   -ERROR coode
//   -PULSE GENERATOR registers for 4 components
//////////////////////////////////////////////////////////////////////////////////

`ifndef _ADDRESS_MAP_VH_
`define _ADDRESS_MAP_VH_
////////
//BUSSES CONFIGURATION
`define ADDR_WIDTH 7//one bit more
`define DATA_WIDTH 8

//READ ACKNOLEDGE ANSWER
`define ACK     8'h60

//TIME_OF_DAY
`define THUNDER_YEAR_L  'h07
`define THUNDER_YEAR_H  'h08
`define THUNDER_MONTH   'h09
`define THUNDER_DAY     'h0A
`define THUNDER_HOUR    'h0B
`define THUNDER_MINUTES 'h0C
`define THUNDER_SECONDS 'h0D

//MAIN MEMORY ADDRESSES
//CHANNEL CONFIG
`define CH_MUX_SELECTOR 'h0E
`define CH_MUX_ENABLE   'h0F

//PULSE GENERATOR 0
`define PG0_PULSE_ENA      'h10
`define PG0_USR_YEAR_H     'h11
`define PG0_USR_YEAR_L     'h12
`define PG0_USR_MONTH      'h13
`define PG0_USR_DAY        'h14
`define PG0_USR_HOUR       'h15
`define PG0_USR_MINUTES    'h16
`define PG0_USR_SECONDS    'h17
`define PG0_WIDTH_HIGH_3   'h18
`define PG0_WIDTH_HIGH_2   'h19
`define PG0_WIDTH_HIGH_1   'h1A
`define PG0_WIDTH_HIGH_0   'h1B
`define PG0_WIDTH_PERIOD_3 'h1C
`define PG0_WIDTH_PERIOD_2 'h1D
`define PG0_WIDTH_PERIOD_1 'h1E
`define PG0_WIDTH_PERIOD_0 'h1F

//PULSE GENERATOR 1
`define PG1_PULSE_ENA      'h20
`define PG1_USR_YEAR_H     'h21
`define PG1_USR_YEAR_L     'h22
`define PG1_USR_MONTH      'h23
`define PG1_USR_DAY        'h24
`define PG1_USR_HOUR       'h25
`define PG1_USR_MINUTES    'h26
`define PG1_USR_SECONDS    'h27
`define PG1_WIDTH_HIGH_3   'h28
`define PG1_WIDTH_HIGH_2   'h29
`define PG1_WIDTH_HIGH_1   'h2A
`define PG1_WIDTH_HIGH_0   'h2B
`define PG1_WIDTH_PERIOD_3 'h2C
`define PG1_WIDTH_PERIOD_2 'h2D
`define PG1_WIDTH_PERIOD_1 'h2E
`define PG1_WIDTH_PERIOD_0 'h2F

//PULSE GENERATOR 2
`define PG2_PULSE_ENA      'h30
`define PG2_USR_YEAR_H     'h31
`define PG2_USR_YEAR_L     'h32
`define PG2_USR_MONTH      'h33
`define PG2_USR_DAY        'h34
`define PG2_USR_HOUR       'h35
`define PG2_USR_MINUTES    'h36
`define PG2_USR_SECONDS    'h37
`define PG2_WIDTH_HIGH_3   'h38
`define PG2_WIDTH_HIGH_2   'h39
`define PG2_WIDTH_HIGH_1   'h3A
`define PG2_WIDTH_HIGH_0   'h3B
`define PG2_WIDTH_PERIOD_3 'h3C
`define PG2_WIDTH_PERIOD_2 'h3D
`define PG2_WIDTH_PERIOD_1 'h3E
`define PG2_WIDTH_PERIOD_0 'h3F

//PULSE GENERATOR 3
`define PG3_PULSE_ENA      'h40
`define PG3_USR_YEAR_H     'h41
`define PG3_USR_YEAR_L     'h42
`define PG3_USR_MONTH      'h43
`define PG3_USR_DAY        'h44
`define PG3_USR_HOUR       'h45
`define PG3_USR_MINUTES    'h46
`define PG3_USR_SECONDS    'h47
`define PG3_WIDTH_HIGH_3   'h48
`define PG3_WIDTH_HIGH_2   'h49
`define PG3_WIDTH_HIGH_1   'h4A
`define PG3_WIDTH_HIGH_0   'h4B
`define PG3_WIDTH_PERIOD_3 'h4C
`define PG3_WIDTH_PERIOD_2 'h4D
`define PG3_WIDTH_PERIOD_1 'h4E
`define PG3_WIDTH_PERIOD_0 'h4F

//PPS DIVIDER 0
`define PPS_DIV_0_PER_TRUE 'h50
`define PPS_DIV_0_DIV_NUM  'h51
`define PPS_DIV_0_PHASE_0  'h52
`define PPS_DIV_0_PHASE_1  'h53
`define PPS_DIV_0_PHASE_2  'h54
`define PPS_DIV_0_PHASE_3  'h55
`define PPS_DIV_0_WIDTH    'h56
`define PPS_DIV_0_START    'h57
`define PPS_DIV_0_STOP     'h58

//PPS DIVIDER 1
`define PPS_DIV_1_PER_TRUE 'h59
`define PPS_DIV_1_DIV_NUM  'h5A
`define PPS_DIV_1_PHASE_0  'h5B
`define PPS_DIV_1_PHASE_1  'h5C
`define PPS_DIV_1_PHASE_2  'h5D
`define PPS_DIV_1_PHASE_3  'h5E
`define PPS_DIV_1_WIDTH    'h5F
`define PPS_DIV_1_START    'h60
`define PPS_DIV_1_STOP     'h61

//PPS DIVIDER 2
`define PPS_DIV_2_PER_TRUE 'h62
`define PPS_DIV_2_DIV_NUM  'h63
`define PPS_DIV_2_PHASE_0  'h64
`define PPS_DIV_2_PHASE_1  'h65
`define PPS_DIV_2_PHASE_2  'h66
`define PPS_DIV_2_PHASE_3  'h67
`define PPS_DIV_2_WIDTH    'h68
`define PPS_DIV_2_START    'h69
`define PPS_DIV_2_STOP     'h6A

//PPS DIVIDER 3
`define PPS_DIV_3_PER_TRUE 'h6B
`define PPS_DIV_3_DIV_NUM  'h6C
`define PPS_DIV_3_PHASE_0  'h6D
`define PPS_DIV_3_PHASE_1  'h6E
`define PPS_DIV_3_PHASE_2  'h6F
`define PPS_DIV_3_PHASE_3  'h70
`define PPS_DIV_3_WIDTH    'h71
`define PPS_DIV_3_START    'h72
`define PPS_DIV_3_STOP     'h73

`endif
