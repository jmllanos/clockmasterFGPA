----------------------------------------------------------------------------------
-- file: SPI_slave.v
-- author: Victor Vasquez
-- SPI slave block. no need for more information.
-- IMPORTANT:	any configuration can be achieved by changing the condition when
--					'cycle' increases from 'sclk_r = rd_edge' to 'sclk_r = wr_edge' as
--					was initially intended, but for speed optimization was changed.
--					currently the block only works for CPHA = 0 as long as the HOLD
--					TIME requirements of the MASTER are met, as the MISO line changes
--					right after the clock reading edge.
--
-- for more information check the thesis report.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_slave is
	generic (
		-- configuration
		RST_LVL		: std_logic := '1';	-- reset low or high
		CPOL	: std_logic := '0';			-- clock polarity
		CPHA	: std_logic := '0'			-- clock phase
	);
	port (
		-- external interface
		sclk	: in	std_logic;	-- serial clock from Master
		mosi	: in	std_logic;			-- ""rx""
		miso	: out	std_logic := '0';	-- ""tx""
		ss		: in	std_logic;	-- slave select, active low
		-- control signals
		clk	: in	std_logic;	-- reference clock
		rst	: in	std_logic;	-- reset
		-- data
		rx_data	: out	std_logic_vector(7 downto 0) := x"00";-- data to read on MOSI
		tx_data	: in	std_logic_vector(7 downto 0);			-- data to send over MISO
		-- logic interface
		spi_end	: out	std_logic := '0'	-- reception completed(one clock cycle flag)
	);
end SPI_slave;

architecture Behavioral of SPI_slave is
	
	constant wr_edge	: std_logic_vector(1 downto 0) := (CPOL xnor CPHA) & (CPOL xor CPHA);
	constant rd_edge	: std_logic_vector(1 downto 0) := (CPOL xor CPHA) & (CPOL xnor CPHA);
	
	constant init_cycle	: unsigned(2 downto 0) := (others => CPHA);	-- initial value for 'cycle'
	signal cycle	: unsigned(2 downto 0) := init_cycle;	-- SCLK cycle
	
	signal sclk_r	: std_logic_vector(1 downto 0) := (others => CPOL);-- register for SCLK
	signal ss_r		: std_logic := '1';	-- register for SS
	signal mosi_r	: std_logic := '0';	-- register for MOSI
	
	signal rx_data_aux	: std_logic_vector(7 downto 0) := x"00";

begin

	ss_shift_register: process(clk)
		-- 'SS' input register
	begin
		if rising_edge(clk) then
			if rst = RST_LVL then
				ss_r	<= '1';
			else
				ss_r	<= ss;
			end if;
		end if;
	end process;

	mosi_shift_register: process(clk)
		-- 'MOSI' input register
	begin
		if rising_edge(clk) then
			if rst = RST_LVL then
				mosi_r	<= '0';
			else
				mosi_r	<= mosi;
			end if;
		end if;
	end process;

	sclk_shift_register: process(clk)
		-- 'SCLK' input register
	begin
		if rising_edge(clk) then
			if rst = RST_LVL then
				sclk_r	<= CPOL & CPOL;
			else
				sclk_r	<= sclk_r(0) & sclk;
			end if;
		end if;
	end process;
	
	spi_cycle: process(clk)
		-- SCLK cycle counter
	begin
		if rising_edge(clk) then
			if rst = RST_LVL or ss_r = '1' then
				cycle		<= init_cycle;
			else
				if sclk_r = rd_edge then	-- theoretically should be at wr_edge but for optimization is at rd_edge
					cycle <= cycle + 1;
				end if;
			end if;
		end if;
	end process;
	-- output bit to 'MISO' line
	miso		<= tx_data(7 - to_integer(cycle));	-- this should be improved

	spi_transaction: process(clk)
		-- transaction process
	begin
		if rising_edge(clk) then
			if rst = RST_LVL or ss_r = '1' then
				rx_data_aux	<= (others => '0');
			else
				if sclk_r = rd_edge then-- reading edge
					rx_data_aux	<= rx_data_aux(6 downto 0) & mosi_r;	-- shif incomming bit
				end if;
			end if;
		end if;
	end process;
	-- wire to 'rx_data'
	rx_data	<= rx_data_aux;

	spi_finish: process (clk)
	begin
		if rising_edge(clk) then
			if rst = RST_LVL or ss_r = '1' then
				spi_end	<= '0';
			else
				-- default 'spi_end' value
				spi_end	<= '0';
				--
				if sclk_r = rd_edge and cycle = 7 then
					spi_end	<= '1';		-- end transaction
				end if;		
			end if;
		end if;
	end process;

end Behavioral;