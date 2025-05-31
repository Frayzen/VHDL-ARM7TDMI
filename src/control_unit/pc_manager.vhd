library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- PC: outputs the current pc
-- OFFSET: gather the offset to add
-- nPCsel: select either to increment PC by 1 (0) or by OFFSET (1)
-- CLK: clock
-- RST: reset pc to 0
entity pc_manager is
    port (
      pc : out word_t;
      offset : in pc_offset_t;
      nPCsel, CLK, RST : in std_logic
    );
end entity;

architecture  RTL of pc_manager is
    signal ext_offset : word_t;
begin
    
    PC_EXTENDER : entity work.sign_extender generic map (n => 24)
    port map (
      E => offset, 
      S => ext_offset
    );
    process(CLK, RST)
    begin
      if rst = '1' then
        pc <= (others => '0');
      elsif rising_edge(CLK) then
        if nPCsel = '0' then
          pc <= Std_Logic_Vector(unsigned(pc) + 1);
        else
          pc <= Std_Logic_Vector(unsigned(pc) + unsigned(ext_offset) + 1);
        end if;
      end if;
    end process;
end architecture;
