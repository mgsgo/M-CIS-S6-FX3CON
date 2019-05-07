----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo, mgsg.opensource@gmail.com
-- 
-- Create Date:    2017
-- Design Name:    SHA1_AUTHENTICATION
-- Module Name:    FPGA - Behavioral 
-- Project Name:   MGSG-CIS-S6-FX3CON_EXAMPLE
-- Target Devices: XC6SLX16-2FTG256
-- Tool versions:  ISE14.7
-- Description:    LED blink is the simplest example for M-CIS-S6-FX3CON, toggle LED D8/D9 
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

entity SHA1_AUTHENTICATION is
port(
--clk
i_clk_100mhz            : in     std_logic;      --100mhz

io_gpio                 : inout  std_logic_vector(8-1 downto 0);

io_led_D8               : inout  std_logic;
io_led_D9               : inout  std_logic;

io_DS28E01P             : inout  std_logic;
UART_TX                 : out    std_logic;
UART_RX                 : in     std_logic
);
end SHA1_AUTHENTICATION;

architecture Behavioral of SHA1_AUTHENTICATION is

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

--signals----------------------------------------------------------------------
signal s_clk_100mhz        : std_logic;
signal s_rst               : std_logic;
signal s_rst_n             : std_logic;
signal s_cnt_32bit         : std_logic_vector(32-1 downto 0);

signal s_clk_66mhz         : std_logic;
signal s_clk_66mhz_n       : std_logic;

begin

--reset------------------------------------------------------------------------
--clock------------------------------------------------------------------------
--clock wizard, internal reset
clock_wizard_100mhz_input_u0 : clock_wizard_100mhz_input
port map(
CLK_IN1              => i_clk_100mhz,
CLK_OUT1             => s_clk_100mhz,
CLK_OUT2             => s_clk_66mhz,      --66.667MHz clock generate
RESET                => '0',
LOCKED               => s_rst_n
);
s_rst                <= not s_rst_n;
s_clk_66mhz_n        <= not s_clk_66mhz;
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


--SHA1_PROG_TEST
SHA1_PROG_TEST_u0 : SHA1_PROG_TEST
Port map(
SERIAL_TX         => UART_TX,
SERIAL_RX         => UART_RX,
DS_WIRE           => io_DS28E01P,
FPGA_LS1_EN       => open,
RESET             => s_rst,
CLK_IN            => s_clk_66mhz
);


end Behavioral;

