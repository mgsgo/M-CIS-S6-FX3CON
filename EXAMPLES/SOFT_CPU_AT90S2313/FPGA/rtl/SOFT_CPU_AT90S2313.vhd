----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo, mgsg.opensource@gmail.com
-- 
-- Create Date:    2019
-- Design Name:    SOFT_CPU_AT90S2313
-- Module Name:    FPGA - Behavioral 
-- Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
-- Target Devices: XC6SLX16-2FTG256
-- Tool versions:  ISE14.7
-- Description:    SOFT CPU core example AT90S2313 using opencores AX8
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity SOFT_CPU_AT90S2313 is
port(
--clk
i_clk_100mhz            : in     std_logic;      --100mhz

io_gpio                 : inout  std_logic_vector(8-1 downto 0);

io_led_D8               : inout  std_logic;
io_led_D9               : inout  std_logic;

UART_TX                 : out    std_logic;
UART_RX                 : in     std_logic
);
end SOFT_CPU_AT90S2313;

architecture Behavioral of SOFT_CPU_AT90S2313 is

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

component SHA1_PROG_TEST is
Port(
SERIAL_TX      : out std_logic;
SERIAL_RX      : in std_logic;
DS_WIRE        : inout std_logic;
FPGA_LS1_EN    : out std_logic;             
RESET          : in std_logic;
CLK_IN         : in std_logic
);
end component;

component BUFG is 
port (
I : in STD_LOGIC; 
O : out STD_LOGIC
); 
end component; 
component A90S2313 is
generic(
SyncReset : boolean := true;
TriState : boolean := false
);
port(
Clk      : in std_logic;
Reset_n  : in std_logic;
INT0     : in std_logic;
INT1     : in std_logic;
T0       : in std_logic;
T1       : in std_logic;
ICP      : in std_logic;
RXD      : in std_logic;
TXD      : out std_logic;
OC       : out std_logic;
Port_B   : inout std_logic_vector(7 downto 0);
Port_D   : inout std_logic_vector(7 downto 0)
);
end component;
--signals----------------------------------------------------------------------
signal s_clk_100mhz        : std_logic;
signal s_rst               : std_logic;
signal s_rst_n             : std_logic;
signal s_cnt_32bit         : std_logic_vector(32-1 downto 0);

signal s_clk_50mhz         : std_logic;
signal s_clk_50mhz_n       : std_logic;

signal s_clk_50mhz_gated   : std_logic;
signal A90S2313_PORT_D     : std_logic_vector(8-1 downto 0);


begin

--reset------------------------------------------------------------------------
--clock------------------------------------------------------------------------
--clock wizard, internal reset
clock_wizard_100mhz_input_u0 : clock_wizard_100mhz_input
port map(
CLK_IN1              => i_clk_100mhz,
CLK_OUT1             => s_clk_100mhz,
CLK_OUT2             => s_clk_50mhz,      --66.667MHz clock generate
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


--gpio-------------------------------------------------------------------------
io_gpio              <= s_cnt_32bit(24-1 downto 16);
--end gpio---------------------------------------------------------------------


--SOFT CPU AT90S2313
BUFG_50MHz : BUFG
port map(
I   => s_cnt_32bit(0),
O   => s_clk_50mhz_gated
); 
A90S2313_u0 : A90S2313
port map(
Clk         => s_clk_50mhz_gated,      --XC6SLX16-2FTG256C synthesize 85MHz, 50MHz gated clock use
Reset_n     => s_rst_n,
INT0        => '1',
INT1        => '1',
T0          => '1',
T1          => '1',
ICP         => '1',
RXD         => UART_RX,
TXD         => UART_TX,
OC          => open,
Port_B      => open,
Port_D      => A90S2313_PORT_D
);

--led--------------------------------------------------------------------------
io_led_D9            <= A90S2313_PORT_D(5);         --D9 high ON
io_led_D8            <= not A90S2313_PORT_D(6);     --D8 low ON
--end led----------------------------------------------------------------------


end Behavioral;

