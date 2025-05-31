library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- -----------------------------------
entity ALU is
-- -----------------------------------
  port ( OP       : in  op_t;    -- Opcode
         A        : in  word_t;   -- Input A
         B        : in  word_t;   -- Input B
         S        : out word_t;   -- Output S
         FLAGS    : out flags_t     -- Flag (NZCV)
        );
end entity ALU;

-- Opcode:
-- ADD -> 000
-- B   -> 001
-- SUB -> 010
-- A   -> 011
-- OR  -> 100
-- AND -> 101
-- XOR -> 110
-- NOT -> 111
-- N, Z, C, V

-- -----------------------------------
architecture RTL of ALU is
-- -----------------------------------

    signal result     : std_logic_vector(31 downto 0);

    signal carry : std_logic;  -- C (FLAGS(1))
    signal overflow   : std_logic;  -- V (FLAGS(0))
begin
    process(OP, A, B)
        variable temp_add : unsigned(32 downto 0); 
        variable temp_sub : unsigned(32 downto 0);
        variable temp_result : std_logic_vector(31 downto 0);
    begin
        case OP is
            -- ADD (000)
            when "000" =>
                temp_add := unsigned('0' & A) + unsigned('0' & B);
                temp_result := std_logic_vector(temp_add(31 downto 0));
                result   <= temp_result;

                carry <= temp_add(32);
                overflow <= (A(31) and B(31) and not temp_result(31)) or 
                           (not A(31) and not B(31) and temp_result(31));

            -- SUB (010)
            when "010" =>
                temp_sub := unsigned('0' & A) - unsigned('0' & B);
                temp_result := std_logic_vector(temp_sub(31 downto 0));

                result   <= temp_result;

                carry <= temp_sub(32); 
                overflow <= (A(31) and not B(31) and not temp_result(31)) or 
                           (not A(31) and B(31) and temp_result(31));

            -- Pas de traitement specifique pour les autres operations
            when "001" => 
                result <= B;
                carry    <= '0';
                overflow <= '0';
            when "011" => 
                result <= A;
                carry    <= '0';
                overflow <= '0';
            when "100" => 
                result <= A or B;
                carry    <= '0';
                overflow <= '0';
            when "101" => 
                result <= A and B;
                carry    <= '0';
                overflow <= '0';
            when "110" => 
                result <= A xor B;
                carry    <= '0';
                overflow <= '0';
            when "111" => 
                result <= not A; 
                carry    <= '0';
                overflow <= '0';
            when others => 
                result <= (others => '0');
                carry    <= '0';
                overflow <= '0';
        end case;
    end process;

    S <= result;
    FLAGS(3) <= result(31);                             -- N
    FLAGS(2) <= '1' when result = x"00000000" else '0'; -- Z
    FLAGS(1) <= carry;                                  -- C
    FLAGS(0) <= overflow;                               -- V
end architecture RTL;
