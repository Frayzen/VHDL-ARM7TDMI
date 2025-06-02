library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity pc_manager_tb is
end entity;

architecture Bench of pc_manager_tb is
    -- Component signals
    signal PC, VICPC : word_t;
    signal offset : pc_offset_t;
    signal nPCSel, CLK, RST, IRQ, IRQEnd, IRQServ : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;
    signal FINISHED : std_logic := '0';
    signal flags, savedFlags : flags_t;
begin
    -- Instantiation of the Registers entity
    regs: entity work.pc_manager
    port map (
      pc => PC,
      offset => offset,
      nPCsel => nPCsel,
      CLK => CLK,
      RST => RST,
      IRQ => IRQ,
      IRQEnd => IRQEnd,
      IRQServ => IRQServ,
      VICPC => VICPC,
      flags => flags,
      savedFlags => savedFlags
    );

    CLK <= not CLK after CLK_PERIOD / 2 when FINISHED /= '1' else '0';

    -- Stimulus process
    stim_proc: process
    begin
	VICPC <= X"00000000";
	RST <= '1';
        wait for CLK_PERIOD;
        RST <= '0';

        nPCSel <= '0';
        offset <= x"000004";
        wait for CLK_PERIOD;
        assert (PC = x"00000001") report "Error: unexpected value of S (got " & to_hstring(PC) & " expected 00000001)" severity error;
        wait for CLK_PERIOD;
        assert (PC = x"00000002") report "Error: unexpected value of S (got " & to_hstring(PC) & " expected 00000002)" severity error;
        nPCSel <= '1';
        wait for CLK_PERIOD;
        assert (PC = x"00000007") report "Error: unexpected value of S (got " & to_hstring(PC) & " expected 00000007)" severity error;
        -- End of test
        finished <= '1';
        wait;
    end process;

end architecture;
