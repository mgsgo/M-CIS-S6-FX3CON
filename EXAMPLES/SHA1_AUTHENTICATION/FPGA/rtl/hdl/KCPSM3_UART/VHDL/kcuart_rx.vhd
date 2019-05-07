--
-------------------------------------------------------------------------------------------
-- Copyright © 2010, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Constant (K) Compact UART Receiver
--
-- 8 data bits, no parity, 1 stop bit
--
--
-- This module was made for use with Spartan-3 Generation Devices and is also ideally 
-- suited for use with Virtex-II(PRO) and Virtex-4 devices. Will also work in Virtex-5, 
-- Virtex-6 and Spartan-6 devices but it is not specifically optimised for these 
-- architectures.
--
--
-- Version : 2.10 
-- Version Date : 19th March 2010
-- Reason : The VHDL coding style adjusted to be compatible with XST provided as 
--          part of the ISE v12.1i tools when targeting Spartan-6 and Virtex-6 
--          devices. No functional changes.
--
-- Version : 1.30 
-- Version Date : 17th January 2007
-- Reason : Format and Spelling
--
-- Version : 1.20 
-- Version Date : 11th December 2006
-- Reason : Attributes and '--translate on/off' directives removed as no longer 
--          required for XST.
--
-- Version : 1.10 
-- Version Date : 3rd December 2003
-- Reason : '--translate' directives changed to '--synthesis translate' directives
--
-- Version : 1.00
-- Version Date : 16th October 2002
--
-- Start of design entry : 16th October 2002
--
-- Ken Chapman
-- Xilinx Ltd
-- Benchmark House
-- 203 Brooklands Road
-- Weybridge
-- Surrey KT13 ORH
-- United Kingdom
--
-- chapman@xilinx.com
--
-------------------------------------------------------------------------------------------
--
-- Library declarations
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;
--
-------------------------------------------------------------------------------------------
--
-- Main Entity for KCUART_RX
--
entity kcuart_rx is
    Port (      serial_in : in std_logic;  
                 data_out : out std_logic_vector(7 downto 0);
              data_strobe : out std_logic;
             en_16_x_baud : in std_logic;
                      clk : in std_logic);
    end kcuart_rx;
