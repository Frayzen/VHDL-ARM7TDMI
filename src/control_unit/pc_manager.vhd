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
      pc : inout word_t;
      offset : in pc_offset_t;
      nPCsel, CLK, RST : in std_logic;
      IRQ, IRQEnd: in std_logic;
      VICPC: in word_t;
      IRQServ: out std_logic
	);
end entity;

architecture  RTL of pc_manager is
    signal ext_offset, cur_pc, lr : word_t := (others => '0');
    signal irq_handling : std_logic;	
begin
    
    PC_EXTENDER : entity work.sign_extender generic map (n => 24)
    port map (
      E => offset, 
      S => ext_offset
    );
    process(CLK, RST)
    begin
      if rst = '1' then
        cur_pc <= (others => '0');
	irq_handling <= '0';
        IRQServ <= '0';
      elsif rising_edge(CLK) then
	IRQServ <= '0';
	if IRQ = '1' and irq_handling = '0' then
	  lr <= pc;
	  cur_pc <= VICPC;
	  irq_handling <= '1';
	  IRQServ <= '1';
	elsif IRQEnd = '1' then
 	  cur_pc <= std_logic_vector(unsigned(lr) + 1);
          irq_handling <= '0';
  	else
  	
	  if nPCsel = '0' then
	    cur_pc <= Std_Logic_Vector(unsigned(cur_pc) + 1);
	  else
	    cur_pc <= Std_Logic_Vector(unsigned(cur_pc) + unsigned(ext_offset) + 1);
	  end if;
	end if;

	      
      end if;
    end process;

    pc <= cur_pc;
end architecture;
