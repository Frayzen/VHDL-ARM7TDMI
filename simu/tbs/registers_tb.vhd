library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity Registers_tb is
end entity;

architecture Bench of Registers_tb is
    -- Component signals
    signal W : reg_t;
    signal RA, RB, RW : std_logic_vector(3 downto 0); -- 4-bit addresses
    signal A, B : reg_t;
    signal CLK, RST, WE, FINISHED : std_logic := '0';
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiation of the Registers entity
    regs: entity WORK.Registers 
    port map (
        W => W,
        RA => RA,
        RB => RB,
        RW => RW,
        A => A,
        B => B,
        CLK => CLK,
        RST => RST,
        WE => WE
    );

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2 when finished /= '1' else '0';

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset initialization
        RST <= '1';
        WE <= '0';
        W <= (others => '0');
        RA <= (others => '0');
        RB <= (others => '0');
        RW <= (others => '0');
        wait for CLK_PERIOD;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: Write to register 5
        RW <= std_logic_vector(to_unsigned(5, 4));
        W <= X"ABCD1234";
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        
        -- Read from register 5 on both ports
        RA <= std_logic_vector(to_unsigned(5, 4));
        RB <= std_logic_vector(to_unsigned(5, 4));
        wait for CLK_PERIOD;
        assert (A = x"ABCD1234") report "Error: unexpected value of A (got " & to_hstring(A) & " expected ABCD1234)" severity error;
        assert (B = x"ABCD1234") report "Error: unexpected value of B (got " & to_hstring(B) & " expected ABCD1234)" severity error;
        
        -- Test 2: Write to register 15 (should have initial value X"00000030")
        RA <= std_logic_vector(to_unsigned(15, 4));
        wait for CLK_PERIOD;
        assert (A = x"00000030") report "Error: unexpected value of A (got " & to_hstring(A) & " expected 00000030)" severity error;
        assert (B = x"ABCD1234") report "Error: unexpected value of B (got " & to_hstring(B) & " expected ABCD1234)" severity error;
        
        -- Test 3: Write to register 0
        RW <= std_logic_vector(to_unsigned(0, 4));
        W <= X"FFFFFFFF";
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        
        -- Read from register 0 on port A and 5 on port B
        RA <= std_logic_vector(to_unsigned(0, 4));
        RB <= std_logic_vector(to_unsigned(5, 4));
        wait for CLK_PERIOD;
        assert (A = x"FFFFFFFF") report "Error: unexpected value of A (got " & to_hstring(A) & " expected FFFFFFFF)" severity error;
        assert (B = x"ABCD1234") report "Error: unexpected value of B (got " & to_hstring(B) & " expected ABCD1234)" severity error;

        -- Test 4: Write disabled 
        RW <= std_logic_vector(to_unsigned(1, 4));
        RA <= std_logic_vector(to_unsigned(1, 4));
        W <= X"12345678";
        WE <= '0';
        wait for CLK_PERIOD;
        assert (A = x"00000000") report "Error: unexpected value of A (got " & to_hstring(A) & " expected 00000000)" severity error;
        WE <= '1';
        wait for CLK_PERIOD;
        assert (A = x"12345678") report "Error: unexpected value of A (got " & to_hstring(A) & " expected 12345678)" severity error;
        
        -- End of test
        finished <= '1';
        wait;
    end process;

end architecture;
