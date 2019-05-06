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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity video_merge_two8bit1280x720_to_one16bit2560x720 is
generic(
IN_DATA_WIDTH        : integer;
H_WIDTH              : integer;
V_HEIGHT             : integer;
H_WIDTH_BIT          : integer;
V_HEIGHT_BIT         : integer
);
Port(
i_rst_n              : in     std_logic;

i_C1_PCLK            : in     std_logic;
i_C1_LV              : in     std_logic;
i_C1_FV              : in     std_logic;
i_C1_DATA            : in     std_logic_vector(IN_DATA_WIDTH-1 downto 0);

i_C2_PCLK            : in     STD_LOGIC;
i_C2_LV              : in     STD_LOGIC;
i_C2_FV              : in     STD_LOGIC;
i_C2_DATA            : in     std_logic_vector(IN_DATA_WIDTH-1 downto 0);

o_OUT_PCLK           : out    std_logic;
o_OUT_LV             : out    std_logic;
o_OUT_FV             : out    std_logic;
o_OUT_DATA           : out    std_logic_vector(IN_DATA_WIDTH*2-1 downto 0);

r_H_WIDTH            : in     std_logic_vector(16-1 downto 0);
r_V_HEIGHT           : in     std_logic_vector(16-1 downto 0);
r_PACK_OPT           : in     std_logic_vector(8-1 downto 0)
);
end video_merge_two8bit1280x720_to_one16bit2560x720;

architecture Behavioral of video_merge_two8bit1280x720_to_one16bit2560x720 is


--constants

--components-------------------------------------------------------------------
component video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing is
generic(
IN_DATA_WIDTH        : integer:=12;
H_WIDTH              : integer:=1280;
V_HEIGHT             : integer:=720;
H_WIDTH_BIT          : integer:=11;
V_HEIGHT_BIT         : integer:=11
);
Port(
i_rst_n              : in     std_logic;

i_C1_PCLK            : in     std_logic;
i_C1_LV              : in     std_logic;
i_C1_DE_2CLK         : in     std_logic;
i_C1_FV              : in     std_logic;
i_C1_DATA            : in     std_logic_vector(IN_DATA_WIDTH-1 downto 0);

i_C2_PCLK            : in     std_logic;
i_C2_LV              : in     std_logic;
i_C2_DE_2CLK         : in     std_logic;
i_C2_FV              : in     std_logic;
i_C2_DATA            : in     std_logic_vector(IN_DATA_WIDTH-1 downto 0);

o_OUT_PCLK           : out    std_logic;
o_OUT_LV             : out    std_logic;
o_OUT_FV             : out    std_logic;
o_OUT_DATA           : out    std_logic_vector(IN_DATA_WIDTH-1 downto 0);

r_H_WIDTH            : in     std_logic_vector(16-1 downto 0);
r_V_HEIGHT           : in     std_logic_vector(16-1 downto 0);
r_PACK_OPT           : in     std_logic_vector(8-1 downto 0)
);
end component;


--signals----------------------------------------------------------------------
signal s_C1_LV_1d       : std_logic;
signal s_C1_FV_1d       : std_logic;
signal s_C1_DATA_1d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C1_LV_2d       : std_logic;
signal s_C1_FV_2d       : std_logic;
signal s_C1_DATA_2d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C1_LV_3d       : std_logic;
signal s_C1_FV_3d       : std_logic;
signal s_C1_DATA_3d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C1_LV_4d       : std_logic;
signal s_C1_FV_4d       : std_logic;
signal s_C1_DATA_4d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C1_LV_5d       : std_logic;
signal s_C1_FV_5d       : std_logic;
signal s_C1_DATA_5d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal CNT_C1_LVAL      : std_logic_vector(2-1 downto 0);

signal s_C1_DE_2CLK     : std_logic;

signal s_C1_LV_2pack       : std_logic;
signal s_C1_DE_2CLK_2pack  : std_logic;
signal s_C1_FV_2pack       : std_logic;
signal s_C1_DATA_2pack     : std_logic_vector(IN_DATA_WIDTH*2-1 downto 0);



