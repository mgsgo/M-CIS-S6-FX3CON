----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo
-- 
-- Create Date:    2017
-- Design Name:    LED_BLINK
-- Module Name:    FPGA - Behavioral 
-- Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
-- Target Devices: XC6SLX16-2FTG256
-- Tool versions:  ISE14.7
-- Description:    LED blink example
-- License:        LGPL
--
-- Dependencies:   
--
-- Revision:       
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity LED_BLINK is
port(
--clk
i_clk_100mhz			: in		std_logic;		--100mhz

io_gpio					: inout	std_logic_vector(8-1 downto 0);

io_led_D8				: inout	std_logic;
io_led_D9				: inout	std_logic
);
end LED_BLINK;

architecture Behavioral of LED_BLINK is

--components-------------------------------------------------------------------

--signals----------------------------------------------------------------------
signal s_clk_100mhz			: std_logic;                     --
signal s_rst					: std_logic;                     --
signal s_rst_n					: std_logic;                     --
signal s_cnt_32bit			: std_logic_vector(32-1 downto 0);                     --

begin


--reset------------------------------------------------------------------------
--1. internal reset
s_rst					<= '0';
s_rst_n				<= not s_rst;
--end reset--------------------------------------------------------------------

--clock------------------------------------------------------------------------
s_clk_100mhz		<= i_clk_100mhz;
--end clock--------------------------------------------------------------------


--test counter-----------------------------------------------------------------
process(s_rst_n, s_clk_100mhz)
begin
	if s_rst_n = '0' then
		s_cnt_32bit		<= (others=>'0');
	elsif rising_edge(s_clk_100mhz) then
		s_cnt_32bit		<= s_cnt_32bit +1;
	end if;
end process;
--end test counter-------------------------------------------------------------


--led--------------------------------------------------------------------------
io_led_D8							<= not s_cnt_32bit(24);				--D8 low ON
io_led_D9							<= not(s_cnt_32bit(24));			--D9 high ON
--end led----------------------------------------------------------------------

--gpio-------------------------------------------------------------------------
io_gpio								<= s_cnt_32bit(24-1 downto 16);
--end gpio---------------------------------------------------------------------


end Behavioral;

