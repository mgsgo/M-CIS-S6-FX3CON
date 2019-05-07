-------------------------------------------------------------------------
--
-- File        : sha1_prog_test.vhd
--             :
-- Description : PicoBlaze performing 1-wire communication and SHA1 
--             : algorithm for interaction with the DS28E01 device from 
--             : Maxim Semiconductor. The DS28E01 is described as 
--             : a 1k-bit Protected 1-Wire EEPROM with SHA-1 Engine.
--             : Design provided and tested on the Avnet S6LX16 
--             : Spartan-6 Evaluation Board.
--             :
-- Created by  : Ken Chapman, Xilinx
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
-- Notes       : The design is set up for a 66MHz system clock and 
--             : UART communications of 9600 baud
--             : 
-------------------------------------------------------------------------
-- Revision History :                                          
-------------------------------------------------------------------------
--   Rev. | Author | Changes Made:                           | Date:
--   1.0  | KC     | First write                             | 4/19/2006      
--   2.0  | TC     | Updates to Spartan-6 and PicoBlaze 6    | 3/9/2011      
--                 | Also updated for Maxim DS28E01-100      |
--                 | secure EEPROM with SHA-1 engine         |
--   3.0  | TC     | Updates to ISE 13.2                     | 9/9/2011      
--                 | Minor formatting changes                |
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--
library unisim;
use unisim.vcomponents.all;

entity SHA1_PROG_TEST is
   Port ( SERIAL_TX   : out std_logic;
          SERIAL_RX   : in std_logic;
          DS_WIRE     : inout std_logic;
          FPGA_LS1_EN : out std_logic;				 
          RESET       : in std_logic;
          CLK_IN      : in std_logic);
   end SHA1_PROG_TEST;

