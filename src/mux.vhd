library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- COM: Selection du bus de données (0 = 1er, 1 = 2nd)
-- A: Premier bus de données
-- B: Second bus de données
-- S: Sortie
entity mux is generic (n : positive);
  port (
    A, B : in STD_LOGIC_VECTOR(n - 1 downto 0);
    COM : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR(n - 1 downto 0)
  );
end entity;

architecture Behaviour of mux is
begin
    with COM select
      S <= A when '0',
           B when '1',
      (others => 'Z') when others;

end architecture;

