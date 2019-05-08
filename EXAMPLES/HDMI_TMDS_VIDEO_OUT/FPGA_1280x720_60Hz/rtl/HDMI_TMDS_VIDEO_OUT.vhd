----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo, mgsg.opensource@gmail.com
-- 
-- Create Date:    2019
-- Design Name:    HDMI_TMDS_VIDEO_OUT
-- Module Name:    FPGA - Behavioral 
-- Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
-- Target Devices: XC6SLX16-2FTG256
-- Tool versions:  ISE14.7
-- Description:    Example of UVC(Universal Video Class) camera using 1 image sensor(MT9M114)
-- License:        BSD 2-Clause
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

entity HDMI_TMDS_VIDEO_OUT is
port(
--clk
i_clk_100mhz            : in     std_logic;      --100mhz

io_gpio                 : inout  std_logic_vector(8-1 downto 0);

io_led_D8               : inout  std_logic;
io_led_D9               : inout  std_logic;

o_clk_50mhz             : out    std_logic;
i_clk_50mhz             : in     std_logic;

HDMI_CLKp               : out    std_logic;
HDMI_CLKn               : out    std_logic;
HDMI_Dp                 : out    std_logic_vector(3-1 downto 0);
HDMI_Dn                 : out    std_logic_vector(3-1 downto 0)
);
end HDMI_TMDS_VIDEO_OUT;

architecture Behavioral of HDMI_TMDS_VIDEO_OUT is

--components-------------------------------------------------------------------
component clock_wizard_100mhz_input
port
(-- Clock in ports
CLK_IN1                 : in     std_logic;  -- Clock out ports
CLK_OUT1                : out    std_logic;  -- Status and control signals
CLK_OUT2                : out    std_logic;  -- Status and control signals
--CLK_OUT3                : out    std_logic;  -- Status and control signals
--CLK_OUT4                : out    std_logic;  -- Status and control signals
--CLK_OUT5                : out    std_logic;  -- Status and control signals
--CLK_OUT6                : out    std_logic;  -- Status and control signals
--CLK_OUT7                : out    std_logic;  -- Status and control signals
--CLK_OUT8                : out    std_logic;  -- Status and control signals
RESET                   : in     std_logic;
LOCKED                  : out    std_logic
);
end component;

component ODDR2
generic(
DDR_ALIGNMENT  : string := "NONE";
INIT           : bit    := '0';
SRTYPE         : string := "SYNC"
);
port(
Q              : out std_ulogic;
C0             : in  std_ulogic;
C1             : in  std_ulogic;
CE             : in  std_ulogic := 'H';
D0             : in  std_ulogic;
D1             : in  std_ulogic;
R              : in  std_ulogic := 'L';
S              : in  std_ulogic := 'L'
);
end component;

component dvid_serdes is
port(
clk50             : in     std_logic;
tmds_out_p        : out    std_logic_vector(4-1 downto 0);
tmds_out_n        : out    std_logic_vector(4-1 downto 0)
);
end component;

--signals----------------------------------------------------------------------
signal s_clk_100mhz        : std_logic;
signal s_rst               : std_logic;
signal s_rst_n             : std_logic;
signal s_cnt_32bit         : std_logic_vector(32-1 downto 0);

signal s_clk_50mhz         : std_logic;
signal s_clk_50mhz_n       : std_logic;

signal s_tmds_out_p        : std_logic_vector(4-1 downto 0);
signal s_tmds_out_n        : std_logic_vector(4-1 downto 0);

begin

--reset------------------------------------------------------------------------
--clock------------------------------------------------------------------------
--clock wizard, internal reset
clock_wizard_100mhz_input_u0 : clock_wizard_100mhz_input
port map(
CLK_IN1              => i_clk_100mhz,
CLK_OUT1             => s_clk_100mhz,
CLK_OUT2             => s_clk_50mhz,      --50MHz clock generate
RESET                => '0',
LOCKED               => s_rst_n
);
s_rst                <= not s_rst_n;
s_clk_50mhz_n        <= not s_clk_50mhz;
--end clock--------------------------------------------------------------------


--test counter-----------------------------------------------------------------
process(s_rst_n, s_clk_100mhz)
begin
	if s_rst_n = '0' then
		s_cnt_32bit       <= (others=>'0');
	elsif rising_edge(s_clk_100mhz) then
		s_cnt_32bit       <= s_cnt_32bit +1;
	end if;
end process;
--end test counter-------------------------------------------------------------


--led--------------------------------------------------------------------------
io_led_D8            <= not s_cnt_32bit(24);          --D8 low ON
io_led_D9            <= not(s_cnt_32bit(24));         --D9 high ON
--end led----------------------------------------------------------------------

--gpio-------------------------------------------------------------------------
io_gpio              <= s_cnt_32bit(24-1 downto 16);
--end gpio---------------------------------------------------------------------


--dvid_serdes use(http://hamsterworks.co.nz/mediawiki/index.php/DVI-D_Serdes)------------
--50mhz output use ODDR2(SPARTAN6)
ODDR2_C1_MCLK : ODDR2
generic map(DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC")
port map(
Q           => o_clk_50mhz,       --port
C0          => s_clk_50mhz,      --output
C1          => s_clk_50mhz_n,    --not output
CE          => '1', D0 => '1', D1 => '0', R => '0', S => '0');

dvid_serdes_u0 : dvid_serdes
port map(
clk50             => i_clk_50mhz,
tmds_out_p        => s_tmds_out_p,
tmds_out_n        => s_tmds_out_n
);

HDMI_Dp(0)        <= s_tmds_out_p(0);
HDMI_Dn(0)        <= s_tmds_out_n(0);
HDMI_Dp(1)        <= s_tmds_out_p(1);
HDMI_Dn(1)        <= s_tmds_out_n(1);
HDMI_Dp(2)        <= s_tmds_out_p(2);
HDMI_Dn(2)        <= s_tmds_out_n(2);
HDMI_CLKp         <= s_tmds_out_p(3);
HDMI_CLKn         <= s_tmds_out_n(3);
--end dvid_serdes use(http://hamsterworks.co.nz/mediawiki/index.php/DVI-D_Serdes)--------


end Behavioral;

