library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
    subtype word_t is std_logic_vector(31 downto 0);
    subtype data_addr_t is std_logic_vector(5 downto 0); -- Address of some data 
    subtype reg_addr_t is std_logic_vector(3 downto 0); -- Address of the register
    subtype op_t is std_logic_vector(2 downto 0); -- op type of the ALU
    subtype flags_t is std_logic_vector(3 downto 0); -- ALU flags (NZCV)
    type reg_table_t is array (0 to 15) of word_t;
    type data_table_t is array (0 to 63) of word_t;
end package types;
