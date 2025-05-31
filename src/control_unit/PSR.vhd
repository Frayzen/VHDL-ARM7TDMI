library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PSR is
    port (
        DATAIN   : in  std_logic_vector(31 downto 0);
        RST      : in  std_logic;
        CLK      : in  std_logic;
        WE       : in  std_logic;
        DATAOUT  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture  RTL of PSR is
    signal reg : std_logic_vector(31 downto 0) := (others => '0');
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
