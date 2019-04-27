----------------------------------------------------------------------------------
-- Company:        MGSG
-- Engineer:       jhyoo
-- 
-- Create Date:    2017
-- Design Name:    CIS_BYPASS_LEFT_1280x720
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

entity CIS_BYPASS_LEFT_1280x720 is
port(
--clk
i_clk_100mhz            : in     std_logic;      --100mhz

io_gpio                 : inout  std_logic_vector(8-1 downto 0);

io_led_D8               : inout  std_logic;
io_led_D9               : inout  std_logic;

--CIS1
io_C1_PCLK              : inout  std_logic;
io_C1_FV                : inout  std_logic;
io_C1_LV                : inout  std_logic;
io_C1_DATA              : inout  std_logic_vector(8-1 downto 0);
io_C1_SCL               : inout  std_logic;
io_C1_SDA               : inout  std_logic;
io_C1_RESETn            : inout  std_logic;
io_C1_MCLK              : inout  std_logic;
io_C1_FLASH             : inout  std_logic;
io_C1_SADDR             : inout  std_logic;

--CIS2
io_C2_PCLK              : inout  std_logic;
io_C2_FV                : inout  std_logic;
io_C2_LV                : inout  std_logic;
io_C2_DATA              : inout  std_logic_vector(8-1 downto 0);
io_C2_SCL               : inout  std_logic;
io_C2_SDA               : inout  std_logic;
io_C2_RESETn            : inout  std_logic;
io_C2_MCLK              : inout  std_logic;
io_C2_FLASH             : inout  std_logic;
io_C2_SADDR             : inout  std_logic;

--FX3
io_fx3_PCLK             : inout  std_logic;
io_fx3_DQ               : inout  std_logic_vector(32-1 downto 0);
io_fx3_CTL              : inout  std_logic_vector(13-1 downto 0);
io_fx3_INT_N_CTL15      : inout  std_logic;
io_fx3_i2c_sda          : inout  std_logic;
io_fx3_i2c_scl          : inout  std_logic;
io_fx3_spi_mosi_uart_rx : inout  std_logic;
io_fx3_spi_miso_uart_tx : inout  std_logic;
io_fx3_spi_ssn_uart_cts : inout  std_logic;
io_fx3_spi_sck_uart_rts : inout  std_logic;
io_fx3_GPIO45           : inout  std_logic
);
end CIS_BYPASS_LEFT_1280x720;

architecture Behavioral of CIS_BYPASS_LEFT_1280x720 is

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

--signals----------------------------------------------------------------------
signal s_clk_100mhz        : std_logic;
signal s_rst               : std_logic;
signal s_rst_n             : std_logic;
signal s_cnt_32bit         : std_logic_vector(32-1 downto 0);

signal s_clk_24mhz         : std_logic;
signal s_clk_24mhz_n       : std_logic;

--CIS1
signal i_C1_FV             : std_logic;
signal i_C1_LV             : std_logic;
signal i_C1_DATA           : std_logic_vector(8-1 downto 0);
signal s_C1_FV_1d          : std_logic;
signal s_C1_LV_1d          : std_logic;
signal s_C1_DATA_1d        : std_logic_vector(8-1 downto 0);
signal s_C1_FV_2d          : std_logic;
signal s_C1_LV_2d          : std_logic;
signal s_C1_DATA_2d        : std_logic_vector(8-1 downto 0);

--CIS2
signal s_C2_FV_1d          : std_logic;
signal s_C2_LV_1d          : std_logic;
signal s_C2_DATA_1d        : std_logic_vector(8-1 downto 0);
signal s_C2_FV_2d          : std_logic;
signal s_C2_LV_2d          : std_logic;
signal s_C2_DATA_2d        : std_logic_vector(8-1 downto 0);

--FX3
signal s_FX3_PCLK          : std_logic;
signal s_FX3_PCLK_n        : std_logic;

begin

--reset------------------------------------------------------------------------
--clock------------------------------------------------------------------------
--clock wizard, internal reset
clock_wizard_100mhz_input_u0 : clock_wizard_100mhz_input
port map(
CLK_IN1              => i_clk_100mhz,
CLK_OUT1             => s_clk_100mhz,
CLK_OUT2             => s_clk_24mhz,      --24MHz clock generate
RESET                => '0',
LOCKED               => s_rst_n
);
s_rst                <= not s_rst_n;
s_clk_24mhz_n        <= not s_clk_24mhz;
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


