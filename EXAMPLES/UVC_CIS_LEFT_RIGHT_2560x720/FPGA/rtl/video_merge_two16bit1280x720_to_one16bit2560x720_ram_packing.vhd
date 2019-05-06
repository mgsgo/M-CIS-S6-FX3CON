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

entity video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing is
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
end video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing;

architecture Behavioral of video_merge_two16bit1280x720_to_one16bit2560x720_ram_packing is

--components-------------------------------------------------------------------
component ram_dual
generic(
DATA_WIDTH        : positive;
ADDR_WIDTH        : positive;
NUMWORDS          : positive
);
port(
clock1            : in     std_logic;
clock2            : in     std_logic;
data              : in     std_logic_vector(DATA_WIDTH -1 downto 0);
write_address     : in     std_logic_vector(ADDR_WIDTH -1 downto 0);
read_address      : in     std_logic_vector(ADDR_WIDTH -1 downto 0);
we                : in     std_logic;
q                 : out    std_logic_vector(DATA_WIDTH -1 downto 0)
);
end component;

--constants
constant RAM_DUAL_DATA_WIDTH  : integer :=IN_DATA_WIDTH;
constant RAM_DUAL_ADDR_WIDTH  : integer :=H_WIDTH_BIT +2;   --+1 2line bud, +2 4line buf
constant RAM_DUAL_NUMWORDS    : integer :="**"(2, RAM_DUAL_ADDR_WIDTH);

constant PIXEL_CNT_WR_WIDTH   : integer :=H_WIDTH_BIT;
constant PIXEL_CNT_RD_WIDTH   : integer :=H_WIDTH_BIT +2;
constant LINE_CNT_WIDTH       : integer :=V_HEIGHT_BIT;

--signals----------------------------------------------------------------------
signal s_x_width_x1           : std_logic_vector(16-1 downto 0);
signal s_x_width_x2           : std_logic_vector(16-1 downto 0);


signal s_C1_LV_1d             : std_logic;
signal s_C1_DE_2CLK_1d        : std_logic;
signal s_C1_FV_1d             : std_logic;
signal s_C1_DATA_1d           : std_logic_vector(IN_DATA_WIDTH-1 downto 0);
signal s_C1_LV_Rpulse_0d      : std_logic;
signal s_C1_LV_Fpulse_0d      : std_logic;
signal s_C1_FV_Rpulse_0d      : std_logic;

signal CNT_C1_pixel           : std_logic_vector(PIXEL_CNT_WR_WIDTH -1 downto 0);
signal CNT_C1_line            : std_logic_vector(LINE_CNT_WIDTH -1 downto 0);

signal s_C1_RAM_WR_en         : std_logic;
signal s_C1_RAM_HADDR         : std_logic_vector(2-1 downto 0);
signal s_C1_RAM_WR_addr       : std_logic_vector(RAM_DUAL_ADDR_WIDTH-1 downto 0);
signal s_C1_RAM_RD_addr       : std_logic_vector(RAM_DUAL_ADDR_WIDTH-1 downto 0);

signal CNT_C1_RD_pixel        : std_logic_vector(PIXEL_CNT_RD_WIDTH -1 downto 0);
signal CNT_C1_RD_addr         : std_logic_vector(PIXEL_CNT_WR_WIDTH -1 downto 0);

signal s_C1_RAM_RD_en         : std_logic;
signal s_C1C2_RAM_RD_en       : std_logic;

signal s_C1_RAM_RD_DATA       : std_logic_vector(RAM_DUAL_DATA_WIDTH-1 downto 0);




signal s_C2_LV_1d             : std_logic;
signal s_C2_DE_2CLK_1d        : std_logic;
signal s_C2_FV_1d             : std_logic;
signal s_C2_DATA_1d           : std_logic_vector(IN_DATA_WIDTH-1 downto 0);
signal s_C2_LV_Rpulse_0d      : std_logic;
signal s_C2_LV_Fpulse_0d      : std_logic;
signal s_C2_FV_Rpulse_0d      : std_logic;

signal CNT_C2_pixel           : std_logic_vector(PIXEL_CNT_WR_WIDTH -1 downto 0);
signal CNT_C2_line            : std_logic_vector(LINE_CNT_WIDTH -1 downto 0);

signal s_C2_RAM_WR_en         : std_logic;
signal s_C2_RAM_HADDR         : std_logic_vector(2-1 downto 0);
signal s_C2_RAM_WR_addr       : std_logic_vector(RAM_DUAL_ADDR_WIDTH-1 downto 0);
signal s_C2_RAM_RD_addr       : std_logic_vector(RAM_DUAL_ADDR_WIDTH-1 downto 0);

