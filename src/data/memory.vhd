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
    for i in 26 downto 16 loop
      result(i) := x"00000001";
    end loop;
    result(1 ) := x"00000048"; -- H
    result(2 ) := x"00000065"; -- e
    result(3 ) := x"0000006C"; -- l
    result(4 ) := x"0000006C"; -- l
    result(5 ) := x"0000006F"; -- o
    result(6 ) := x"00000020"; -- SPACE 
    result(7 ) := x"00000057"; -- W
    result(8 ) := x"0000006F"; -- o
    result(9 ) := x"00000072"; -- r
    result(10) := x"0000006C"; -- l
    result(11) := x"00000064"; -- d
    result(12) := x"00000021"; -- !
    result(13) := x"00000000"; -- \0
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

