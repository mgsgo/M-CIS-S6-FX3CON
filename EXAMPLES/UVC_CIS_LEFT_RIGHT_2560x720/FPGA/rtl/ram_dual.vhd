LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

ENTITY ram_dual IS
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
END ram_dual;

ARCHITECTURE rtl OF ram_dual IS

TYPE MEM IS ARRAY(NUMWORDS-1 downto 0) OF std_logic_vector(DATA_WIDTH -1 downto 0);

SIGNAL ram_block : MEM;
SIGNAL read_address_reg    : std_logic_vector(ADDR_WIDTH -1 downto 0);

begin

PROCESS (clock1)
BEGin
   IF (clock1'event AND clock1 = '1') THEN
      IF (we = '1') THEN
         ram_block(conv_integer(write_address)) <= data;
      END IF;
   END IF;
END PROCESS;

PROCESS (clock2)
BEGin
   IF (clock2'event AND clock2 = '1') THEN
      read_address_reg <= read_address;
   END IF;
END PROCESS;

q <= ram_block(conv_integer(read_address_reg));

END rtl;