signal s_C2_RAM_RD_DATA       : std_logic_vector(RAM_DUAL_DATA_WIDTH-1 downto 0);



signal s_C1_LV_2d             : std_logic;
signal s_C1_LV_3d             : std_logic;
signal s_C1_LV_4d             : std_logic;

signal s_C1_DE_2CLK_2d        : std_logic;
signal s_C1_DE_2CLK_3d        : std_logic;
signal s_C1_DE_2CLK_4d        : std_logic;

signal s_C1_FV_2d             : std_logic;
signal s_C1_FV_3d             : std_logic;
signal s_C1_FV_2d_1dLINE      : std_logic;
signal s_C1_FV_2d_1dLINE_1d   : std_logic;
signal s_C1_FV_2d_1dLINE_2d   : std_logic;
signal s_C1_FV_2d_1dLINE_3d   : std_logic;

signal s_C1_FV_2d_2dLINE      : std_logic;
signal s_C1_FV_2d_2dLINE_1d   : std_logic;
signal s_C1_FV_2d_2dLINE_2d   : std_logic;
signal s_C1_FV_2d_2dLINE_3d   : std_logic;

signal s_C1_RAM_RD_en_1d      : std_logic;
signal s_C1_RAM_RD_en_2d      : std_logic;
signal s_C1_RAM_RD_en_3d      : std_logic;

signal s_C1C2_RAM_RD_en_1d    : std_logic;
signal s_C1C2_RAM_RD_en_2d    : std_logic;
signal s_C1C2_RAM_RD_en_3d    : std_logic;

signal s_RAM_RD_DATA_mux      : std_logic_vector(RAM_DUAL_DATA_WIDTH-1 downto 0);
signal s_RAM_RD_DATA_mux_1d   : std_logic_vector(RAM_DUAL_DATA_WIDTH-1 downto 0);


signal s_OUT_LV               : std_logic;
signal s_OUT_FV               : std_logic;
signal s_OUT_DATA             : std_logic_vector(IN_DATA_WIDTH-1 downto 0);


begin

--x_width calculation----------------------------------------------------------
s_x_width_x1         <= '0' & r_H_WIDTH(16-1 downto 1);     --16bit
                        --1280 pixels = 1280/2 clk
s_x_width_x2         <= s_x_width_x1 + s_x_width_x1;        --16bit *2
                        --2560 pixels = 1280 clk
--end x_width calculation------------------------------------------------------


--waveforms--------------------------------------------------------------------
--i_C1_PCLK                : __ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้__ก่--ก้
--i_C1_LV                  : ________________________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--s_C1_LV_1d               : ______________________________________ก่a-----b-----c-----d-----e-----f-----g-----h----ก้___________________________
--write---------------------
--s_C1_LV_Fpulse_0d        : ________________________________ก่-----ก้______________________________________________________________________
--CNT_C1_pixel             :                                       ก่0          ก่1                      ก่2  
--s_C1_DATA_1d             :                                             ก่abcd                   ก่efgh
--s_C1_RAM_WR_en           : ____________________________________________ก่-----ก้_________________ก่-----ก้_______________________
--read----------------------
--CNT_C1_RD_pixel          :                                       ก่0    ก่1    ก่2    ก่3
--CNT_C1_RD_addr           :                                       ก่0    ก่1    ก่2    ก่3
--s_C1_RAM_RD_en           : ______________________________________ก่-----------------------------------------------ก้___________________________
--s_C1_RAM_RD_en_1d        : ____________________________________________ก่-----------------------------------------------ก้___________________________
--s_C1_RAM_RD_en_2d        : __________________________________________________ก่-----------------------------------------------ก้___________________________
--s_C1_RAM_RD_en_3d        : ________________________________________________________ก่-----------------------------------------------ก้___________________________
--s_C1_RAM_RD_DATA         :                                                   ก่0    ก่1    ก่2     
--s_RAM_RD_DATA_mux        :                                                         ก่0    ก่1    ก่2     
--s_OUT_DATA               :                                                               ก่0    ก่1    ก่2     
--s_OUT_LV                 : ________________________________________________________ก่-----------------------------------------------ก้___________________________
--end waveforms----------------------------------------------------------------


--C1_RAM-----------------------------------------------------------------------
--input video d flip flops
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_C1_LV_1d        <= i_C1_LV;
      s_C1_DE_2CLK_1d   <= i_C1_DE_2CLK;
      s_C1_FV_1d        <= i_C1_FV;
      s_C1_DATA_1d      <= i_C1_DATA;
   end if;
end process;