--CIS to FX3 bypass------------------------------------------------------------
--CIS1 control and input video D flip flops
io_C1_RESETn         <= '1';
io_C1_SADDR          <= '0';   --SADDR=0 : I2C Addr --> 0x90 (default)
                               --SADDR=1 : I2C Addr --> 0xBA
--MCLK output use ODDR2(SPARTAN6)
ODDR2_C1_MCLK : ODDR2
generic map(DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC")
port map(
Q           => io_C1_MCLK,       --port
C0          => s_clk_24mhz,      --output
C1          => s_clk_24mhz_n,    --not output
CE          => '1', D0 => '1', D1 => '0', R => '0', S => '0');
--input video d flip flops
process(io_C1_PCLK)
begin
   if rising_edge(io_C1_PCLK) then
      --1st stage D flip flops
      s_C1_FV_1d        <= io_C1_FV;
      s_C1_LV_1d        <= io_C1_LV;
      s_C1_DATA_1d      <= io_C1_DATA;
      --2nd stage D flip flops
      s_C1_FV_2d        <= s_C1_FV_1d;
      s_C1_LV_2d        <= s_C1_LV_1d;
      s_C1_DATA_2d      <= s_C1_DATA_1d;
   end if;
end process;

--CIS1 control and input video D flip flops
io_C2_RESETn         <= '1';
io_C2_SADDR          <= '0';   --SADDR=0 : I2C Addr --> 0x90 (default)
                               --SADDR=1 : I2C Addr --> 0xBA
--MCLK output use ODDR2(SPARTAN6)
ODDR2_C2_MCLK : ODDR2
generic map(DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC")
port map(
Q           => io_C2_MCLK,       --port
C0          => s_clk_24mhz,      --output
C1          => s_clk_24mhz_n,    --not output
CE          => '1', D0 => '1', D1 => '0', R => '0', S => '0');
--input video d flip flops
process(io_C2_PCLK)
begin
   if rising_edge(io_C2_PCLK) then
      --1st stage D flip flops
      s_C2_FV_1d        <= io_C2_FV;
      s_C2_LV_1d        <= io_C2_LV;
      s_C2_DATA_1d      <= io_C2_DATA;
      --2nd stage D flip flops
      s_C2_FV_2d        <= s_C2_FV_1d;
      s_C2_LV_2d        <= s_C2_LV_1d;
      s_C2_DATA_2d      <= s_C2_DATA_1d;
   end if;
end process;


--FX3 AN75779 mappings-----------------------------------------------
--case 1. CIS1 BYPASS------------------------------------
s_FX3_PCLK              <= io_C1_PCLK;
s_FX3_PCLK_n            <= not s_FX3_PCLK;
--FX3 PCLK out use ODDR2(SPARTAN6)
ODDR2_FX3_PCLK : ODDR2
generic map(DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC")
port map(
Q           => io_fx3_PCLK,      --port
C0          => s_FX3_PCLK_n,     --output
C1          => s_FX3_PCLK,       --not output
CE          => '1', D0 => '1', D1 => '0', R => '0', S => '0');
io_fx3_CTL(11)          <= s_C1_LV_2d;
io_fx3_CTL(12)          <= s_C1_FV_2d;
io_fx3_DQ(8-1 downto 0) <= s_C1_DATA_2d;
----case 2. CIS2 BYPASS-----------------------------------
--s_FX3_PCLK              <= io_C2_PCLK;
--s_FX3_PCLK_n            <= not s_FX3_PCLK;
----FX3 PCLK out use ODDR2(SPARTAN6)
--ODDR2_FX3_PCLK : ODDR2
--generic map(DDR_ALIGNMENT => "NONE", INIT => '0', SRTYPE => "SYNC")
--port map(
--Q           => io_fx3_PCLK,      --port
--C0          => s_FX3_PCLK_n,     --output
--C1          => s_FX3_PCLK,       --not output
--CE          => '1', D0 => '1', D1 => '0', R => '0', S => '0');
--io_fx3_CTL(11)          <= s_C2_LV_2d;
--io_fx3_CTL(12)          <= s_C2_FV_2d;
--io_fx3_DQ(8-1 downto 0) <= s_C2_DATA_2d;
--end CIS to FX3 bypass--------------------------------------------------------


end Behavioral;

