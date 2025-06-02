library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity processor is
    port (
      CLK, RST, IRQ0 : in std_logic;
      RegDisp : out word_t;
      dbgInstruction : out word_t
    );
end entity;

architecture rtl of processor is
  signal offset : pc_offset_t;
  signal instruction, psrOut, RegBOut, VICPC : word_t;
  signal muxOut, Rm, Rd, Rn : reg_addr_t;
  signal Imm : imm_t;
  signal flags : flags_t;
  signal ALUCtr      : std_logic_vector(2 downto 0);
  signal IRQ, IRQ1, IRQServ : std_logic;
  signal nPCSel, RegWr, ALUSrc, PSREn, MemWr, WrSrc, RegSel, RegAff, IRQEnd: std_logic;

  signal inst, inst1, IRQ0_front, IRQ0_clean: std_logic := '0';
begin
  
   -- Pour empecher le bounching, a reverifier !!!
	process(clk, rst)
		 constant DEBOUNCE_DELAY : integer := 500000; -- 10ms at 50MHz
		 variable count : integer range 0 to DEBOUNCE_DELAY;
	begin
		 if rst = '1' then
			  count := 0;
			  IRQ0_clean <= '0';
		 elsif rising_edge(clk) then
			  if IRQ0 = '1' and IRQ0_clean = '0' then
					if count < DEBOUNCE_DELAY then
						 count := count + 1;
					else
						 IRQ0_clean <= '1';
					end if;
			  elsif IRQ0 = '0' then
					IRQ0_clean <= '0';
					count := 0;
			  end if;
		 end if;
	end process;
  
  process (clk, rst)
  begin
	if rst = '1' then
	  inst <= '0'; inst1 <= '0';
	  IRQ0_front <= '0';
	elsif rising_edge(clk) then
	  inst1 <= IRQ0;
	  inst <= inst1;
	  IRQ0_front <= inst and (not inst1);

	end if;
  end process;
  
  
  Rn <= instruction(19 downto 16);
  Rd <= instruction(15 downto 12);
  Rm <= instruction(3 downto 0);
  Imm <= instruction(7 downto 0);
  offset <= instruction(23 downto 0);
  dbgInstruction <= instruction;
	
  
  VIC : entity work.VIC 
  port map (
    CLK => CLK,
    RST => RST,
    IRQServ => IRQServ,
    IRQ0 => IRQ0_front,
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
    IRQEnd => IRQEnd
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
    RegBOut => RegBOut
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

end architecture;
