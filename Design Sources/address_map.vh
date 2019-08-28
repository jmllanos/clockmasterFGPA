`ifndef _ADDRESS_MAP_VH_
`define _ADDRESS_MAP_VH_
////////
//BUSES CONFIGURATION
parameter ADDR_WIDTH=8;
parameter DATA_WIDTH=8;

/////////////////////////////////////
//MAIN MEMORY ADDRESSES
//TIME_OF_DAY
parameter YEAR_L = 'h07; 
parameter YEAR_H = 'h08;
parameter MONTH  = 'h09;
parameter DAY    = 'h0A;
parameter HOUR   = 'h0B;
parameter MINUTE = 'h0C;
parameter SECOND = 'h08D;
//CHANNEL CONFIG
parameter CH_MUX_SELECTOR = 'h0E;
parameter CH_MUX_ENABLE   = 'h0F;

///////////////////////////////////////
//PPS DIVIDER 0
parameter PPS_DIV_0_PER_TRUE ='h50;
parameter PPS_DIV_0_DIV_NUM  ='h51;
parameter PPS_DIV_0_PHASE_0  ='h52;
parameter PPS_DIV_0_PHASE_1  ='h53;
parameter PPS_DIV_0_PHASE_2  ='h54;
parameter PPS_DIV_0_PHASE_3  ='h55;
parameter PPS_DIV_0_WIDTH    ='h56;
parameter PPS_DIV_0_START    ='h57;
parameter PPS_DIV_0_STOP     ='h58;

//PPS DIVIDER 1
parameter PPS_DIV_1_per_true ='h59;
parameter PPS_DIV_1_DIV_NUM  ='h5A;
parameter PPS_DIV_1_HASE_0   ='h5B;
parameter PPS_DIV_1_PHASE_1  ='h5C;
parameter PPS_DIV_1_PHASE_2  ='h5D;
parameter PPS_DIV_1_PHASE_3  ='h5E;
parameter PPS_DIV_1_WIDTH    ='h5F;
parameter PPS_DIV_1_START    ='h60;
parameter PPS_DIV_1_STOP     ='h61;

//PPS DIVIDER 2
parameter PPS_DIV_2_per_true ='h62;
parameter PPS_DIV_2_DIV_NUM  ='h63;
parameter PPS_DIV_2_PHASE_0  ='h64;
parameter PPS_DIV_2_PHASE_1  ='h65;
parameter PPS_DIV_2_PHASE_2  ='h66;
parameter PPS_DIV_2_PHASE_3  ='h67;
parameter PPS_DIV_2_WIDTH    ='h68;
parameter PPS_DIV_2_START    ='h69;
parameter PPS_DIV_2_STOP     ='h6A;

//PPS DIVIDER 3
parameter PPS_DIV_3_per_true ='h62;
parameter PPS_DIV_3_DIV_NUM  ='h63;
parameter PPS_DIV_3_PHASE_0  ='h64;
parameter PPS_DIV_3_PHASE_1  ='h65;
parameter PPS_DIV_3_PHASE_2  ='h66;
parameter PPS_DIV_3_PHASE_3  ='h67;
parameter PPS_DIV_3_WIDTH    ='h68;
parameter PPS_DIV_3_START    ='h69;
parameter PPS_DIV_3_STOP     ='h6A;

`endif