------------------------------------------------------------------------------------
-- Start of test architecture
------------------------------------------------------------------------------------
architecture RTL of SHA1_PROG_TEST is

   --
   -- declaration of KCPSM6
   --
   component kcpsm6 
      Generic (          hwbuild : std_logic_vector(7 downto 0) := X"00" ;
                interrupt_vector : std_logic_vector(11 downto 0) := X"3FF" ;
         scratch_pad_memory_size : integer := 64 );
      Port (             address : out std_logic_vector(11 downto 0);
                     instruction : in std_logic_vector(17 downto 0);
                     bram_enable : out std_logic;
                         in_port : in std_logic_vector(7 downto 0);
                        out_port : out std_logic_vector(7 downto 0);
                         port_id : out std_logic_vector(7 downto 0);
                    write_strobe : out std_logic;
                  k_write_strobe : out std_logic;
                     read_strobe : out std_logic;
                       interrupt : in std_logic;
                   interrupt_ack : out std_logic;
                           sleep : in std_logic;
                           reset : in std_logic;
                             clk : in std_logic );
   end component;
   
   --
   -- declaration of program ROM
   --
   component sha1prog
      Port ( address : in std_logic_vector(11 downto 0);
         instruction : out std_logic_vector(17 downto 0);
              enable : in std_logic;
                 clk : in std_logic);
   end component;

   --
   -- declaration of UART transmitter with integral 16 byte FIFO buffer.
   --  
   component uart_tx
      Port (      data_in : in std_logic_vector(7 downto 0);
             write_buffer : in std_logic;
             reset_buffer : in std_logic;
             en_16_x_baud : in std_logic;
               serial_out : out std_logic;
              buffer_full : out std_logic;
         buffer_half_full : out std_logic;
                      clk : in std_logic);
   end component;

   --
   -- declaration of UART Receiver with integral 16 byte FIFO buffer
   --
   component uart_rx
      Port (       serial_in : in std_logic;
                    data_out : out std_logic_vector(7 downto 0);
                 read_buffer : in std_logic;
                reset_buffer : in std_logic;
                en_16_x_baud : in std_logic;
         buffer_data_present : out std_logic;
                 buffer_full : out std_logic;
            buffer_half_full : out std_logic;
                         clk : in std_logic);
   end component;

   --
   -- declaration of serial random number generator
   --
   component rnd
      port(clk : in std_logic;       -- System Clock
           o   : out std_logic);     -- Random Serial Output Data
   end component;
     
   --
   -- Signals used to connect KCPSM6 to program ROM and I/O logic
   --
   signal  address         : std_logic_vector(11 downto 0);
   signal  instruction     : std_logic_vector(17 downto 0);
   signal  port_id         : std_logic_vector(7 downto 0);
   signal  out_port        : std_logic_vector(7 downto 0);
   signal  in_port         : std_logic_vector(7 downto 0);
   signal  write_strobe    : std_logic;
   signal  k_write_strobe  : std_logic;
   signal  read_strobe     : std_logic;
   signal  interrupt       : std_logic;
   signal  interrupt_ack   : std_logic;
   signal  kcpsm6_sleep    : std_logic;
   signal  bram_enable     : std_logic;

   --
   -- Signals for connection of peripherals
   --
   signal      status_port : std_logic_vector(7 downto 0);

   --
   -- Signals for UART connections
   --
   constant BaudRate:integer:=9600;
   constant ClockFrequency:integer:=66000000;
   constant BaudCountMax:integer:= ClockFrequency/(16* BaudRate);
   constant TargetBoard:String:="ADS-6SLX9";

   signal       baud_count : integer range 0 to BaudCountMax :=0;
   signal     en_16_x_baud : std_logic;

   signal    write_to_uart : std_logic;
   signal          tx_full : std_logic;
   signal     tx_half_full : std_logic;
   signal   read_from_uart : std_logic;
   signal          rx_data : std_logic_vector(7 downto 0);
   signal  rx_data_present : std_logic;
   signal          rx_full : std_logic;
   signal     rx_half_full : std_logic;

   --
   -- Signal to connect to DS28E01 1-wire interface 
   --
   signal    drive_ds_wire : std_logic;

   --
   -- signal output from random number generator
   --
   signal             rbit : std_logic;
     
   --
   -- Signals used to form 'Wt' word buffer 
   --
   signal   delay_0_to_15_byte_tap : std_logic_vector(7 downto 0);
   signal        delay_15_byte_tap : std_logic_vector(7 downto 0);
   signal  delay_16_to_31_byte_tap : std_logic_vector(7 downto 0);
   signal        delay_31_byte_tap : std_logic_vector(7 downto 0);
   signal  delay_32_to_47_byte_tap : std_logic_vector(7 downto 0);
   signal        delay_47_byte_tap : std_logic_vector(7 downto 0);
   signal  delay_48_to_63_byte_tap : std_logic_vector(7 downto 0);
   signal   delay_0_to_31_byte_tap : std_logic_vector(7 downto 0);
   signal  delay_32_to_63_byte_tap : std_logic_vector(7 downto 0);
   signal                wt_buffer : std_logic_vector(7 downto 0);
   signal           write_w_buffer : std_logic;

   signal                user_clk  : std_logic;
   signal                clk_nub   : std_logic;
