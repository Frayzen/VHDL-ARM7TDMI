library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- E: Bus de données d'entrée sur n bits
-- S: Sortie sur 32 bit
entity sign_extender is generic (n : integer range 1 to 32);
  port (
    E : in STD_LOGIC_VECTOR(n - 1 downto 0);
    S : out reg_t
  );
end entity;

architecture Behaviour of sign_extender is
begin
   -- Sign extend the n-bit input to 32 bits
    S <= std_logic_vector(resize(signed(E), S'length));
end architecture;

