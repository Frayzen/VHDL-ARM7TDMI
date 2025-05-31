library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- CLK: Horloge,
-- RST : reset asynchrone (actif à l’état haut) non représenté sur le schéma
-- W: Bus de donnés en écriture sur 32 bits
-- RA: Bus d’adresses en lecture du port A sur 4 bits
-- RB: Bus d’adresses en lecture du port B sur 4 bits
-- RW: Bus d’adresses en écriture sur 4 bits
-- WE: Write Enable sur 1 bit
-- A: Bus de données en lecture du port A
-- B: Bus de données en lecture du port B
entity Registers is
  port (
        W: in word_t;
        RA, RB, RW: in reg_addr_t;
        A, B : out word_t;
        CLK, RST, WE: in Std_logic
      );
end entity;

architecture Behaviour of Registers is

  -- Init function of the registers
  function init_reg return reg_table_t is
    variable result : reg_table_t;
  begin
    for i in 14 downto 0 loop
      result(i) := (others=>'0');
    end loop;
    result(15):=X"00000030";
    return result;
  end init_reg;

  signal REGS : reg_table_t := init_reg;
begin
  process (CLK, RST)
  begin
    if RST = '1' then
      REGS <= init_reg;
    elsif rising_edge(CLK) then
      if WE = '1' then
        REGS(to_integer(unsigned(RW))) <= W;
      end if;
    end if;
  end process;

  A <= REGS(to_integer(unsigned(RA)));
  B <= REGS(to_integer(unsigned(RB)));

end architecture;

