library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity PSR is
    port (
        DATAIN   : in  word_t;
        RST      : in  std_logic;
        CLK      : in  std_logic;
        WE       : in  std_logic;
        DATAOUT  : out word_t 
    );
end entity;

architecture  RTL of PSR is
    signal reg : word_t := (others => '0');
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            reg <= (others => '0'); 
        elsif rising_edge(CLK) then
            if WE = '1' then
                reg <= DATAIN;
            end if;
        end if;
    end process;
    DATAOUT <= reg;

end architecture;
