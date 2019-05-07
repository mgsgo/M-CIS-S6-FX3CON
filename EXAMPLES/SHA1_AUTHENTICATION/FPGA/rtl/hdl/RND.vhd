-------------------------------------------------------------------------
--
-- File        : rnd.vhd
--             :
-- Description : This module generates a serial stream of random 
--             : (not pseudorandom) bits
--             :
-- Created by  : Catalin Baetoniu, Xilinx
--             :
-- Coding      :  
-- Standard    : Active-low signals are identified with '_n' or '_N'.
--             : Only one entity-architecture pair per file.
--             :
-- Synthesis   :
-- Standard    : All outputs registered when possible.
--             :
-- Synthesis   :
-- Warnings    : <NO warnings without written explanation>
--             :
-- Limitations : For use in Xilinx FPGA
--             :
-- Notes       : <notes>
--             : 
-------------------------------------------------------------------------
-- Revision History :                                          
-------------------------------------------------------------------------
--   Rev. | Author | Changes Made:                           | Date:
--   1.0  | CB     | First write                             | 04/15/2004
--   2.0  | KVE    | Not tested if this produces a real      | 2010
--                 | random number, original Spartan-3 design contains 
--                 | net-locking information which is not vaild for 
--                 | other Xilinx device architectures      
--   2.1  | TC     | Code cleanup and portability updates
-------------------------------------------------------------------------
--
--     AVNET IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
--     OR STANDARD, AVNET IS MAKING NO REPRESENTATION THAT THIS
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
--     FOR YOUR IMPLEMENTATION.  AVNET EXPRESSLY DISCLAIMS ANY
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--     FOR A PARTICULAR PURPOSE.
--     
--     (c) Copyright 2007 AVNET, Inc.
--     All rights reserved.
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity rnd is
  port ( clk : in std_logic;     -- System Clock
         o   : out std_logic);   -- Random Serial Output Data
end rnd;

architecture test of rnd is
  function TO01 (i : std_logic) return std_logic is
  begin
    if i = '1' then
      return '1';
    else
      return '0';
    end if;
  end;


  signal ring1, ring2 : std_logic := '0';
  signal cring1, cring2, cq1, q1, q2, q3, q19, q20 : std_logic := '0';

  attribute s        : STRING;
  attribute rloc     : STRING;
  attribute bel      : STRING;
  attribute syn_keep : BOOLEAN; 
  attribute route    : STRING;

  attribute s of ring1     : signal is "yes";
  attribute s of ring2     : signal is "yes";

  --
  -- timing simulation values for 2VP-6  
  --
  constant tnet1 : time := 192 ps;
  constant tnet2 : time := 79 ps;
  constant tilox : time := 288 ps;
  constant tiloy : time := 313 ps;
  
begin

  -- First Ring Oscillator
  cring1 <= transport TO01 (ring1) after tnet1 + tilox - 100 ps;
  r1 : LUT1 generic map (INIT => "01")
            port map (I0 => cring1,
                      O  => ring1);
                      
  -- Second Ring Oscillator
  cring2 <= transport TO01 (ring2) after tnet2 + tiloy - 100 ps;
  r2 : LUT1 generic map (INIT=>"01")
            port map (I0 => cring2,
                      O  => ring2);
                      
  -- Polynomial x**20+x**3+1 is Primitive
  x4 :  LUT4 generic map (INIT => X"6996") -- XOR4
             port map (I0 => ring1,
                       I1 => ring2,
                       I2 => q3,
                       I3 => q20,
                       O  => cq1);
                       
  -- This FF will go metastable very often and this is exactly what we want
  f1 : FD port map (C => clk,
                    D => TO01(cq1),
                    Q => q1);
                    
  f2 : FD port map (C => clk,
                    D => q1,
                    Q => q2);
                    
  f3 : FD port map (C => clk,
                    D => q2,
                    Q => q3);
                    
  sr : SRL16 port map ( CLK => clk,
                        D   => q3,
                        A0  => '1',
                        A1  => '1',
                        A2  => '1',
                        A3  => '1',
                        Q   => q19);
                        
  f20 : FD port map (C => clk,
                     D => q19,
                     Q => q20);

  -- Double Sampled Output to Remove Metastability
  o <= q2;
  
end test;

