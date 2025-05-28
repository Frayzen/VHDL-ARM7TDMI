library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import the register types

entity mux_tb is
end entity;

architecture Bench of mux_tb is
    -- Component signals
    signal A, B, S : std_logic_vector(3 downto 0); -- 4-bit addresses
    signal COM : STD_LOGIC;
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiation of the Registers entity
    regs: entity work.mux generic map(4)
    port map (
      A => A,
      B => B,
      S => S,
      COM => COM
    );
    -- Stimulus process
    stim_proc: process
    begin
        A <= "0001";
        B <= "1000";
        COM <= '0';
        wait for CLK_PERIOD;
        assert (S = "0001") report "Error: unexpected value of S (got " & to_bstring(S) & " expected 0001)" severity error;
        COM <= '1';
        wait for CLK_PERIOD;
        assert (S = "1000") report "Error: unexpected value of S (got " & to_bstring(S) & " expected 1000)" severity error;
        -- End of test
        wait;
    end process;

end architecture;