------------------------------------------------------------------------------------
-- Start of circuit description
------------------------------------------------------------------------------------
begin

   --Add a Bufg for clock
   USER_CLOCK: BUFG
   port map (
      O => user_clk,
      I => CLK_IN);

   FPGA_LS1_EN <= '1';

   ----------------------------------------------------------------------------------------------------------------------------------
   -- Open Collector Bidirectional data interface to DS28E01  
   ----------------------------------------------------------------------------------------------------------------------------------
   --
   -- The 1-wire interface is an open collector interface with an external pull-up resistor (R101) of 680 Ohms 
   -- fitted on the board. 
   --
   -- For Spartan-3E to transmit a Low signal, the output buffer must be enabled with a data value of '0'.
   -- To transmit a High, the output buffer is disabled (tri-state) and the external pull-up generates the '1'.
   -- Receiving a bit is again performed with the output buffer disabled.
   --
   --
   DS_WIRE <= '0' when (drive_ds_wire='0') else 'Z';

   ----------------------------------------------------------------------------------------------------------------------------------
   -- 'Wt' word buffer 
   ----------------------------------------------------------------------------------------------------------------------------------
   --
   -- The SHA-1 algorithm requires a buffer capable of holding 16 words of 32-bits (64 bytes) of data.
   --
   -- Before starting the algorithm, the buffer is loaded with an initial table of values known as the 'M' words 
   -- M0 though to M15. As the algorithm progresses, these 'M' words are read and then gradually replaced with a  
   -- series of 'Wt' words W0 through to W79. 
   --
   -- Each 'Wt' word is formed in one of two ways depending in the iteration step 't'.
   --
   --   For t=0 to t=15 then 
   --      Wt = Mt
   --
   --   For t=16 to t=79 then 
   --      Wt = rotate_left_one_position(Wt-3 xor Wt-8 xor Wt-14 xor Wt-16) 
   -- 
   -- It can be seen that for the later iterations, a history of the 16 previous 'W' words is required. The 
   -- following circuit implements this buffer as a shift register. Because PicoBlaze is an 8-bit processor and 
   -- all communication with the DS28E01 device is byte based, this shift register is also implemented with 8-bit
   -- ports. As such, each 32-bit word ('M' or 'W') will actually be stored as 4 successive bytes (it was
   -- more convenient for PicoBlaze code to store these words most significant byte first).
   --
   -- Initially PicoBlaze will write the 16 'M' words by shifting in the 64 bytes in ascending order. Once the 
   -- SHA-1 algorithm starts, PicoBlaze will spend the first 16 iterations reading the values back out of the 
   -- shift register and shifting the same values back in as 'Wt' words W0 through to W15. 
   --
   -- During the remaining iterations, PicoBlaze is able to read the values of the delayed 'Wt' words by reading 
   -- the following ports.
   --
   --    Wt-3   byte0 = input port 08 
   --           byte1 = input port 09
   --           byte2 = input port 0A
   --           byte3 = input port 0B
   --           
   --    Wt-8   byte0 = input port 1C 
   --           byte1 = input port 1D
   --           byte2 = input port 1E
   --           byte3 = input port 1F
   --           
   --   Wt-14   byte0 = input port 34 
   --           byte1 = input port 35
   --           byte2 = input port 36
   --           byte3 = input port 37
   --           
   --   Wt-16   byte0 = input port 3C 
   --           byte1 = input port 3D
   --           byte2 = input port 3E
   --           byte3 = input port 3F
   --           
   --
   -- The buffer is implemented efficiently using the SRL16E and SRLC16E modes of the look-up tables combined with
   -- the dedicated F5 and F6 multiplexers. This means that only 16 slices are required to implement this buffer. 
   --
   --
   -- SRL16E and SRLC16E data storage.
   -- Instantiated to ensure perfect packing into 2 slices per bit.
   --
   data_width_loop: for i in 0 to 7 generate
   --
   attribute INIT : string; 
   attribute INIT of   w1_to_w4_buffer : label is "0000"; 
   attribute INIT of   w5_to_w8_buffer : label is "0000"; 
   attribute INIT of  w9_to_w12_buffer : label is "0000"; 
   attribute INIT of w13_to_w16_buffer : label is "0000"; 
   --
   begin

      --Stages 1 to 16  

      w1_to_w4_buffer: SRLC16E
      --synthesis translate_off
      generic map (INIT => X"0000")
      --synthesis translate_on
      port map(   D => out_port(i),    
                 CE => write_w_buffer,
                CLK => user_clk,
                 A0 => port_id(0),
                 A1 => port_id(1),
                 A2 => port_id(2),
                 A3 => port_id(3),
                  Q => delay_0_to_15_byte_tap(i),
                Q15 => delay_15_byte_tap(i) );

      --Stages 17 to 32  

      w5_to_w8_buffer: SRLC16E
      --synthesis translate_off
      generic map (INIT => X"0000")
      --synthesis translate_on
      port map(   D => delay_15_byte_tap(i),
                 CE => write_w_buffer,
                CLK => user_clk,
                 A0 => port_id(0),
                 A1 => port_id(1),
                 A2 => port_id(2),
                 A3 => port_id(3),
                  Q => delay_16_to_31_byte_tap(i),
                Q15 => delay_31_byte_tap(i) );

      --Stages 33 to 48 

      w9_to_w12_buffer: SRLC16E
      --synthesis translate_off
      generic map (INIT => X"0000")
      --synthesis translate_on
      port map(   D => delay_31_byte_tap(i),    
                 CE => write_w_buffer,
                CLK => user_clk,
                 A0 => port_id(0),
                 A1 => port_id(1),
                 A2 => port_id(2),
                 A3 => port_id(3),
                  Q => delay_32_to_47_byte_tap(i),
                Q15 => delay_47_byte_tap(i) );

      --Stages 49 to 64 

      w13_to_w16_buffer: SRL16E
      --synthesis translate_off
      generic map (INIT => X"0000")
      --synthesis translate_on
      port map(   D => delay_47_byte_tap(i),    
                 CE => write_w_buffer,
                CLK => user_clk,
                 A0 => port_id(0),
                 A1 => port_id(1),
                 A2 => port_id(2),
                 A3 => port_id(3),
                  Q => delay_48_to_63_byte_tap(i));
    
      delay_0_to_31_muxf5: MUXF5
      port map(  I1 => delay_16_to_31_byte_tap(i),
                 I0 => delay_0_to_15_byte_tap(i),
                  S => port_id(4),
                  O => delay_0_to_31_byte_tap(i));

      delay_32_to_63_muxf5: MUXF5
      port map(  I1 => delay_48_to_63_byte_tap(i),
                 I0 => delay_32_to_47_byte_tap(i),
                  S => port_id(4),
                  O => delay_32_to_63_byte_tap(i));

      delay_0_to_63_muxf6: MUXF6
      port map(  I1 => delay_32_to_63_byte_tap(i),
                 I0 => delay_0_to_31_byte_tap(i),
                  S => port_id(5),
                  O => wt_buffer(i));

   end generate data_width_loop;

   ----------------------------------------------------------------------------------------------------------------------------------
   -- KCPSM6 and the program memory 
   ----------------------------------------------------------------------------------------------------------------------------------
   kcpsm6_sleep <= '0';

   processor: kcpsm6
   generic map (      hwbuild => X"00", 
             interrupt_vector => X"3FF",
      scratch_pad_memory_size => 64)
   port map(          address => address,
                  instruction => instruction,
                  bram_enable => bram_enable,
                      port_id => port_id,
                 write_strobe => write_strobe,
               k_write_strobe => k_write_strobe,
                     out_port => out_port,
                  read_strobe => read_strobe,
                      in_port => in_port,
                    interrupt => interrupt,
                interrupt_ack => interrupt_ack,
                        sleep => kcpsm6_sleep,
                        reset => RESET,
                          clk => user_clk);
  
   ------------------------------------------------------------------------------------
   -- PicoBlaze program memory
   ------------------------------------------------------------------------------------
   program_rom: sha1prog
   port map(address => address,
        instruction => instruction,
             enable => bram_enable,
                clk => user_clk);

   ------------------------------------------------------------------------------------
   -- serial true random number generator
   ------------------------------------------------------------------------------------
   rand_gen: rnd
   port map(o   => rbit,
            clk => user_clk);

   ------------------------------------------------------------------------------------
   -- KCPSM6 input port
   ------------------------------------------------------------------------------------

   --
   -- UART FIFO status signals to form a bus
   -- 
   status_port <= "000" & rx_full & rx_half_full & rx_data_present & tx_full & tx_half_full;

   --
   -- The inputs connect via a pipelined multiplexer
   --
   input_reg: process(user_clk)
   begin
      if rising_edge(user_clk) then
         case port_id(7 downto 6) is
            -- read the 16 word (64-byte) 'Wt' buffer in the address range 00 to 3F.
            when "00" => in_port <= wt_buffer;
            -- read status signals at address 40 hex
            when "01" => in_port <= status_port;
            -- read UART receive data at address 80 hex
            when "10" => in_port <= rx_data;
            -- UART status and read DS28E01 at address C0 hex (ds_wire is bit 0)
            when "11" => in_port <= "000000" & rbit & DS_WIRE;
            -- Don't care used for all other addresses to ensure minimum logic implementation
            when others => in_port <= "XXXXXXXX";  
         end case;

         -- Form read strobe for UART receiver FIFO buffer at address 01 hex.
         -- The fact that the read strobe will occur after the actual data is read by 
         -- the KCPSM3 is acceptable because it is really means 'I have read you'!
  
         if (read_strobe='1' and port_id(7 downto 6)="10") then 
            read_from_uart <= '1';
         else 
            read_from_uart <= '0';
         end if;
      end if;
   end process input_reg;

   ----------------------------------------------------------------------------------------------------------------------------------
   -- KCPSM6 output port
   ----------------------------------------------------------------------------------------------------------------------------------
   output_reg: process(user_clk)
   begin
      if rising_edge(user_clk) then
         if write_strobe='1' then

            -- Write to DS28E01 at 08 hex (bit 0 only)
            if port_id(3)='1' then
               drive_ds_wire <= out_port(0);  
            end if;
         end if;
      end if; 
   end process output_reg;

   --
   -- write to UART transmitter FIFO buffer at address 04 hex.
   -- This is a combinatorial decode because the FIFO is the 'port register'.
   --
   write_to_uart <= '1' when (write_strobe='1' and port_id(2)='1') else '0';

   --
   -- write to 'W' word buffer at address 10 hex.
   -- This is a combinatorial decode because the shift register is the 'port register'.
   --
   write_w_buffer <= '1' when (write_strobe='1' and port_id(4)='1') else '0';

   ----------------------------------------------------------------------------------------------------------------------------------
   -- UART  
   ----------------------------------------------------------------------------------------------------------------------------------
   -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
   -- Each contains an embedded 16-byte FIFO buffer.
   --

   transmit: uart_tx 
   port map (  data_in => out_port, 
          write_buffer => write_to_uart,
          reset_buffer => '0',
          en_16_x_baud => en_16_x_baud,
            serial_out => SERIAL_TX,
           buffer_full => tx_full,
      buffer_half_full => tx_half_full,
                   clk => user_clk );

   receive: uart_rx
   port map (   serial_in => SERIAL_RX,
                 data_out => rx_data,
              read_buffer => read_from_uart,
             reset_buffer => '0',
             en_16_x_baud => en_16_x_baud,
      buffer_data_present => rx_data_present,
              buffer_full => rx_full,
         buffer_half_full => rx_half_full,
                      clk => user_clk );  
   
   --
   -- Set baud rate to 9600 for the UART communications
   -- Requires en_16_x_baud to be 153600Hz which is a single cycle pulse every 326 cycles at 50MHz 
   --
   baud_timer: process(user_clk)
   begin
      if rising_edge(user_clk) then
         if baud_count=BaudCountMax then
            baud_count <= 0;
            en_16_x_baud <= '1';
         else
            baud_count <= baud_count + 1;
            en_16_x_baud <= '0';
         end if;
      end if;
   end process baud_timer;

   ----------------------------------------------------------------------------------------------------------------------------------
   -- Interrupt is not used in this version of the design.
   ----------------------------------------------------------------------------------------------------------------------------------
   interrupt <= interrupt_ack;

end RTL;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE SHA1_PROG_TEST.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

