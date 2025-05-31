library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity processor is
    port (
      CLK, RST : in std_logic
    );
end entity;

architecture rtl of processor is
  signal offset : pc_offset_t;
  signal instruction, psrOut : word_t;
  signal muxOut, Rm, Rd, Rn : reg_addr_t;
  signal Imm : imm_t;
  signal flags : flags_t;
  signal ALUCtr      : std_logic_vector(2 downto 0);
  signal nPCSel, RegWr, ALUSrc, PSREn, MemWr, WrSrc, RegSel, RegAff: std_logic;
begin

  Rn <= instruction(19 downto 16);
  Rd <= instruction(15 downto 12);
  Rm <= instruction(3 downto 0);
  Imm <= instruction(7 downto 0);
  offset <= instruction(23 downto 0);

  INSTR_MANAGER : entity work.instruction_manager
  port map (
    CLK => CLK, 
    RST => RST,
    offset => offset,
    nPCsel => nPCsel,
    instruction => instruction
  );

  DECODER : entity work.decoder
  port map (
    instruction => instruction,
    PSR => psrOut,
    MemWr => MemWr,
    PSREn => PSREn,
    WrSrc => WrSrc,
    RegWr => RegWr,
    ALUSrc => ALUSrc,
    RegSel => RegSel,
    ALUCtr => ALUCtr,
    nPCSel => nPCSel,
    RegAff => RegAff

  );
  
  RB_MUX : entity work.mux generic map(n => 4)
  port map (
    S => muxOut,
    A => Rm,
    B => Rd,
    COM => RegSel
  );

  PROCESS_UNIT : entity work.Processing_Unit
  port map (
    RegWr => RegWr,
    CLK => CLK,
    RW => Rd,
    RA => Rn,
    RB => muxOut,
    OP => ALUCtr,
    Imm => Imm,
    RST => RST,
    MemWr => MemWr,
    flags => flags,
    immCom => ALUSrc,
    resCom => WrSrc
  );

  REG_PSR : entity work.PSR
  port map (
    RST => RST,
    CLK => CLK,
    WE => PSREn,
    DATAIN => x"0000000" & flags,
    DATAOUT => psrOut
  );

end architecture;