--s_C1_LV_Rpulse_0d
s_C1_LV_Rpulse_0d    <= i_C1_LV and (not s_C1_LV_1d);

--s_C1_LV_Fpulse_0d
s_C1_LV_Fpulse_0d    <= (not i_C1_LV) and s_C1_LV_1d;

--s_C1_FV_Rpulse_0d
s_C1_FV_Rpulse_0d    <= i_C1_FV and (not s_C1_FV_1d);

--CNT_C1_pixel
process(i_rst_n, i_C1_PCLK, s_C1_LV_1d)
begin
   if i_rst_n = '0' then
      CNT_C1_pixel      <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
   elsif rising_edge(i_C1_PCLK) then
      if s_C1_LV_Rpulse_0d = '1' then
         CNT_C1_pixel   <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
      elsif (s_C1_LV_1d and s_C1_DE_2CLK_1d) = '1' then
         CNT_C1_pixel   <= CNT_C1_pixel + 1;
      end if;
   end if;
end process;

--CNT_C1_line
process(i_rst_n, i_C1_PCLK, s_C1_LV_1d, s_C1_FV_1d)
begin
   if i_rst_n = '0' then
      CNT_C1_line       <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-1;
   elsif rising_edge(i_C1_PCLK) then
      if s_C1_FV_Rpulse_0d = '1' then
         if s_C1_LV_Rpulse_0d = '1' then
            CNT_C1_line    <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-0;
         else
            CNT_C1_line    <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-1;
         end if;
      elsif s_C1_LV_Rpulse_0d = '1' then
         CNT_C1_line       <= CNT_C1_line + 1;
      end if;
   end if;
end process;


--C1_RAM_WRITE---------------------------------------------
--gen s_C1_RAM_WR_en
s_C1_RAM_WR_en       <= (s_C1_LV_1d and s_C1_DE_2CLK_1d) and s_C1_FV_1d;

--gen s_C1_RAM_HADDR
s_C1_RAM_HADDR       <= CNT_C1_line(1 downto 0);

--gen s_C1_RAM_WR_addr
s_C1_RAM_WR_addr     <= s_C1_RAM_HADDR & CNT_C1_pixel;
--end C1_RAM_WRITE-----------------------------------------

--CNT_C1_RD_pixel
process(i_rst_n, i_C1_PCLK)
begin
   if i_rst_n = '0' then
      CNT_C1_RD_pixel   <= conv_std_logic_vector(0, PIXEL_CNT_RD_WIDTH);
      CNT_C1_RD_addr    <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
      s_C1_RAM_RD_en    <= '0';
      s_C1C2_RAM_RD_en  <= '0';
   elsif rising_edge(i_C1_PCLK) then
      if s_C1_LV_Rpulse_0d = '1' then
         CNT_C1_RD_pixel   <= conv_std_logic_vector(0, PIXEL_CNT_RD_WIDTH);
         CNT_C1_RD_addr    <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
         s_C1_RAM_RD_en    <= '1';     --C1_RAM read start
         s_C1C2_RAM_RD_en  <= '1';     --C1C2_RAM read start
      elsif s_C1_LV_1d  = '1' then
         CNT_C1_RD_pixel   <= CNT_C1_RD_pixel + 1;
         CNT_C1_RD_addr    <= CNT_C1_RD_addr + 1;
         if    CNT_C1_RD_pixel = s_x_width_x1(PIXEL_CNT_RD_WIDTH-1 downto 0) -1 then
            CNT_C1_RD_addr    <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
            s_C1_RAM_RD_en    <= '0';  --C1_RAM read end
            s_C1C2_RAM_RD_en  <= '1';
         elsif CNT_C1_RD_pixel = s_x_width_x2(PIXEL_CNT_RD_WIDTH-1 downto 0) -1 then
            CNT_C1_RD_addr    <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
            s_C1_RAM_RD_en    <= '0';
            s_C1C2_RAM_RD_en  <= '0';  --C1C2_RAM read end
         end if;
      end if;
   end if;
end process;
   
--C1_RAM_EAD-----------------------------------------------
--s_C1_RAM_RD_addr
s_C1_RAM_RD_addr      <= (s_C1_RAM_HADDR -2) & CNT_C1_RD_addr;
--end C1_RAM_READ------------------------------------------

