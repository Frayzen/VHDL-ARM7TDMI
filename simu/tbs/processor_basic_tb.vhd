library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity Processor_Basic_tb is
end entity;

architecture Bench of Processor_Basic_tb is
    -- Component signals
    signal CLK, RST, FINISHED, IRQ0 : std_logic := '0';
    signal dbgInstruction : word_t;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiation of the Processor entity
    regs: entity WORK.Processor_Basic
    port map (
      CLK => CLK,
      RST => RST,
      dbgInstruction => dbgInstruction,
      IRQ0 => IRQ0
    );

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2 when finished /= '1' else '0';
    -- IRQ0 <= not IRQ0 after 100 ns when finished /= '1' else '0';

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset initialization
        RST <= '1';
        wait for CLK_PERIOD;
        -- Release reset
        RST <= '0';
        assert dbgInstruction = x"E3A01020" report "First instruction should be loaded" severity error;
        -- Test
        for i in 0 to 52 loop
            wait for CLK_PERIOD;
        end loop;
        -- End of test
        assert dbgInstruction = x"EAFFFFF7" report "Last instruction should be loaded" severity error;
        finished <= '1';
        wait;
    end process;

end architecture;
