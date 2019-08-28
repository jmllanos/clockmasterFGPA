`ifndef _ADDRESS_MAP_VH_
`define _ADDRESS_MAP_VH_
/////////////////////////////////////
//MAIN MEMORY
//TIME_OF_DAY
parameter YEAR_L = 8'h07; 
parameter YEAR_H = 8'h08;
parameter MONTH  = 8'h09;
parameter DAY    = 8'h0A;
parameter HOUR   = 8'h0B;
parameter MINUTE = 8'h0C;
parameter SECOND = 8'h08D;
//CHANNEL CONFIG
parameter CH_MUX_SELECTOR = 8'h0E;
parameter CH_MUX_ENABLE   = 8'h0F;

///////////////////////////////////////
//PPS DIVIDER 0
parameter PPS_DIV_0_PER_TRUE =8'h50;
parameter PPS_DIV_0_DIV_NUM  =8'h51;
parameter PPS_DIV_0_PHASE_0  =8'h52;
parameter PPS_DIV_0_PHASE_1  =8'h53;
parameter PPS_DIV_0_PHASE_2  =8'h54;
parameter PPS_DIV_0_PHASE_3  =8'h55;
parameter PPS_DIV_0_WIDTH    =8'h56;
parameter PPS_DIV_0_START    =8'h57;
parameter PPS_DIV_0_STOP     =8'h58;

//PPS DIVIDER 1
parameter PPS_DIV_1_per_true =8'h59;
parameter PPS_DIV_1_DIV_NUM  =8'h5A;
parameter PPS_DIV_1_HASE_0   =8'h5B;
parameter PPS_DIV_1_PHASE_1  =8'h5C;
parameter PPS_DIV_1_PHASE_2  =8'h5D;
parameter PPS_DIV_1_PHASE_3  =8'h5E;
parameter PPS_DIV_1_WIDTH    =8'h5F;
parameter PPS_DIV_1_START    =8'h60;
parameter PPS_DIV_1_STOP     =8'h61;

//PPS DIVIDER 2
parameter PPS_DIV_2_per_true =8'h62;
parameter PPS_DIV_2_DIV_NUM  =8'h63;
parameter PPS_DIV_2_PHASE_0  =8'h64;
parameter PPS_DIV_2_PHASE_1  =8'h65;
parameter PPS_DIV_2_PHASE_2  =8'h66;
parameter PPS_DIV_2_PHASE_3  =8'h67;
parameter PPS_DIV_2_WIDTH    =8'h68;
parameter PPS_DIV_2_START    =8'h69;
parameter PPS_DIV_2_STOP     =8'h6A;

//PPS DIVIDER 3
parameter PPS_DIV_3_per_true =8'h62;
parameter PPS_DIV_3_DIV_NUM  =8'h63;
parameter PPS_DIV_3_PHASE_0  =8'h64;
parameter PPS_DIV_3_PHASE_1  =8'h65;
parameter PPS_DIV_3_PHASE_2  =8'h66;
parameter PPS_DIV_3_PHASE_3  =8'h67;
parameter PPS_DIV_3_WIDTH    =8'h68;
parameter PPS_DIV_3_START    =8'h69;
parameter PPS_DIV_3_STOP     =8'h6A;

`endif
