library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity instruction_manager_tb is
end entity;

architecture Bench of instruction_manager_tb is
    -- Component signals
    signal instruction, VICPC : word_t;
    signal offset : pc_offset_t;
    signal nPCSel, CLK, RST : std_logic := '0';
    
    signal IRQ, IRQEnd, IRQServ : std_logic := '0';

    constant CLK_PERIOD : time := 10 ns;
    signal FINISHED : std_logic := '0';
begin
    -- Instantiation of the Registers entity
    regs: entity work.instruction_manager
    port map (
      instruction => instruction,
      offset => offset,
      nPCsel => nPCsel,
      CLK => CLK,
      RST => RST,
      IRQ => IRQ,
      IRQEnd => IRQEnd,
      IRQServ => IRQServ,
      VICPC => VICPC
    );

    CLK <= not CLK after CLK_PERIOD / 2 when FINISHED /= '1' else '0';
    -- Stimulus process
    stim_proc: process
    begin
        VICPC <= X"00000000";
	IRQ <= '0';
	IRQEnd <= '0';
	IRQServ <= '0';

	RST <= '1';
        wait for CLK_PERIOD;
        RST <= '0';
        nPCSel <= '0';
        offset <= x"000004";
        wait for CLK_PERIOD;
        assert (instruction = x"E3A02000") report "Error: unexpected value of S (got " & to_hstring(instruction) & " expected E3A02000)" severity error;
        wait for CLK_PERIOD;
        assert (instruction = x"E6110000") report "Error: unexpected value of S (got " & to_hstring(instruction) & " expected E6110000)" severity error;
        nPCSel <= '1';
        wait for CLK_PERIOD;
        assert (instruction = x"E6012000") report "Error: unexpected value of S (got " & to_hstring(instruction) & " expected E6012000)" severity error;
        -- End of test
        finished <= '1';
        wait;
    end process;

end architecture;
