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
    subtype uart_byte_t is std_logic_vector(7 downto 0); -- UART byte
    subtype imm_t is std_logic_vector(7 downto 0); -- Immediate value type
    subtype pc_offset_t is std_logic_vector(23 downto 0); -- PC offset type
    type RAM64x32 is array (0 to 63) of std_logic_vector (31 downto 0);
end package types;