--RAM------------------------------------------------------
ram_dual_C1 : ram_dual
generic map(
DATA_WIDTH        => RAM_DUAL_DATA_WIDTH,
ADDR_WIDTH        => RAM_DUAL_ADDR_WIDTH,
NUMWORDS          => RAM_DUAL_NUMWORDS
)
port map(
clock1            => i_C1_PCLK,     --write clk
clock2            => i_C1_PCLK,     --read clk
data              => s_C1_DATA_1d,
write_address     => s_C1_RAM_WR_addr,
read_address      => s_C1_RAM_RD_addr,
we                => s_C1_RAM_WR_en,
q                 => s_C1_RAM_RD_DATA
);
--end RAM--------------------------------------------------
--end C1_RAM-------------------------------------------------------------------


--C2_RAM-----------------------------------------------------------------------
--iinput video d flip flops
process(i_C2_PCLK)
begin
   if rising_edge(i_C2_PCLK) then
      s_C2_LV_1d        <= i_C2_LV;
      s_C2_DE_2CLK_1d   <= i_C2_DE_2CLK;
      s_C2_FV_1d        <= i_C2_FV;
      s_C2_DATA_1d      <= i_C2_DATA;
   end if;
end process;

--s_C2_LV_Rpulse_0d
s_C2_LV_Rpulse_0d    <= i_C2_LV and (not s_C2_LV_1d);

--s_C2_LV_Fpulse_0d
s_C2_LV_Fpulse_0d    <= (not i_C2_LV) and s_C2_LV_1d;

--s_C2_FV_Rpulse_0d
s_C2_FV_Rpulse_0d    <= i_C2_FV and (not s_C2_FV_1d);

--CNT_C2_pixel
process(i_rst_n, i_C2_PCLK, s_C2_LV_1d)
begin
   if i_rst_n = '0' then
      CNT_C2_pixel      <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
   elsif rising_edge(i_C2_PCLK) then
      if s_C2_LV_Rpulse_0d = '1' then
         CNT_C2_pixel   <= conv_std_logic_vector(0, PIXEL_CNT_WR_WIDTH);
      elsif (s_C2_LV_1d and s_C2_DE_2CLK_1d) = '1' then
         CNT_C2_pixel   <= CNT_C2_pixel + 1;
      end if;
   end if;
end process;

--CNT_C2_line
process(i_rst_n, i_C2_PCLK, s_C2_LV_1d, s_C2_FV_1d)
begin
   if i_rst_n = '0' then
      CNT_C2_line       <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-1;
   elsif rising_edge(i_C2_PCLK) then
      if s_C2_FV_Rpulse_0d = '1' then
         if s_C2_LV_Rpulse_0d = '1' then
            CNT_C2_line    <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-0;
         else
            CNT_C2_line    <= conv_std_logic_vector(0, LINE_CNT_WIDTH)-1;
         end if;
      elsif s_C2_LV_Rpulse_0d = '1' then
         CNT_C2_line       <= CNT_C2_line + 1;
      end if;
   end if;
end process;


--C2_RAM_WRITE---------------------------------------------
--gen s_C2_RAM_WR_en
s_C2_RAM_WR_en       <= (s_C2_LV_1d and s_C2_DE_2CLK_1d) and s_C2_FV_1d;
--s_C2_RAM_WR_en <= s_C1_RAM_WR_en;
--gen s_C2_RAM_HADDR
s_C2_RAM_HADDR       <= CNT_C2_line(1 downto 0);

--gen s_C2_RAM_WR_addr
s_C2_RAM_WR_addr     <= s_C2_RAM_HADDR & CNT_C2_pixel;
--s_C2_RAM_WR_addr <= s_C1_RAM_WR_addr;
--end C2_RAM_WRITE-----------------------------------------

--C2_RAM_EAD-----------------------------------------------
--s_C2_RAM_RD_addr
s_C2_RAM_RD_addr      <= s_C1_RAM_RD_addr;   --use C1_RAM control
--end C2_RAM_READ------------------------------------------

--RAM------------------------------------------------------
ram_dual_C2 : ram_dual
generic map(
DATA_WIDTH        => RAM_DUAL_DATA_WIDTH,
ADDR_WIDTH        => RAM_DUAL_ADDR_WIDTH,
NUMWORDS          => RAM_DUAL_NUMWORDS
)
port map(
clock1            => i_C2_PCLK,     --write clk
clock2            => i_C1_PCLK,     --read clk
data              => s_C2_DATA_1d,
write_address     => s_C2_RAM_WR_addr,
read_address      => s_C2_RAM_RD_addr,
we                => s_C2_RAM_WR_en,
q                 => s_C2_RAM_RD_DATA
);
--end RAM--------------------------------------------------
--end C2_RAM-------------------------------------------------------------------



