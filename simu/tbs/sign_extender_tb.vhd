library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity sign_extender_tb is
end entity;

architecture Bench of sign_extender_tb is
    -- Component signals
    signal E : STD_LOGIC_VECTOR(3 downto 0); -- 4-bit addresses
    signal S : word_t;
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiation of the Registers entity
    regs: entity work.sign_extender generic map(4)
    port map (
      E => E,
      S => S
    );
    -- Stimulus process
    stim_proc: process
    begin
        E <= "0001";
        wait for CLK_PERIOD;
        assert (S = x"00000001") report "Error: unexpected value of S (got " & to_hstring(S) & " expected 00000001)" severity error;
        E <= "1111";
        wait for CLK_PERIOD;
        assert (S = x"ffffffff") report "Error: unexpected value of S (got " & to_hstring(S) & " expected ffffffff)" severity error;
        -- End of test
        wait;
    end process;

end architecture;
