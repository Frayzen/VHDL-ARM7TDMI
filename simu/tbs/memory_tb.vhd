library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity Memory_tb is
end entity;

architecture Bench of Memory_tb is
    -- Component signals
    signal Addr : data_addr_t;
    signal DataIn, DataOut : word_t;
    signal CLK, RST, WE, FINISHED : std_logic := '0';
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiation of the Memory entity
    regs: entity WORK.Memory
    port map (
    Addr => Addr,
    DataOut => DataOut,
    DataIn => DataIn,
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
        DataIn <= (others => '0');
        wait for CLK_PERIOD;
        
        -- Release reset
        RST <= '0';
        wait for CLK_PERIOD;
        
        -- Test 1: Write to register 5
        Addr <= std_logic_vector(to_unsigned(5, 6));
        DataIn <= x"ABCD1234";
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (DataOut = x"ABCD1234") report "Error: unexpected value of A (got " & to_hstring(DataOut) & " expected ABCD1234)" severity error;

        -- Test 2: Read from register 5 (should maintain value)
        Addr <= std_logic_vector(to_unsigned(5, 6));
        WE <= '0';
        wait for CLK_PERIOD;
        assert (DataOut = x"ABCD1234") report "Error: register 5 not maintaining value" severity error;
        
        -- Test 3: Write and read from register 0
        Addr <= std_logic_vector(to_unsigned(0, 6));
        DataIn <= x"FFFFFFFF";
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (DataOut = x"FFFFFFFF") report "Error: register 0 write/read failed" severity error;
        
        -- Test 4: Simultaneous read and write different registers
        Addr <= std_logic_vector(to_unsigned(3, 6));  -- Write to reg 3
        DataIn <= x"11223344";
        WE <= '1';
        wait for CLK_PERIOD;
        Addr <= std_logic_vector(to_unsigned(5, 6));  -- Read from reg 5 while writing to reg 3
        WE <= '0';
        wait for CLK_PERIOD;
        assert (DataOut = x"ABCD1234") report "Error: wrong value when reading reg 5" severity error;
        Addr <= std_logic_vector(to_unsigned(3, 6));  -- Verify reg 3 write
        wait for CLK_PERIOD;
        assert (DataOut = x"11223344") report "Error: reg 3 write failed" severity error;
        
        -- Test 5: Reset test
        RST <= '1';
        wait for CLK_PERIOD;
        Addr <= std_logic_vector(to_unsigned(5, 6));
        assert (DataOut = x"00000000") report "Error: reset not clearing registers" severity error;
        Addr <= std_logic_vector(to_unsigned(0, 6));
        assert (DataOut = x"00000000") report "Error: reset not clearing register 0" severity error;
        RST <= '0';
        
        -- Test 6: Write enable functionality test
        Addr <= std_logic_vector(to_unsigned(7, 6));
        DataIn <= x"A5A5A5A5";
        WE <= '0';  -- Write disabled
        wait for CLK_PERIOD;
        assert (DataOut = x"00000000") report "Error: write occurred when WE=0" severity error;
        WE <= '1';  -- Write enabled
        wait for CLK_PERIOD;
        assert (DataOut = x"A5A5A5A5") report "Error: write failed when WE=1" severity error;
        
        -- Test 7: Verify all registers can be written
        for i in 0 to 15 loop
            Addr <= std_logic_vector(to_unsigned(i, 6));
            DataIn <= std_logic_vector(to_unsigned(i+1, 32));  -- i+1 to distinguish from address
            WE <= '1';
            wait for CLK_PERIOD;
            WE <= '0';
            assert (DataOut = std_logic_vector(to_unsigned(i+1, 32))) 
                report "Error: register " & integer'image(i) & " write failed" severity error;
        end loop;
        
        -- End of test
        finished <= '1';
        wait;
    end process;

end architecture;
