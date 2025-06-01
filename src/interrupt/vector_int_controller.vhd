library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vector_int_controller is
    port(
        CLK      : in std_logic;
        RST    : in std_logic;
        IRQServ : in std_logic; 
        IRQ0     : in std_logic;
        IRQ1     : in std_logic;
        IRQ      : out std_logic;
        VICPC    : out std_logic_vector(31 downto 0)
    );
end entity vector_int_controller;

architecture RTL of vector_int_controller is
    signal IRQ0_memo, IRQ1_memo : std_logic := '0';
    signal IRQ_internal : std_logic := '0'; -- Signal intermediaire
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            IRQ0_memo <= '0';
            IRQ1_memo <= '0';
            IRQ_internal <= '0';
            VICPC <= (others => '0');
        elsif rising_edge(CLK) then

            -- Capture des fronts montants
            if IRQ0 = '1' and IRQ0_memo = '0' then
                IRQ0_memo <= '1';
            end if;
            
            if IRQ1 = '1' and IRQ1_memo = '0' then
                IRQ1_memo <= '1';
            end if;
            
            -- Acquittement
            if IRQServ = '1' then
                if IRQ0_memo = '1' then
                    IRQ0_memo <= '0';
                elsif IRQ1_memo = '1' then
                    IRQ1_memo <= '0';
                end if;
            end if;
            
            -- Maj de l'adresse
            if IRQ0_memo = '1' then
                VICPC <= X"00000009";
            elsif IRQ1_memo = '1' then
                VICPC <= X"00000015";
            else
                VICPC <= (others => '0');
            end if;
            
            IRQ_internal <= IRQ0_memo or IRQ1_memo;
        end if;
    end process;
    
    IRQ <= IRQ_internal;
end architecture RTL;
