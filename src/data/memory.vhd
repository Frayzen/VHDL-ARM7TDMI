library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- CLK: Horloge,
-- RST : reset asynchrone (actif à l’état haut) non représenté sur le schéma
-- WE: Write Enable sur 1 bit
-- Addr: Bus d’adresses pour l'ecriture et la lecture
-- DataIn: Bus de données en ecriture
-- DataOut: Bus de données en lecture de l'addresse
entity Memory is
  port (
        CLK, RST, WE: in Std_logic;
        Addr: in data_addr_t;
        DataIn : in word_t;
        DataOut : out word_t
      );
end entity;

architecture Behaviour of Memory is

  -- Init function of the registers
  function init_data return data_table_t is
    variable result : data_table_t;
  begin
    for i in 63 downto 0 loop
      result(i) := (others=>'0');
    end loop;
    for i in 42 downto 32 loop
      result(i) := x"00000001";
    end loop;
    return result;
  end init_data;

  signal MEM_CELLS : data_table_t := init_data;
begin
  process (CLK, RST)
  begin
    if RST = '1' then
      MEM_CELLS <= init_data;
    elsif rising_edge(CLK) then
      if WE = '1' then
        MEM_CELLS(to_integer(unsigned(Addr))) <= DataIn;
      end if;
    end if;
  end process;

  DataOut <= MEM_CELLS(to_integer(unsigned(Addr)));

end architecture;

