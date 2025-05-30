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
      nPCsel, CLK, RST : in std_logic
    );
end entity;

architecture impl of instruction_manager is
    signal pc : word_t;
begin
    
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
