----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo
-- 
-- Create Date:    2019
-- Design Name:    UVC_CIS_LEFT_RIGHT_2560x720
-- Module Name:    FPGA - Behavioral 
-- Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
-- Target Devices: XC6SLX16-2FTG256
-- Tool versions:  ISE14.7
-- Description:    Example of UVC(Universal Video Class) camera using 2 image sensors(MT9M114)
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity video_add_LV_when_FV_low is
generic(
IN_DATA_WIDTH        : integer:=8;
H_WIDTH_BIT          : integer:=11
);
Port(
i_rst_n              : in     std_logic;
i_rst                : in     std_logic;

i_PCLK               : in     STD_LOGIC;
i_LV                 : in     STD_LOGIC;
i_FV                 : in     STD_LOGIC;
i_DATA               : in     STD_LOGIC_vector(IN_DATA_WIDTH-1 downto 0);

o_LV                 : out    STD_LOGIC;
o_FV                 : out    STD_LOGIC;
o_DATA               : out    STD_LOGIC_vector(IN_DATA_WIDTH-1 downto 0)
);
end video_add_LV_when_FV_low;

architecture Behavioral of video_add_LV_when_FV_low is
--components

--constants
constant c_LV_width     : std_logic_vector(H_WIDTH_BIT-1 downto 0):=conv_std_logic_vector(2560, 12);
constant c_LBLANK_width : std_logic_vector(H_WIDTH_BIT-1 downto 0):=conv_std_logic_vector(610, 12);

--signals----------------------------------------------------------------------
signal s_LV             : std_logic;
signal s_LV_add         : std_logic;
signal s_FV             : std_logic;
signal s_DATA           : std_logic_vector(IN_DATA_WIDTH-1 downto 0);
signal cnt_FV_low       : std_logic_vector((H_WIDTH_BIT+1)-1 downto 0);

begin

--input video d flip flops
process(i_PCLK)
begin
   if rising_edge(i_PCLK) then
      s_FV           <= i_FV;
      s_DATA         <= i_DATA;
   end if;
end process;

--cnt_FV_low
process(i_rst_n, i_PCLK, i_FV)
begin
   if i_rst_n = '0' or i_FV = '1' then
      cnt_FV_low     <= (others=>'0');
      s_LV_add       <= '0';
   elsif rising_edge(i_PCLK) then
      cnt_FV_low     <= cnt_FV_low +1;
      if cnt_FV_low = c_LBLANK_width then
         s_LV_add    <= '1';
      elsif cnt_FV_low = c_LBLANK_width + c_LV_width then
         s_LV_add    <= '0';
         cnt_FV_low  <= (others=>'0');
      end if;
   end if;
end process;

--s_LV
process(i_PCLK, i_FV)
begin
   if rising_edge(i_PCLK) then
      if i_FV = '1' then
         s_LV        <= i_LV;
      else
         s_LV        <= s_LV_add;
      end if;
   end if;
end process;

o_LV              <= s_LV;
o_FV              <= s_FV;
o_DATA            <= s_DATA;

end Behavioral;