--
-------------------------------------------------------------------------------------------
--
-- Start of Main Architecture for KCUART_RX
--	 
architecture low_level_definition of kcuart_rx is
--
-------------------------------------------------------------------------------------------
--
-- Signals used in KCUART_RX
--
-------------------------------------------------------------------------------------------
--
signal sync_serial        : std_logic;
signal stop_bit           : std_logic;
signal data_int           : std_logic_vector(7 downto 0);
signal data_delay         : std_logic_vector(7 downto 0);
signal start_delay        : std_logic;
signal start_bit          : std_logic;
signal edge_delay         : std_logic;
signal start_edge         : std_logic;
signal decode_valid_char  : std_logic;
signal valid_char         : std_logic;
signal decode_purge       : std_logic;
signal purge              : std_logic;
signal valid_srl_delay    : std_logic_vector(8 downto 0);
signal valid_reg_delay    : std_logic_vector(8 downto 0);
signal decode_data_strobe : std_logic;
--
--
-------------------------------------------------------------------------------------------
--
-- Start of KCUART_RX circuit description
--
-------------------------------------------------------------------------------------------
--	
begin

  -- Synchronise input serial data to system clock

  sync_reg: FD
  port map ( D => serial_in,
             Q => sync_serial,
             C => clk);

  stop_reg: FD
  port map ( D => sync_serial,
             Q => stop_bit,
             C => clk);


  -- Data delays to capture data at 16 time baud rate
  -- Each SRL16E is followed by a flip-flop for best timing

  data_loop: for i in 0 to 7 generate
  begin

     lsbs: if i<7 generate
     begin

       delay15_srl: SRL16E
       generic map (INIT => X"0000")
       port map(   D => data_int(i+1),
                  CE => en_16_x_baud,
                 CLK => clk,
                  A0 => '0',
                  A1 => '1',
                  A2 => '1',
                  A3 => '1',
                   Q => data_delay(i) );

     end generate lsbs;

     msb: if i=7 generate
     begin

       delay15_srl: SRL16E
       generic map (INIT => X"0000")
       port map(   D => stop_bit,
                  CE => en_16_x_baud,
                 CLK => clk,
                  A0 => '0',
                  A1 => '1',
                  A2 => '1',
                  A3 => '1',
                   Q => data_delay(i) );

     end generate msb;

     data_reg: FDE
     port map ( D => data_delay(i),
                Q => data_int(i),
               CE => en_16_x_baud,
                C => clk);

  end generate data_loop;

  -- Assign internal signals to outputs

  data_out <= data_int;
 
  -- Data delays to capture start bit at 16 time baud rate

  start_srl: SRL16E
  generic map (INIT => X"0000")
  port map(   D => data_int(0),
             CE => en_16_x_baud,
            CLK => clk,
             A0 => '0',
             A1 => '1',
             A2 => '1',
             A3 => '1',
              Q => start_delay );

  start_reg: FDE
  port map ( D => start_delay,
             Q => start_bit,
            CE => en_16_x_baud,
             C => clk);


  -- Data delays to capture start bit leading edge at 16 time baud rate
  -- Delay ensures data is captured at mid-bit position

  edge_srl: SRL16E
  generic map (INIT => X"0000")
  port map(   D => start_bit,
             CE => en_16_x_baud,
            CLK => clk,
             A0 => '1',
             A1 => '0',
             A2 => '1',
             A3 => '0',
              Q => edge_delay );

  edge_reg: FDE
  port map ( D => edge_delay,
             Q => start_edge,
            CE => en_16_x_baud,
             C => clk);

  -- Detect a valid character 

  valid_lut: LUT4
  generic map (INIT => X"0040")
  port map( I0 => purge,
            I1 => stop_bit,
            I2 => start_edge,
            I3 => edge_delay,
             O => decode_valid_char );  

  valid_reg: FDE
  port map ( D => decode_valid_char,
             Q => valid_char,
            CE => en_16_x_baud,
             C => clk);

  -- Purge of data status 

  purge_lut: LUT3
  generic map (INIT => X"54")
  port map( I0 => valid_reg_delay(8),
            I1 => valid_char,
            I2 => purge,
             O => decode_purge );  

  purge_reg: FDE
  port map ( D => decode_purge,
             Q => purge,
            CE => en_16_x_baud,
             C => clk);

  -- Delay of valid_char pulse of length equivalent to the time taken 
  -- to purge data shift register of all data which has been used.
  -- Requires 9x16 + 8 delays which is achieved by packing of SRL16E with 
  -- up to 16 delays and utilising the dedicated flip flop in each stage.

  valid_loop: for i in 0 to 8 generate
  begin

     lsb: if i=0 generate
     begin

       delay15_srl: SRL16E
       generic map (INIT => X"0000")
       port map(   D => valid_char,
                  CE => en_16_x_baud,
                 CLK => clk,
                  A0 => '0',
                  A1 => '1',
                  A2 => '1',
                  A3 => '1',
                   Q => valid_srl_delay(i) );

     end generate lsb;

     msbs: if i>0 generate
     begin

       delay16_srl: SRL16E
       generic map (INIT => X"0000")
       port map(   D => valid_reg_delay(i-1),
                  CE => en_16_x_baud,
                 CLK => clk,
                  A0 => '1',
                  A1 => '1',
                  A2 => '1',
                  A3 => '1',
                   Q => valid_srl_delay(i) );

     end generate msbs;

     data_reg: FDE
     port map ( D => valid_srl_delay(i),
                Q => valid_reg_delay(i),
               CE => en_16_x_baud,
                C => clk);

  end generate valid_loop;

  -- Form data strobe

  strobe_lut: LUT2
  generic map (INIT => X"8")
  port map( I0 => valid_char,
            I1 => en_16_x_baud,
             O => decode_data_strobe );

  strobe_reg: FD
  port map ( D => decode_data_strobe,
             Q => data_strobe,
             C => clk);

end low_level_definition;

-------------------------------------------------------------------------------------------
--
-- END OF FILE kcuart.vhd
--
-------------------------------------------------------------------------------------------


