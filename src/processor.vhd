library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity processor is
    port (
      CLK, RST : in std_logic;
      GPIO      : inout std_logic_vector(35 downto 0);
      RegDisp : out word_t;
      dbgInstruction : out word_t
    );
end entity;

architecture rtl of processor is
  signal offset : pc_offset_t;
  signal instruction, psrOut, RegBOut, busWOut, VICPC : word_t;
  signal Rm, Rd, Rn, muxOut : reg_addr_t;
  signal Imm : imm_t;
  signal flags : flags_t;
  signal ALUCtr      : std_logic_vector(2 downto 0);
  signal IRQ, IRQ0, IRQ1, IRQServ : std_logic;
  signal nPCSel, RegWr, ALUSrc, PSREn, MemWr, WrSrc, RegSel, RegAff, IRQEnd: std_logic;
  signal UART_CONF : uart_byte_t;
  signal UART_GO : std_logic;
  signal current_instruction : enum_instruction;
begin

  Rn <= instruction(19 downto 16);
  Rd <= instruction(15 downto 12);
  Rm <= instruction(3 downto 0);
  Imm <= instruction(7 downto 0);
  offset <= instruction(23 downto 0);
  dbgInstruction <= instruction;

  with RegBOut select
        UART_CONF <= busWOut(7 downto 0) when x"00000040",
        (others => '0') when others;
  UART_GO <= '1' when current_instruction = STR and RegBOut = x"00000040" else '0';

  VIC : entity work.vector_int_controller 
  port map (
    CLK => CLK,
    RST => RST,
    IRQServ => IRQServ,
    IRQ0 => IRQ0,
    IRQ1 => IRQ1,
    IRQ => IRQ,
    VICPC => VICPC
  );


  INSTR_MANAGER : entity work.instruction_manager
  port map (
    CLK => CLK, 
    RST => RST,
    offset => offset,
    nPCsel => nPCsel,
    instruction => instruction,
    IRQ => IRQ,
    IRQEnd => IRQEnd,
    VICPC => VICPC,
    IRQServ => IRQServ
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
    RegAff => RegAff,
    IRQEnd => IRQEnd,
    current_instruction => current_instruction
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
    resCom => WrSrc,
    RegBOut => RegBOut,
    busWOut => busWOut
  );

  REG_PSR : entity work.PSR
  port map (
    RST => RST,
    CLK => CLK,
    WE => PSREn,
    DATAIN => x"0000000" & flags,
    DATAOUT => psrOut
  );

  REG_DISP : entity work.PSR
  port map (
    RST => RST,
    CLK => CLK,
    WE => RegAff,
    DATAIN => RegBOut,
    DATAOUT => RegDisp
  );

  UART_DEV : entity work.UART_DEV
  port map (
      RST => RST,
      CLK => CLK,
      GO => UART_GO,
      GPIO => GPIO,
      UART_Conf => UART_CONF
  );

end architecture;
