library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- INSTUCTION: outputs the current instruction
-- OFFSET: gather the offset to add
-- nPCsel: select either to increment PC by 1 (0) or by OFFSET (1)
-- CLK: clock
-- RST: reset pc to 0
entity instruction_manager is
    port (
      instruction : out word_t;
      offset : in pc_offset_t;
      nPCsel, CLK, RST : in std_logic;
      IRQ, IRQEnd : in std_logic;
      VICPC : in word_t;
      IRQServ : out std_logic
    );
end entity;

architecture impl of instruction_manager is
    signal pc : word_t;
    signal lr : word_t;
    signal irq_handling : std_logic := '0';
begin
  -- interrupts
  process(CLK, RST)
    begin
        if RST = '1' then
            lr <= (others => '0');
            irq_handling <= '0';
            IRQServ <= '0';
        elsif rising_edge(CLK) then
            IRQServ <= '0';
            
            if IRQ = '0' and irq_handling = '0' then
                lr <= pc;
  		pc <= VICPC;
                irq_handling <= '1';
                IRQServ <= '1';
            elsif IRQEnd = '1' then
                pc <= std_logic_vector(unsigned(lr) + 1);
                irq_handling <= '0';
            end if;
        end if;
    end process;




  PC_MANANGER : entity work.pc_manager
  port map (
    offset => offset,
    nPCsel => nPCsel,
    pc => pc,
    CLK => CLK,
    RST => RST
   );

  INSTRUCTION_MEM : entity work.instruction_memory
  port map (
    PC => pc,
    Instruction => instruction
  );
end architecture;
