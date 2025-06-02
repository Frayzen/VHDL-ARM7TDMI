library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity processor is
    port (
      CLK, RST, IRQ0 : in std_logic;
      GPIO      : inout std_logic_vector(35 downto 0);
      RegDisp : out word_t;
      dbgInstruction : out word_t
    );
end entity;

architecture rtl of processor is
  signal offset : pc_offset_t;
  signal instruction, psrOut, RegBOut, RegAOut, VICPC : word_t;
  signal Rm, Rd, Rn, muxOut : reg_addr_t;
  signal Imm : imm_t;
  signal flags, savedFlags, flagsALU : flags_t;
  signal ALUCtr      : std_logic_vector(2 downto 0);
  signal IRQ, IRQServ : std_logic;
  signal nPCSel, RegWr, ALUSrc, PSREn, MemWr, WrSrc, RegSel, RegAff, IRQEnd: std_logic;
  signal UART_CONF : uart_byte_t;
  signal UART_GO : std_logic;
  signal current_instruction : enum_instruction;
  signal IRQ0_front : std_logic := '0';
  signal TXIRQ : std_logic := '0';
  signal IRQ0_debouncer : unsigned(30 downto 0);
  signal psrWE : std_logic := '0';
  signal pc : word_t;

begin
  
  process (clk, rst)
  begin
    if rst = '1' then
      IRQ0_front <= '0';
    elsif rising_edge(clk) then
      if IRQ0 = '1' then
        if IRQ0_debouncer = 0 then
          IRQ0_front <= '1'; 
        else
          IRQ0_front <= '0'; 
        end if;
        IRQ0_debouncer <= IRQ0_debouncer + 1;
      else
        IRQ0_front <= '0'; 
        IRQ0_debouncer <= (others => '0');
      end if;
    end if;
  end process;

  with IRQEnd select
    flags <= flagsALU when '0',
             savedFlags when '1',
             (others => 'Z') when others;

  Rn <= instruction(19 downto 16);
  Rd <= instruction(15 downto 12);
  Rm <= instruction(3 downto 0);
  Imm <= instruction(7 downto 0);
  offset <= instruction(23 downto 0);
  dbgInstruction <= instruction;

  psrWE <= RegAff when RegAOut /= x"00000040" else '0';

  UART_GO <= '1' when current_instruction = STR and RegAOut = x"00000040" else '0';
  with UART_GO select
        UART_CONF <= RegBOut(7 downto 0) when '1',
        (others => '0') when others;

  VIC : entity work.vector_int_controller 
  port map (
    CLK => CLK,
    RST => RST,
    IRQServ => IRQServ,
    IRQ0 => IRQ0_front,
    IRQ1 => TXIRQ,
    IRQ => IRQ,
    VICPC => VICPC
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
    flags => flagsALU,
    immCom => ALUSrc,
    resCom => WrSrc,
    RegBOut => RegBOut,
    RegAOut => RegAOut
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
    DATAIN => RegBOut,
    WE => psrWE,
    DATAOUT => RegDisp
  );

  PC_MANAGER : entity work.pc_manager
  port map (
    offset => offset,
    nPCsel => nPCsel,
    pc => pc,
    CLK => CLK,
    RST => RST,
    IRQ => IRQ,
    IRQEnd => IRQEnd,
    VICPC => VICPC,
    IRQServ => IRQServ,
    flags => flags,
    savedFlags => savedFlags
   );

  UART_DEV : entity work.UART_DEV
  port map (
      RST => RST,
      CLK => CLK,
      GO => UART_GO,
      GPIO => GPIO,
      UART_Conf => UART_CONF,
      TXIRQ => TXIRQ
  );

	INSTRUCTION_MEM_IRQ : entity work.instruction_memory
	  port map (
		 PC => pc,
		 Instruction => instruction
	  );


end architecture;