signal s_C2_LV_1d       : std_logic;
signal s_C2_FV_1d       : std_logic;
signal s_C2_DATA_1d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C2_LV_2d       : std_logic;
signal s_C2_FV_2d       : std_logic;
signal s_C2_DATA_2d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C2_LV_3d       : std_logic;
signal s_C2_FV_3d       : std_logic;
signal s_C2_DATA_3d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C2_LV_4d       : std_logic;
signal s_C2_FV_4d       : std_logic;
signal s_C2_DATA_4d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal s_C2_LV_5d       : std_logic;
signal s_C2_FV_5d       : std_logic;
signal s_C2_DATA_5d     : std_logic_vector(IN_DATA_WIDTH-1 downto 0);

signal CNT_C2_LVAL      : std_logic_vector(2-1 downto 0);

signal s_C2_DE_2CLK     : std_logic;

signal s_C2_LV_2pack       : std_logic;
signal s_C2_DE_2CLK_2pack  : std_logic;
signal s_C2_FV_2pack       : std_logic;
signal s_C2_DATA_2pack     : std_logic_vector(IN_DATA_WIDTH*2-1 downto 0);



signal s_MERGED_LV      : std_logic;
signal s_MERGED_FV      : std_logic;
signal s_MERGED_DATA    : std_logic_vector(IN_DATA_WIDTH*2-1 downto 0);

signal s_OUT_LV         : std_logic;
signal s_OUT_FV         : std_logic;
signal s_OUT_DATA       : std_logic_vector(IN_DATA_WIDTH*2-1 downto 0);


begin

--waveforms--------------------------------------------------------------------
--lval length % 4 must be zero...
--i_C1_PCLK             : __ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้
--s_C1_LV_1d            : ________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--s_C1_LV_3d            : ____________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--s_C1_LV_4d            : __________________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--cnt_vid_lval_3t       : __________________________ก่0    ก่1    ก่2    ก่3    ก่4    ก่5    ก่6    ก่7    ก้___________________________
--CNT_C1_LVAL           : __________________________ก่0    ก่1    ก่2    ก่3    ก่0    ก่1    ก่2    ก่3    ก้___________________________
--s_C1_LV_5d            : ________________________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________

--s_C1_LV_2d            : ______________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--CNT_C1_LVAL           : ______________ก่0    ก่1    ก่2    ก่3    ก่0    ก่1    ก่2    ก่3    ก้___________________________
--s_C1_LV_3d            : ____________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--s_C1_DATA_2pack       :                           ก่ab         ก่cd
--s_C1_DE_2CLK          : __________________________ก่-----ก้_____ก่-----ก้_______________________
--end waveforms----------------------------------------------------------------


--C1 DATA packing--------------------------------------------------------------
--input video d flip flops
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_C1_LV_1d        <= i_C1_LV;
      s_C1_FV_1d        <= i_C1_FV;
      s_C1_DATA_1d      <= i_C1_DATA;

      s_C1_LV_2d        <= s_C1_LV_1d;
      s_C1_FV_2d        <= s_C1_FV_1d;
      s_C1_DATA_2d      <= s_C1_DATA_1d;

      s_C1_LV_3d        <= s_C1_LV_2d;
      s_C1_FV_3d        <= s_C1_FV_2d;
      s_C1_DATA_3d      <= s_C1_DATA_2d;

      s_C1_LV_4d        <= s_C1_LV_3d;
      s_C1_FV_4d        <= s_C1_FV_3d;
      s_C1_DATA_4d      <= s_C1_DATA_3d;

      s_C1_LV_5d        <= s_C1_LV_4d;
      s_C1_FV_5d        <= s_C1_FV_4d;
      s_C1_DATA_5d      <= s_C1_DATA_4d;
   end if;                 
end process;


--CNT_C1_LVAL
process(i_C1_PCLK)
begin
	if rising_edge(i_C1_PCLK) then
      if s_C1_LV_2d = '0' then
         CNT_C1_LVAL    <= (others=>'0');
      elsif s_C1_LV_2d = '1' then
         CNT_C1_LVAL    <= CNT_C1_LVAL +1;
      end if;
   end if;                 
end process;

--s_C1_DE_2CLK
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      if CNT_C1_LVAL(0) = '1' then
         s_C1_DE_2CLK   <= '1';
      else
         s_C1_DE_2CLK   <= '0';
      end if;
   end if;                 
end process;

--s_C1_DATA_2pack
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_C1_DATA_2pack   <= s_C1_DATA_2d & s_C1_DATA_3d;
   end if;                 
end process;
s_C1_LV_2pack           <= s_C1_LV_3d;
s_C1_DE_2CLK_2pack      <= s_C1_DE_2CLK;
s_C1_FV_2pack           <= s_C1_FV_3d;
--end C1 DATA packing----------------------------------------------------------

