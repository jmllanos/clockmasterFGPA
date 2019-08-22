/*********************************************************************
test bench for thunderbolt module 
**********************************************************************/

`include "thunderbolt.v"

module tb_thunderbolt(); 


	//--------------------------------
	// Test clock 
	//--------------------------------
	
	wire clk10; 
	default_clk_gen #(.CLK_PERIOD_NS(100)) tb_clk (.o_clk(clk10)); // 10 MHz clock 
	
	//--------------------------------
	// DUT io declarations
	//--------------------------------
	
	// dut inputs 
	reg rst; 
	reg rx_thunder; 
	// dut outputs
	wire tx_thunder; 
	wire thunder_packet_dv; 
	wire [88:0] thunder_data; 
	
	//--------------------------------
	// DUT instantiation 
	//--------------------------------
	
	thunderbolt DUT (.i_clk(clk10), 
					 .i_rst(rst), 
					 .i_rx_thunder(rx_thunder), 
					 .o_tx_thunder(tx_thunder),
					 .o_thunder_packet_dv(thunder_packet_dv),
					 .o_thunder_data(thunder_data)
					);
					
	//--------------------------------
	// waveform file generation 
	//--------------------------------
	initial
	begin
		$dumpfile ("wave_thunder.vcd");
		$dumpvars;
	end
	
	//--------------------------------
	// Directed stimulus generation
	//--------------------------------
	
	initial begin
		
		// initialization 
		#100000
		rst <= 1; 
		#100000
		rst <= 0; 
		#50000000
		// exit simulation
		$finish;
	end
	
endmodule 

/*********************************************************************
default_clk_gen
**********************************************************************/

module default_clk_gen #(parameter CLK_PERIOD_NS = 1000)
						(output wire o_clk);
	
	// signal declaration 
	reg r_clk = 1'b0; 
	
	// clock generation logic 
    initial
    begin
        forever
        begin
            #(CLK_PERIOD_NS / 2) r_clk = ~r_clk;  
        end
    end
	
	// output 
	assign o_clk = r_clk; 

endmodule