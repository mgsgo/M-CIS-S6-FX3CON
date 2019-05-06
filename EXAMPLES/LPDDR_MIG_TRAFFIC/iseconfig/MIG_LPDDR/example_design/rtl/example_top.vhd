--*****************************************************************************
-- (c) Copyright 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor             : Xilinx
-- \   \   \/     Version            : 3.92
--  \   \         Application        : MIG
--  /   /         Filename           : example_top.vhd
-- /___/   /\     Date Last Modified : $Date: 2011/06/02 07:17:24 $
-- \   \  /  \    Date Created       : Jul 03 2009
--  \___\/\___\
--
--Device           : Spartan-6
--Design Name      : DDR/DDR2/DDR3/LPDDR 
--Purpose          : This is the design top level. which instantiates top wrapper,
--                   test bench top and infrastructure modules.
--Reference        :
--Revision History :
--*****************************************************************************
library ieee;
use ieee.std_logic_1164.all;
entity example_top is
generic
  (
            C1_P0_MASK_SIZE           : integer := 16;
          C1_P0_DATA_PORT_SIZE      : integer := 128;
          C1_P1_MASK_SIZE           : integer := 16;
          C1_P1_DATA_PORT_SIZE      : integer := 128;
    C1_MEMCLK_PERIOD        : integer := 5000; 
                                       -- Memory data transfer clock period.
    C1_RST_ACT_LOW          : integer := 0; 
                                       -- # = 1 for active low reset,
                                       -- # = 0 for active high reset.
    C1_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; 
                                       -- input clock type DIFFERENTIAL or SINGLE_ENDED.
    C1_CALIB_SOFT_IP        : string := "TRUE"; 
                                       -- # = TRUE, Enables the soft calibration logic,
                                       -- # = FALSE, Disables the soft calibration logic.
    C1_SIMULATION           : string := "FALSE"; 
                                       -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                       -- # = FALSE, Implementing the design.
    C1_HW_TESTING           : string := "FALSE"; 
                                       -- Determines the address space accessed by the traffic generator,
                                       -- # = FALSE, Smaller address space,
                                       -- # = TRUE, Large address space.
    DEBUG_EN                : integer := 0; 
                                       -- # = 1, Enable debug signals/controls,
                                       --   = 0, Disable debug signals/controls.
    C1_MEM_ADDR_ORDER       : string := "ROW_BANK_COLUMN"; 
                                       -- The order in which user address is provided to the memory controller,
                                       -- ROW_BANK_COLUMN or BANK_ROW_COLUMN.
    C1_NUM_DQ_PINS          : integer := 16; 
                                       -- External memory data width.
    C1_MEM_ADDR_WIDTH       : integer := 13; 
                                       -- External memory address width.
    C1_MEM_BANKADDR_WIDTH   : integer := 2 
                                       -- External memory bank address width.
  );
   
  port
  (
i_clk_100mhz			: in		std_logic;		--100mhz

io_led_D8				: inout	std_logic;
io_led_D9				: inout	std_logic;

i_extclk_fb_B14_1		: in		std_logic;	--
o_extclk_fb_B14_1		: out		std_logic;	--

--   calib_done                              : out std_logic;
--   error                                   : out std_logic;
   mcb1_dram_dq                            : inout  std_logic_vector(C1_NUM_DQ_PINS-1 downto 0);
   mcb1_dram_a                             : out std_logic_vector(C1_MEM_ADDR_WIDTH-1 downto 0);
   mcb1_dram_ba                            : out std_logic_vector(C1_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb1_dram_cke                           : out std_logic;
   mcb1_dram_ras_n                         : out std_logic;
   mcb1_dram_cas_n                         : out std_logic;
   mcb1_dram_we_n                          : out std_logic;
   mcb1_dram_dm                            : out std_logic;
   mcb1_dram_udqs                          : inout  std_logic;
   mcb1_rzq                                : inout  std_logic;
   mcb1_dram_udm                           : out std_logic;
--   c1_sys_clk                              : in  std_logic;
--   c1_sys_rst_i                            : in  std_logic;
   mcb1_dram_dqs                           : inout  std_logic;
   mcb1_dram_ck                            : out std_logic;
   mcb1_dram_ck_n                          : out std_logic
  );
end example_top;

architecture arc of example_top is

 

component memc1_infrastructure is
    generic (
      C_RST_ACT_LOW        : integer;
      C_INPUT_CLK_TYPE     : string;
      C_CLKOUT0_DIVIDE     : integer;
      C_CLKOUT1_DIVIDE     : integer;
      C_CLKOUT2_DIVIDE     : integer;
      C_CLKOUT3_DIVIDE     : integer;
      C_CLKFBOUT_MULT      : integer;
      C_DIVCLK_DIVIDE      : integer;
      C_INCLK_PERIOD       : integer

      );
    port (
      sys_clk_p                              : in    std_logic;
      sys_clk_n                              : in    std_logic;
      sys_clk                                : in    std_logic;
      sys_rst_i                              : in    std_logic;
      clk0                                   : out   std_logic;
      rst0                                   : out   std_logic;
      async_rst                              : out   std_logic;
      sysclk_2x                              : out   std_logic;
      sysclk_2x_180                          : out   std_logic;
      pll_ce_0                               : out   std_logic;
      pll_ce_90                              : out   std_logic;
      pll_lock                               : out   std_logic;
      mcb_drp_clk                            : out   std_logic

      );
  end component;


component memc1_wrapper is
    generic (
      C_MEMCLK_PERIOD      : integer;
      C_CALIB_SOFT_IP      : string;
      C_SIMULATION         : string;
      C_P0_MASK_SIZE       : integer;
      C_P0_DATA_PORT_SIZE   : integer;
      C_P1_MASK_SIZE       : integer;
      C_P1_DATA_PORT_SIZE   : integer;
      C_ARB_NUM_TIME_SLOTS   : integer;
      C_ARB_TIME_SLOT_0    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_1    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_2    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_3    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_4    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_5    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_6    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_7    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_8    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_9    : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_10   : bit_vector(2 downto 0);
      C_ARB_TIME_SLOT_11   : bit_vector(2 downto 0);
      C_MEM_TRAS           : integer;
      C_MEM_TRCD           : integer;
      C_MEM_TREFI          : integer;
      C_MEM_TRFC           : integer;
      C_MEM_TRP            : integer;
      C_MEM_TWR            : integer;
      C_MEM_TRTP           : integer;
      C_MEM_TWTR           : integer;
      C_MEM_ADDR_ORDER     : string;
      C_NUM_DQ_PINS        : integer;
      C_MEM_TYPE           : string;
      C_MEM_DENSITY        : string;
      C_MEM_BURST_LEN      : integer;
      C_MEM_CAS_LATENCY    : integer;
      C_MEM_ADDR_WIDTH     : integer;
      C_MEM_BANKADDR_WIDTH   : integer;
      C_MEM_NUM_COL_BITS   : integer;
      C_MEM_DDR1_2_ODS     : string;
      C_MEM_DDR2_RTT       : string;
      C_MEM_DDR2_DIFF_DQS_EN   : string;
      C_MEM_DDR2_3_PA_SR   : string;
      C_MEM_DDR2_3_HIGH_TEMP_SR   : string;
      C_MEM_DDR3_CAS_LATENCY   : integer;
      C_MEM_DDR3_ODS       : string;
      C_MEM_DDR3_RTT       : string;
      C_MEM_DDR3_CAS_WR_LATENCY   : integer;
      C_MEM_DDR3_AUTO_SR   : string;
      C_MEM_DDR3_DYN_WRT_ODT   : string;
      C_MEM_MOBILE_PA_SR   : string;
      C_MEM_MDDR_ODS       : string;
      C_MC_CALIB_BYPASS    : string;
      C_MC_CALIBRATION_MODE   : string;
      C_MC_CALIBRATION_DELAY   : string;
      C_SKIP_IN_TERM_CAL   : integer;
      C_SKIP_DYNAMIC_CAL   : integer;
      C_LDQSP_TAP_DELAY_VAL   : integer;
      C_LDQSN_TAP_DELAY_VAL   : integer;
      C_UDQSP_TAP_DELAY_VAL   : integer;
      C_UDQSN_TAP_DELAY_VAL   : integer;
      C_DQ0_TAP_DELAY_VAL   : integer;
      C_DQ1_TAP_DELAY_VAL   : integer;
      C_DQ2_TAP_DELAY_VAL   : integer;
      C_DQ3_TAP_DELAY_VAL   : integer;
      C_DQ4_TAP_DELAY_VAL   : integer;
      C_DQ5_TAP_DELAY_VAL   : integer;
      C_DQ6_TAP_DELAY_VAL   : integer;
      C_DQ7_TAP_DELAY_VAL   : integer;
      C_DQ8_TAP_DELAY_VAL   : integer;
      C_DQ9_TAP_DELAY_VAL   : integer;
      C_DQ10_TAP_DELAY_VAL   : integer;
      C_DQ11_TAP_DELAY_VAL   : integer;
      C_DQ12_TAP_DELAY_VAL   : integer;
      C_DQ13_TAP_DELAY_VAL   : integer;
      C_DQ14_TAP_DELAY_VAL   : integer;
      C_DQ15_TAP_DELAY_VAL   : integer
      );
    port (
      mcb1_dram_dq                           : inout  std_logic_vector((C_NUM_DQ_PINS-1) downto 0);
      mcb1_dram_a                            : out  std_logic_vector((C_MEM_ADDR_WIDTH-1) downto 0);
      mcb1_dram_ba                           : out  std_logic_vector((C_MEM_BANKADDR_WIDTH-1) downto 0);
      mcb1_dram_cke                          : out  std_logic;
      mcb1_dram_ras_n                        : out  std_logic;
      mcb1_dram_cas_n                        : out  std_logic;
      mcb1_dram_we_n                         : out  std_logic;
      mcb1_dram_dm                           : out  std_logic;
      mcb1_dram_udqs                         : inout  std_logic;
      mcb1_rzq                               : inout  std_logic;
      mcb1_dram_udm                          : out  std_logic;
      calib_done                             : out  std_logic;
      async_rst                              : in  std_logic;
      sysclk_2x                              : in  std_logic;
      sysclk_2x_180                          : in  std_logic;
      pll_ce_0                               : in  std_logic;
      pll_ce_90                              : in  std_logic;
      pll_lock                               : in  std_logic;
      mcb_drp_clk                            : in  std_logic;
      mcb1_dram_dqs                          : inout  std_logic;
      mcb1_dram_ck                           : out  std_logic;
      mcb1_dram_ck_n                         : out  std_logic;
      p0_cmd_clk                            : in std_logic;
      p0_cmd_en                             : in std_logic;
      p0_cmd_instr                          : in std_logic_vector(2 downto 0);
      p0_cmd_bl                             : in std_logic_vector(5 downto 0);
      p0_cmd_byte_addr                      : in std_logic_vector(29 downto 0);
      p0_cmd_empty                          : out std_logic;
      p0_cmd_full                           : out std_logic;
      p0_wr_clk                             : in std_logic;
      p0_wr_en                              : in std_logic;
      p0_wr_mask                            : in std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
      p0_wr_data                            : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_wr_full                            : out std_logic;
      p0_wr_empty                           : out std_logic;
      p0_wr_count                           : out std_logic_vector(6 downto 0);
      p0_wr_underrun                        : out std_logic;
      p0_wr_error                           : out std_logic;
      p0_rd_clk                             : in std_logic;
      p0_rd_en                              : in std_logic;
      p0_rd_data                            : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_rd_full                            : out std_logic;
      p0_rd_empty                           : out std_logic;
      p0_rd_count                           : out std_logic_vector(6 downto 0);
      p0_rd_overflow                        : out std_logic;
      p0_rd_error                           : out std_logic;
      selfrefresh_enter                     : in std_logic;
      selfrefresh_mode                      : out std_logic

      );
  end component;


component memc1_tb_top is
    generic (
      C_SIMULATION         : string;
      C_P0_MASK_SIZE       : integer;
      C_P0_DATA_PORT_SIZE   : integer;
      C_P1_MASK_SIZE       : integer;
      C_P1_DATA_PORT_SIZE   : integer;
      C_NUM_DQ_PINS        : integer;
      C_MEM_BURST_LEN      : integer;
      C_MEM_NUM_COL_BITS   : integer;
      C_SMALL_DEVICE       : string;
      C_p0_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0); 
      C_p0_DATA_MODE                          : std_logic_vector(3 downto 0); 
      C_p0_END_ADDRESS                        : std_logic_vector(31 downto 0); 
      C_p0_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0); 
      C_p0_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0) 

      );
    port (
      error                                  : out   std_logic;
      calib_done                             : in    std_logic;
      clk0                                   : in    std_logic;
      rst0                                   : in    std_logic;
      cmp_error                              : out   std_logic;
      cmp_data_valid                         : out   std_logic;
      vio_modify_enable                      : in    std_logic;
      error_status                           : out   std_logic_vector(319 downto 0);
      vio_data_mode_value                    : in  std_logic_vector(2 downto 0);
      vio_addr_mode_value                    : in  std_logic_vector(2 downto 0);
      cmp_data                               : out  std_logic_vector(31 downto 0);
      p0_mcb_cmd_en_o                           : out std_logic;
      p0_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
      p0_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
      p0_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
      p0_mcb_cmd_full_i                         : in std_logic;
      p0_mcb_wr_en_o                            : out std_logic;
      p0_mcb_wr_mask_o                          : out std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
      p0_mcb_wr_data_o                          : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_mcb_wr_full_i                          : in std_logic;
      p0_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);
      p0_mcb_rd_en_o                            : out std_logic;
      p0_mcb_rd_data_i                          : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_mcb_rd_empty_i                         : in std_logic;
      p0_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0)

      );
  end component;



  function c1_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
   begin
   if (C1_HW_TESTING = "FALSE") then
     return val1;
   else
     return val2;
   end if;
   end function;



   constant C1_CLKOUT0_DIVIDE       : integer := 2; 
   constant C1_CLKOUT1_DIVIDE       : integer := 2; 
   constant C1_CLKOUT2_DIVIDE       : integer := 16; 
   constant C1_CLKOUT3_DIVIDE       : integer := 8; 
   constant C1_CLKFBOUT_MULT        : integer := 4; 
   constant C1_DIVCLK_DIVIDE        : integer := 1; 
   constant C1_INCLK_PERIOD         : integer := ((C1_MEMCLK_PERIOD * C1_CLKFBOUT_MULT) / (C1_DIVCLK_DIVIDE * C1_CLKOUT0_DIVIDE * 2)); 
   constant C1_ARB_NUM_TIME_SLOTS   : integer := 12; 
   constant C1_ARB_TIME_SLOT_0      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_1      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_2      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_3      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_4      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_5      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_6      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_7      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_8      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_9      : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_10     : bit_vector(2 downto 0) := o"0"; 
   constant C1_ARB_TIME_SLOT_11     : bit_vector(2 downto 0) := o"0"; 
   constant C1_MEM_TRAS             : integer := 40000; 
   constant C1_MEM_TRCD             : integer := 15000; 
   constant C1_MEM_TREFI            : integer := 7800000; 
   constant C1_MEM_TRFC             : integer := 97500; 
   constant C1_MEM_TRP              : integer := 15000; 
   constant C1_MEM_TWR              : integer := 15000; 
   constant C1_MEM_TRTP             : integer := 7500; 
   constant C1_MEM_TWTR             : integer := 2; 
   constant C1_MEM_TYPE             : string := "MDDR"; 
   constant C1_MEM_DENSITY          : string := "512Mb"; 
   constant C1_MEM_BURST_LEN        : integer := 8; 
   constant C1_MEM_CAS_LATENCY      : integer := 3; 
   constant C1_MEM_NUM_COL_BITS     : integer := 10; 
   constant C1_MEM_DDR1_2_ODS       : string := "FULL"; 
   constant C1_MEM_DDR2_RTT         : string := "50OHMS"; 
   constant C1_MEM_DDR2_DIFF_DQS_EN  : string := "YES"; 
   constant C1_MEM_DDR2_3_PA_SR     : string := "FULL"; 
   constant C1_MEM_DDR2_3_HIGH_TEMP_SR  : string := "NORMAL"; 
   constant C1_MEM_DDR3_CAS_LATENCY  : integer := 6; 
   constant C1_MEM_DDR3_ODS         : string := "DIV6"; 
   constant C1_MEM_DDR3_RTT         : string := "DIV2"; 
   constant C1_MEM_DDR3_CAS_WR_LATENCY  : integer := 5; 
   constant C1_MEM_DDR3_AUTO_SR     : string := "ENABLED"; 
   constant C1_MEM_DDR3_DYN_WRT_ODT  : string := "OFF"; 
   constant C1_MEM_MOBILE_PA_SR     : string := "FULL"; 
   constant C1_MEM_MDDR_ODS         : string := "FULL"; 
   constant C1_MC_CALIB_BYPASS      : string := "NO"; 
   constant C1_MC_CALIBRATION_MODE  : string := "CALIBRATION"; 
   constant C1_MC_CALIBRATION_DELAY  : string := "HALF"; 
   constant C1_SKIP_IN_TERM_CAL     : integer := 1; 
   constant C1_SKIP_DYNAMIC_CAL     : integer := 0; 
   constant C1_LDQSP_TAP_DELAY_VAL  : integer := 0; 
   constant C1_LDQSN_TAP_DELAY_VAL  : integer := 0; 
   constant C1_UDQSP_TAP_DELAY_VAL  : integer := 0; 
   constant C1_UDQSN_TAP_DELAY_VAL  : integer := 0; 
   constant C1_DQ0_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ1_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ2_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ3_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ4_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ5_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ6_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ7_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ8_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ9_TAP_DELAY_VAL    : integer := 0; 
   constant C1_DQ10_TAP_DELAY_VAL   : integer := 0; 
   constant C1_DQ11_TAP_DELAY_VAL   : integer := 0; 
   constant C1_DQ12_TAP_DELAY_VAL   : integer := 0; 
   constant C1_DQ13_TAP_DELAY_VAL   : integer := 0; 
   constant C1_DQ14_TAP_DELAY_VAL   : integer := 0; 
   constant C1_DQ15_TAP_DELAY_VAL   : integer := 0; 
   constant C1_SMALL_DEVICE         : string := "FALSE"; -- The parameter is set to TRUE for all packages of xc6slx9 device
                                                         -- as most of them cannot fit the complete example design when the
                                                         -- Chip scope modules are enabled
   constant C1_p0_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c1_sim_hw (x"00000400", x"01000000");
   constant C1_p0_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C1_p0_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c1_sim_hw (x"000007ff", x"02ffffff");
   constant C1_p0_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c1_sim_hw (x"fffff800", x"fc000000");
   constant C1_p0_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c1_sim_hw (x"00000400", x"01000000");

  signal  c1_sys_clk_p                             : std_logic;
  signal  c1_sys_clk_n                             : std_logic;
  signal  c1_error                                 : std_logic;
  signal  c1_calib_done                            : std_logic;
  signal  c1_clk0                                  : std_logic;
  signal  c1_rst0                                  : std_logic;
  signal  c1_async_rst                             : std_logic;
  signal  c1_sysclk_2x                             : std_logic;
  signal  c1_sysclk_2x_180                         : std_logic;
  signal  c1_pll_ce_0                              : std_logic;
  signal  c1_pll_ce_90                             : std_logic;
  signal  c1_pll_lock                              : std_logic;
  signal  c1_mcb_drp_clk                           : std_logic;
  signal  c1_cmp_error                             : std_logic;
  signal  c1_cmp_data_valid                        : std_logic;
  signal  c1_vio_modify_enable                     : std_logic;
  signal  c1_error_status                          : std_logic_vector(319 downto 0);
  signal  c1_vio_data_mode_value                   : std_logic_vector(2 downto 0);
  signal  c1_vio_addr_mode_value                   : std_logic_vector(2 downto 0);
  signal  c1_cmp_data                              : std_logic_vector(31 downto 0);
  signal  c1_p0_cmd_en                             : std_logic;
  signal  c1_p0_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c1_p0_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c1_p0_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c1_p0_cmd_empty                          : std_logic;
  signal  c1_p0_cmd_full                           : std_logic;
  signal  c1_p0_wr_en                              : std_logic;
  signal  c1_p0_wr_mask                            : std_logic_vector(C1_P0_MASK_SIZE - 1 downto 0);
  signal  c1_p0_wr_data                            : std_logic_vector(C1_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c1_p0_wr_full                            : std_logic;
  signal  c1_p0_wr_empty                           : std_logic;
  signal  c1_p0_wr_count                           : std_logic_vector(6 downto 0);
  signal  c1_p0_wr_underrun                        : std_logic;
  signal  c1_p0_wr_error                           : std_logic;
  signal  c1_p0_rd_en                              : std_logic;
  signal  c1_p0_rd_data                            : std_logic_vector(C1_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c1_p0_rd_full                            : std_logic;
  signal  c1_p0_rd_empty                           : std_logic;
  signal  c1_p0_rd_count                           : std_logic_vector(6 downto 0);
  signal  c1_p0_rd_overflow                        : std_logic;
  signal  c1_p0_rd_error                           : std_logic;

  signal  c1_selfrefresh_enter                     : std_logic;
  signal  c1_selfrefresh_mode                      : std_logic;

	signal  calib_done                              : std_logic;
	signal  error                                   : std_logic;
	signal  c1_sys_clk                              : std_logic;
	signal  c1_sys_rst_i                            : std_logic;


component clock_wizard_100mhz_input
port
(-- Clock in ports
CLK_IN1              : in     std_logic;  -- Clock out ports
CLK_OUT1             : out    std_logic;  -- Status and control signals
CLK_OUT2             : out    std_logic;  -- Status and control signals
--CLK_OUT3             : out    std_logic;  -- Status and control signals
--CLK_OUT4             : out    std_logic;  -- Status and control signals
--CLK_OUT5             : out    std_logic;  -- Status and control signals
--CLK_OUT6             : out    std_logic;  -- Status and control signals
--CLK_OUT7             : out    std_logic;  -- Status and control signals
--CLK_OUT8             : out    std_logic;  -- Status and control signals
RESET                : in     std_logic;
LOCKED               : out    std_logic
);
end component;

component ODDR2
generic(
DDR_ALIGNMENT : string := "NONE";
INIT          : bit    := '0';
SRTYPE        : string := "SYNC"
);
port(
Q           : out std_ulogic;
C0          : in  std_ulogic;
C1          : in  std_ulogic;
CE          : in  std_ulogic := 'H';
D0          : in  std_ulogic;
D1          : in  std_ulogic;
R           : in  std_ulogic := 'L';
S           : in  std_ulogic := 'L'
);
end component;
signal s_dcm_rst			: std_logic;                     --

signal s_clk_100mhz			: std_logic;                     --
signal s_clk_200mhz			: std_logic;                     --
signal s_clk_200mhz_n			: std_logic;                     --
--signal s_clk_200mhz			: std_logic;                     --
--signal s_clk_400mhz			: std_logic;                     --
--signal s_clk_50mhz			: std_logic;                     --
--signal s_clk_38mhz			: std_logic;                     --
--signal s_pll_locked			: std_logic;                     --
--signal s_pll_locked_n		: std_logic;                     --
--signal s_rst_port				: std_logic;                     --
signal s_rst					: std_logic;                     --
signal s_rst_n					: std_logic;                     --
signal s_cnt_32bit			: std_logic_vector(32-1 downto 0);                     --


begin

s_dcm_rst				<= '0';
clock_wizard_100mhz_input_u0 : clock_wizard_100mhz_input
port map(
CLK_IN1              => i_clk_100mhz,
CLK_OUT1             => s_clk_100mhz,
CLK_OUT2             => s_clk_200mhz,
RESET                => s_dcm_rst,--'0',--s_rst,
LOCKED               => open--s_rst_n
);
s_rst_n					<= '1';
s_rst						<= not s_rst_n;
s_clk_200mhz_n			<= not s_clk_200mhz;
CLK_FEDD_14_1 : ODDR2
generic map(DDR_ALIGNMENT => "NONE",	INIT          => '0',	SRTYPE        => "SYNC")
port map(
Q           => o_extclk_fb_B14_1,			--port
C0          => s_clk_200mhz,		--output
C1          => s_clk_200mhz_n,		--not output
CE          => '1',	D0          => '1',	D1          => '0',	R           => '0',	S           => '0');


c1_sys_rst_i		<= '0';
c1_sys_clk			<= i_extclk_fb_B14_1;--i_clk_100mhz;--

io_led_D8							<= s_rst;--'1';				--D8 low ON
io_led_D9							<= calib_done and (not error);			--D9 high ON


 error <= c1_error or c1_cmp_error;
calib_done <= c1_calib_done;
c1_sys_clk_p <= '0';
c1_sys_clk_n <= '0';
c1_selfrefresh_enter <= '0';
memc1_infrastructure_inst : memc1_infrastructure

generic map
 (
   C_RST_ACT_LOW                     => C1_RST_ACT_LOW,
   C_INPUT_CLK_TYPE                  => C1_INPUT_CLK_TYPE,
   C_CLKOUT0_DIVIDE                  => C1_CLKOUT0_DIVIDE,
   C_CLKOUT1_DIVIDE                  => C1_CLKOUT1_DIVIDE,
   C_CLKOUT2_DIVIDE                  => C1_CLKOUT2_DIVIDE,
   C_CLKOUT3_DIVIDE                  => C1_CLKOUT3_DIVIDE,
   C_CLKFBOUT_MULT                   => C1_CLKFBOUT_MULT,
   C_DIVCLK_DIVIDE                   => C1_DIVCLK_DIVIDE,
   C_INCLK_PERIOD                    => C1_INCLK_PERIOD
   )
port map
 (
   sys_clk_p                       => c1_sys_clk_p,
   sys_clk_n                       => c1_sys_clk_n,
   sys_clk                         => c1_sys_clk,
   sys_rst_i                       => c1_sys_rst_i,
   clk0                            => c1_clk0,
   rst0                            => c1_rst0,
   async_rst                       => c1_async_rst,
   sysclk_2x                       => c1_sysclk_2x,
   sysclk_2x_180                   => c1_sysclk_2x_180,
   pll_ce_0                        => c1_pll_ce_0,
   pll_ce_90                       => c1_pll_ce_90,
   pll_lock                        => c1_pll_lock,
   mcb_drp_clk                     => c1_mcb_drp_clk
   );


-- wrapper instantiation
 memc1_wrapper_inst : memc1_wrapper

generic map
 (
   C_MEMCLK_PERIOD                   => C1_MEMCLK_PERIOD,
   C_CALIB_SOFT_IP                   => C1_CALIB_SOFT_IP,
   C_SIMULATION                      => C1_SIMULATION,
   C_P0_MASK_SIZE                    => C1_P0_MASK_SIZE,
   C_P0_DATA_PORT_SIZE               => C1_P0_DATA_PORT_SIZE,
   C_P1_MASK_SIZE                    => C1_P1_MASK_SIZE,
   C_P1_DATA_PORT_SIZE               => C1_P1_DATA_PORT_SIZE,
   C_ARB_NUM_TIME_SLOTS              => C1_ARB_NUM_TIME_SLOTS,
   C_ARB_TIME_SLOT_0                 => C1_ARB_TIME_SLOT_0,
   C_ARB_TIME_SLOT_1                 => C1_ARB_TIME_SLOT_1,
   C_ARB_TIME_SLOT_2                 => C1_ARB_TIME_SLOT_2,
   C_ARB_TIME_SLOT_3                 => C1_ARB_TIME_SLOT_3,
   C_ARB_TIME_SLOT_4                 => C1_ARB_TIME_SLOT_4,
   C_ARB_TIME_SLOT_5                 => C1_ARB_TIME_SLOT_5,
   C_ARB_TIME_SLOT_6                 => C1_ARB_TIME_SLOT_6,
   C_ARB_TIME_SLOT_7                 => C1_ARB_TIME_SLOT_7,
   C_ARB_TIME_SLOT_8                 => C1_ARB_TIME_SLOT_8,
   C_ARB_TIME_SLOT_9                 => C1_ARB_TIME_SLOT_9,
   C_ARB_TIME_SLOT_10                => C1_ARB_TIME_SLOT_10,
   C_ARB_TIME_SLOT_11                => C1_ARB_TIME_SLOT_11,
   C_MEM_TRAS                        => C1_MEM_TRAS,
   C_MEM_TRCD                        => C1_MEM_TRCD,
   C_MEM_TREFI                       => C1_MEM_TREFI,
   C_MEM_TRFC                        => C1_MEM_TRFC,
   C_MEM_TRP                         => C1_MEM_TRP,
   C_MEM_TWR                         => C1_MEM_TWR,
   C_MEM_TRTP                        => C1_MEM_TRTP,
   C_MEM_TWTR                        => C1_MEM_TWTR,
   C_MEM_ADDR_ORDER                  => C1_MEM_ADDR_ORDER,
   C_NUM_DQ_PINS                     => C1_NUM_DQ_PINS,
   C_MEM_TYPE                        => C1_MEM_TYPE,
   C_MEM_DENSITY                     => C1_MEM_DENSITY,
   C_MEM_BURST_LEN                   => C1_MEM_BURST_LEN,
   C_MEM_CAS_LATENCY                 => C1_MEM_CAS_LATENCY,
   C_MEM_ADDR_WIDTH                  => C1_MEM_ADDR_WIDTH,
   C_MEM_BANKADDR_WIDTH              => C1_MEM_BANKADDR_WIDTH,
   C_MEM_NUM_COL_BITS                => C1_MEM_NUM_COL_BITS,
   C_MEM_DDR1_2_ODS                  => C1_MEM_DDR1_2_ODS,
   C_MEM_DDR2_RTT                    => C1_MEM_DDR2_RTT,
   C_MEM_DDR2_DIFF_DQS_EN            => C1_MEM_DDR2_DIFF_DQS_EN,
   C_MEM_DDR2_3_PA_SR                => C1_MEM_DDR2_3_PA_SR,
   C_MEM_DDR2_3_HIGH_TEMP_SR         => C1_MEM_DDR2_3_HIGH_TEMP_SR,
   C_MEM_DDR3_CAS_LATENCY            => C1_MEM_DDR3_CAS_LATENCY,
   C_MEM_DDR3_ODS                    => C1_MEM_DDR3_ODS,
   C_MEM_DDR3_RTT                    => C1_MEM_DDR3_RTT,
   C_MEM_DDR3_CAS_WR_LATENCY         => C1_MEM_DDR3_CAS_WR_LATENCY,
   C_MEM_DDR3_AUTO_SR                => C1_MEM_DDR3_AUTO_SR,
   C_MEM_DDR3_DYN_WRT_ODT            => C1_MEM_DDR3_DYN_WRT_ODT,
   C_MEM_MOBILE_PA_SR                => C1_MEM_MOBILE_PA_SR,
   C_MEM_MDDR_ODS                    => C1_MEM_MDDR_ODS,
   C_MC_CALIB_BYPASS                 => C1_MC_CALIB_BYPASS,
   C_MC_CALIBRATION_MODE             => C1_MC_CALIBRATION_MODE,
   C_MC_CALIBRATION_DELAY            => C1_MC_CALIBRATION_DELAY,
   C_SKIP_IN_TERM_CAL                => C1_SKIP_IN_TERM_CAL,
   C_SKIP_DYNAMIC_CAL                => C1_SKIP_DYNAMIC_CAL,
   C_LDQSP_TAP_DELAY_VAL             => C1_LDQSP_TAP_DELAY_VAL,
   C_LDQSN_TAP_DELAY_VAL             => C1_LDQSN_TAP_DELAY_VAL,
   C_UDQSP_TAP_DELAY_VAL             => C1_UDQSP_TAP_DELAY_VAL,
   C_UDQSN_TAP_DELAY_VAL             => C1_UDQSN_TAP_DELAY_VAL,
   C_DQ0_TAP_DELAY_VAL               => C1_DQ0_TAP_DELAY_VAL,
   C_DQ1_TAP_DELAY_VAL               => C1_DQ1_TAP_DELAY_VAL,
   C_DQ2_TAP_DELAY_VAL               => C1_DQ2_TAP_DELAY_VAL,
   C_DQ3_TAP_DELAY_VAL               => C1_DQ3_TAP_DELAY_VAL,
   C_DQ4_TAP_DELAY_VAL               => C1_DQ4_TAP_DELAY_VAL,
   C_DQ5_TAP_DELAY_VAL               => C1_DQ5_TAP_DELAY_VAL,
   C_DQ6_TAP_DELAY_VAL               => C1_DQ6_TAP_DELAY_VAL,
   C_DQ7_TAP_DELAY_VAL               => C1_DQ7_TAP_DELAY_VAL,
   C_DQ8_TAP_DELAY_VAL               => C1_DQ8_TAP_DELAY_VAL,
   C_DQ9_TAP_DELAY_VAL               => C1_DQ9_TAP_DELAY_VAL,
   C_DQ10_TAP_DELAY_VAL              => C1_DQ10_TAP_DELAY_VAL,
   C_DQ11_TAP_DELAY_VAL              => C1_DQ11_TAP_DELAY_VAL,
   C_DQ12_TAP_DELAY_VAL              => C1_DQ12_TAP_DELAY_VAL,
   C_DQ13_TAP_DELAY_VAL              => C1_DQ13_TAP_DELAY_VAL,
   C_DQ14_TAP_DELAY_VAL              => C1_DQ14_TAP_DELAY_VAL,
   C_DQ15_TAP_DELAY_VAL              => C1_DQ15_TAP_DELAY_VAL
   )
port map
(
   mcb1_dram_dq                        => mcb1_dram_dq,
   mcb1_dram_a                         => mcb1_dram_a,
   mcb1_dram_ba                        => mcb1_dram_ba,
   mcb1_dram_cke                       => mcb1_dram_cke,
   mcb1_dram_ras_n                     => mcb1_dram_ras_n,
   mcb1_dram_cas_n                     => mcb1_dram_cas_n,
   mcb1_dram_we_n                      => mcb1_dram_we_n,
   mcb1_dram_dm                        => mcb1_dram_dm,
   mcb1_dram_udqs                      => mcb1_dram_udqs,
   mcb1_rzq                             => mcb1_rzq,
   mcb1_dram_udm                       => mcb1_dram_udm,
   calib_done                      => c1_calib_done,
   async_rst                       => c1_async_rst,
   sysclk_2x                       => c1_sysclk_2x,
   sysclk_2x_180                   => c1_sysclk_2x_180,
   pll_ce_0                        => c1_pll_ce_0,
   pll_ce_90                       => c1_pll_ce_90,
   pll_lock                        => c1_pll_lock,
   mcb_drp_clk                     => c1_mcb_drp_clk,
   mcb1_dram_dqs                       => mcb1_dram_dqs,
   mcb1_dram_ck                        => mcb1_dram_ck,
   mcb1_dram_ck_n                      => mcb1_dram_ck_n,
   p0_cmd_clk                           =>  c1_clk0,
   p0_cmd_en                            =>  c1_p0_cmd_en,
   p0_cmd_instr                         =>  c1_p0_cmd_instr,
   p0_cmd_bl                            =>  c1_p0_cmd_bl,
   p0_cmd_byte_addr                     =>  c1_p0_cmd_byte_addr,
   p0_cmd_empty                         =>  c1_p0_cmd_empty,
   p0_cmd_full                          =>  c1_p0_cmd_full,
   p0_wr_clk                            =>  c1_clk0,
   p0_wr_en                             =>  c1_p0_wr_en,
   p0_wr_mask                           =>  c1_p0_wr_mask,
   p0_wr_data                           =>  c1_p0_wr_data,
   p0_wr_full                           =>  c1_p0_wr_full,
   p0_wr_empty                          =>  c1_p0_wr_empty,
   p0_wr_count                          =>  c1_p0_wr_count,
   p0_wr_underrun                       =>  c1_p0_wr_underrun,
   p0_wr_error                          =>  c1_p0_wr_error,
   p0_rd_clk                            =>  c1_clk0,
   p0_rd_en                             =>  c1_p0_rd_en,
   p0_rd_data                           =>  c1_p0_rd_data,
   p0_rd_full                           =>  c1_p0_rd_full,
   p0_rd_empty                          =>  c1_p0_rd_empty,
   p0_rd_count                          =>  c1_p0_rd_count,
   p0_rd_overflow                       =>  c1_p0_rd_overflow,
   p0_rd_error                          =>  c1_p0_rd_error,
   selfrefresh_enter                    =>  c1_selfrefresh_enter,
   selfrefresh_mode                     =>  c1_selfrefresh_mode
);

 memc1_tb_top_inst : memc1_tb_top

generic map
 (
   C_SIMULATION                      => C1_SIMULATION,
   C_P0_MASK_SIZE                    => C1_P0_MASK_SIZE,
   C_P0_DATA_PORT_SIZE               => C1_P0_DATA_PORT_SIZE,
   C_P1_MASK_SIZE                    => C1_P1_MASK_SIZE,
   C_P1_DATA_PORT_SIZE               => C1_P1_DATA_PORT_SIZE,
   C_NUM_DQ_PINS                     => C1_NUM_DQ_PINS,
   C_MEM_BURST_LEN                   => C1_MEM_BURST_LEN,
   C_MEM_NUM_COL_BITS                => C1_MEM_NUM_COL_BITS,
   C_SMALL_DEVICE                    => C1_SMALL_DEVICE,
   C_p0_BEGIN_ADDRESS                       =>  C1_p0_BEGIN_ADDRESS, 
   C_p0_DATA_MODE                           =>  C1_p0_DATA_MODE, 
   C_p0_END_ADDRESS                         =>  C1_p0_END_ADDRESS, 
   C_p0_PRBS_EADDR_MASK_POS                 =>  C1_p0_PRBS_EADDR_MASK_POS, 
   C_p0_PRBS_SADDR_MASK_POS                 =>  C1_p0_PRBS_SADDR_MASK_POS 
   )
port map
(
   error                           => c1_error,
   calib_done                      => c1_calib_done,
   clk0                            => c1_clk0,
   rst0                            => c1_rst0,
   cmp_error                       => c1_cmp_error,
   cmp_data_valid                  => c1_cmp_data_valid,
   vio_modify_enable               => c1_vio_modify_enable,
   error_status                    => c1_error_status,
   vio_data_mode_value             => c1_vio_data_mode_value,
   vio_addr_mode_value             => c1_vio_addr_mode_value,
   cmp_data                        => c1_cmp_data,
   p0_mcb_cmd_en_o                          =>  c1_p0_cmd_en,
   p0_mcb_cmd_instr_o                       =>  c1_p0_cmd_instr,
   p0_mcb_cmd_bl_o                          =>  c1_p0_cmd_bl,
   p0_mcb_cmd_addr_o                        =>  c1_p0_cmd_byte_addr,
   p0_mcb_cmd_full_i                        =>  c1_p0_cmd_full,
   p0_mcb_wr_en_o                           =>  c1_p0_wr_en,
   p0_mcb_wr_mask_o                         =>  c1_p0_wr_mask,
   p0_mcb_wr_data_o                         =>  c1_p0_wr_data,
   p0_mcb_wr_full_i                         =>  c1_p0_wr_full,
   p0_mcb_wr_fifo_counts                    =>  c1_p0_wr_count,
   p0_mcb_rd_en_o                           =>  c1_p0_rd_en,
   p0_mcb_rd_data_i                         =>  c1_p0_rd_data,
   p0_mcb_rd_empty_i                        =>  c1_p0_rd_empty,
   p0_mcb_rd_fifo_counts                    =>  c1_p0_rd_count
  );

 
  

 end  arc;