--C2 DATA packing--------------------------------------------------------------
--input video d flip flops
process(i_C2_PCLK)
begin
   if rising_edge(i_C2_PCLK) then
      s_C2_LV_1d        <= i_C2_LV;
      s_C2_FV_1d        <= i_C2_FV;
      s_C2_DATA_1d      <= i_C2_DATA;

      s_C2_LV_2d        <= s_C2_LV_1d;
      s_C2_FV_2d        <= s_C2_FV_1d;
      s_C2_DATA_2d      <= s_C2_DATA_1d;

      s_C2_LV_3d        <= s_C2_LV_2d;
      s_C2_FV_3d        <= s_C2_FV_2d;
      s_C2_DATA_3d      <= s_C2_DATA_2d;

      s_C2_LV_4d        <= s_C2_LV_3d;
      s_C2_FV_4d        <= s_C2_FV_3d;
      s_C2_DATA_4d      <= s_C2_DATA_3d;

      s_C2_LV_5d        <= s_C2_LV_4d;
      s_C2_FV_5d        <= s_C2_FV_4d;
      s_C2_DATA_5d      <= s_C2_DATA_4d;
   end if;                 
end process;


--CNT_C2_LVAL
process(i_C2_PCLK)
begin
	if rising_edge(i_C2_PCLK) then
      if s_C2_LV_2d = '0' then
         CNT_C2_LVAL    <= (others=>'0');
      elsif s_C2_LV_2d = '1' then
         CNT_C2_LVAL    <= CNT_C2_LVAL +1;
      end if;
   end if;                 
end process;

--s_C2_DE_2CLK
process(i_C2_PCLK)
begin
   if rising_edge(i_C2_PCLK) then
      if CNT_C2_LVAL(0) = '1' then
         s_C2_DE_2CLK   <= '1';
      else
         s_C2_DE_2CLK   <= '0';
      end if;
   end if;                 
end process;

--s_C2_DATA_2pack
process(i_C2_PCLK)
begin
   if rising_edge(i_C2_PCLK) then
      s_C2_DATA_2pack   <= s_C2_DATA_2d & s_C2_DATA_3d;
   end if;                 
end process;
s_C2_LV_2pack           <= s_C2_LV_3d;
s_C2_DE_2CLK_2pack      <= s_C2_DE_2CLK;
s_C2_FV_2pack           <= s_C2_FV_3d;
--end C1 DATA packing----------------------------------------------------------






--buffer video packing
video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing_u0 : video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing
generic map(
IN_DATA_WIDTH        => IN_DATA_WIDTH*2,
H_WIDTH              => H_WIDTH/2,
V_HEIGHT             => V_HEIGHT,
H_WIDTH_BIT          => H_WIDTH_BIT-1,
V_HEIGHT_BIT         => V_HEIGHT_BIT
)
Port map(
i_rst_n              => i_rst_n,

i_C1_PCLK            => i_C1_PCLK,
i_C1_LV              => s_C1_LV_2pack,
i_C1_DE_2CLK         => s_C1_DE_2CLK_2pack,
i_C1_FV              => s_C1_FV_2pack,
i_C1_DATA            => s_C1_DATA_2pack,

i_C2_PCLK            => i_C2_PCLK,
i_C2_LV              => s_C2_LV_2pack,
i_C2_DE_2CLK         => s_C2_DE_2CLK_2pack,
i_C2_FV              => s_C2_FV_2pack,
i_C2_DATA            => s_C2_DATA_2pack,

o_OUT_PCLK           => open,
o_OUT_LV             => s_MERGED_LV,
o_OUT_FV             => s_MERGED_FV,
o_OUT_DATA           => s_MERGED_DATA,

r_H_WIDTH            => r_H_WIDTH ,
r_V_HEIGHT           => r_V_HEIGHT,
r_PACK_OPT           => r_PACK_OPT
);

--outputs
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_OUT_LV       <= s_MERGED_LV;
      s_OUT_FV       <= s_MERGED_FV;
      s_OUT_DATA     <= s_MERGED_DATA;
   end if;                 
end process;

o_OUT_PCLK           <= i_C1_PCLK;
o_OUT_LV             <= s_OUT_LV;
o_OUT_FV             <= s_OUT_FV;
o_OUT_DATA           <= s_OUT_DATA;


end Behavioral;