--additional delays------------------------------------------------------------
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_C1_LV_2d           <= s_C1_LV_1d;
      s_C1_LV_3d           <= s_C1_LV_2d;
      s_C1_LV_4d           <= s_C1_LV_3d;

      s_C1_FV_2d           <= s_C1_FV_1d;
      s_C1_FV_3d           <= s_C1_FV_2d;

      s_C1_DE_2CLK_2d      <= s_C1_DE_2CLK_1d;
      s_C1_DE_2CLK_3d      <= s_C1_DE_2CLK_2d;
      s_C1_DE_2CLK_4d      <= s_C1_DE_2CLK_3d;

      s_C1_RAM_RD_en_1d    <= s_C1_RAM_RD_en;
      s_C1_RAM_RD_en_2d    <= s_C1_RAM_RD_en_1d;
      s_C1_RAM_RD_en_3d    <= s_C1_RAM_RD_en_2d;

      s_C1C2_RAM_RD_en_1d  <= s_C1C2_RAM_RD_en;
      s_C1C2_RAM_RD_en_2d  <= s_C1C2_RAM_RD_en_1d;
      s_C1C2_RAM_RD_en_3d  <= s_C1C2_RAM_RD_en_2d;
   end if;
end process;

--s_C1_FV_2d_1dLINE
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      if s_C1_LV_Fpulse_0d = '1' then
         s_C1_FV_2d_1dLINE    <= s_C1_FV_2d;
         s_C1_FV_2d_2dLINE    <= s_C1_FV_2d_1dLINE;
      end if;
   end if;
end process;

--s_C1_FV_2d_1dLINE_1d
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      s_C1_FV_2d_1dLINE_1d   <= s_C1_FV_2d_1dLINE;
      s_C1_FV_2d_1dLINE_2d   <= s_C1_FV_2d_1dLINE_1d;
      s_C1_FV_2d_1dLINE_3d   <= s_C1_FV_2d_1dLINE_2d;

      s_C1_FV_2d_2dLINE_1d   <= s_C1_FV_2d_2dLINE;
      s_C1_FV_2d_2dLINE_2d   <= s_C1_FV_2d_2dLINE_1d;
      s_C1_FV_2d_2dLINE_3d   <= s_C1_FV_2d_2dLINE_2d;
   end if;
end process;
--end additional delays--------------------------------------------------------

--s_RAM_RD_DATA_mux and delay--------------------------------------------------
--s_RAM_RD_DATA_mux
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      if    CNT_C1_RD_pixel   <  s_x_width_x1(PIXEL_CNT_RD_WIDTH-1 downto 0) -0 then      --CAM1 end
         s_RAM_RD_DATA_mux       <= s_C1_RAM_RD_DATA;
      elsif CNT_C1_RD_pixel   =  s_x_width_x1(PIXEL_CNT_RD_WIDTH-1 downto 0) -0 then      --CAM1 end
         s_RAM_RD_DATA_mux       <= s_C1_RAM_RD_DATA;--x"8000";

      elsif CNT_C1_RD_pixel   <  s_x_width_x2(PIXEL_CNT_RD_WIDTH-1 downto 0) -0 then      --CAM12 end
         s_RAM_RD_DATA_mux       <= s_C2_RAM_RD_DATA;
      elsif CNT_C1_RD_pixel   = s_x_width_x2(PIXEL_CNT_RD_WIDTH-1 downto 0) -0 then      --CAM12 end
         s_RAM_RD_DATA_mux       <= s_C2_RAM_RD_DATA;--x"8000";
      end if;

      s_RAM_RD_DATA_mux_1d       <= s_RAM_RD_DATA_mux;
   end if;
end process;
--end s_RAM_RD_DATA_mux and delay----------------------------------------------


--output selection-------------------------------------------------------------
process(i_C1_PCLK)
begin
   if rising_edge(i_C1_PCLK) then
      if    r_PACK_OPT = 1 then      --C1 packed output
         s_OUT_LV          <= s_C1_RAM_RD_en_2d;
         s_OUT_FV          <= s_C1_FV_2d_2dLINE_3d;
         s_OUT_DATA        <= s_RAM_RD_DATA_mux;
      elsif r_PACK_OPT = 2 then      --C1C2 merge packed output
         s_OUT_LV          <= s_C1C2_RAM_RD_en_2d;
         s_OUT_FV          <= s_C1_FV_2d_2dLINE_3d;
         s_OUT_DATA        <= s_RAM_RD_DATA_mux;
      end if;
   end if;
end process;
--end output selection---------------------------------------------------------

o_OUT_PCLK                 <= i_C1_PCLK;
o_OUT_LV                   <= s_OUT_LV;
o_OUT_FV                   <= s_OUT_FV;
o_OUT_DATA                 <= s_OUT_DATA;

end Behavioral;

