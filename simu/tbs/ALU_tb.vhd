library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_TB is
end ALU_TB;


-- -----------------------------------
architecture RTL of ALU_TB is
-- -----------------------------------

    component ALU
        port (
            OP    : in  std_logic_vector(2 downto 0);
            A     : in  std_logic_vector(31 downto 0);
            B     : in  std_logic_vector(31 downto 0);
            S     : out std_logic_vector(31 downto 0);
            FLAGS : out std_logic_vector(3 downto 0)
        );
    end component;

    signal OP    : std_logic_vector(2 downto 0) := (others => '0');
    signal A     : std_logic_vector(31 downto 0) := (others => '0');
    signal B     : std_logic_vector(31 downto 0) := (others => '0');
    signal S     : std_logic_vector(31 downto 0);
    signal FLAGS : std_logic_vector(3 downto 0);
    
begin
    proc: process
        procedure run_test(
            op_code  : in std_logic_vector(2 downto 0);
            a_val    : in std_logic_vector(31 downto 0);
            b_val    : in std_logic_vector(31 downto 0);
            expected : in std_logic_vector(31 downto 0);
            expected_flags: in std_logic_vector(3 downto 0)) is
        begin
            OP <= op_code;
            A  <= a_val;
            B  <= b_val;
            wait for 10 ns;
            
            if S /= expected or FLAGS /= expected_flags then
                assert false report "Test failed" severity error;
            else
                assert false report "Test passed" severity note;
            end if;
        end procedure;
        
    begin
        -- Flag (NZCV)

        -- Test A
        run_test("011", X"12345678", X"9ABCDEF0", X"12345678", "0000");
                
        -- Test B
        run_test("001", X"12345678", X"9ABCDEF0", X"9ABCDEF0", "1000");

        -- Test ADD
        run_test("000", X"00000001", X"00000002", X"00000003", "0000"); -- 1 + 2 = 3
        run_test("000", X"7FFFFFFF", X"00000001", X"80000000", "1001"); -- Negatif et overflow
        run_test("000", X"FFFFFFFF", X"00000001", X"00000000", "0110"); -- Zero et Carry
        
        -- Test SUB
        -- C a 1 si pas d'emprunt -> confirm stp
        run_test("010", X"00000005", X"00000003", X"00000002", "0000"); -- 5 - 3 = 2, No Borrow
        
        run_test("010", X"00000003", X"00000005", X"FFFFFFFE", "1010"); -- Negatif
        run_test("010", X"80000000", X"00000001", X"7FFFFFFF", "0001"); -- Overflow
        
        -- Test OR 
        run_test("100", X"F0F0F0F0", X"0F0F0F0F", X"FFFFFFFF", "1000");
        run_test("100", X"00000000", X"00000000", X"00000000", "0100");
        
        -- Test AND
        run_test("101", X"FFFFFFFF", X"F0F0F0F0", X"F0F0F0F0", "1000");
        run_test("101", X"12345678", X"00000000", X"00000000", "0100");
        
        -- Test XOR
        run_test("110", X"AAAAAAAA", X"55555555", X"FFFFFFFF", "1000");
        run_test("110", X"12345678", X"12345678", X"00000000", "0100");
        
        -- Test NOT
        run_test("111", X"FFFFFFFF", X"00000000", X"00000000", "0100");
        run_test("111", X"AAAAAAAA", X"12345678", X"55555555", "0000");

        
       
        
        wait;
    end process;

    uut: entity work.ALU
    port map (
        OP    => OP,
        A     => A,
        B     => B,
        S     => S,
        FLAGS => FLAGS
    );
end RTL;
