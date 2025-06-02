library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity instruction_memory_IRQ_INT is
	port(
		    PC: in std_logic_vector (31 downto 0);
		    Instruction: out std_logic_vector (31 downto 0)
	    );
end entity;
architecture RTL of instruction_memory_IRQ_INT is
	type RAM64x32 is array (0 to 63) of std_logic_vector (31 downto 0);
	function init_mem return RAM64x32 is
		variable ram_block : RAM64x32;
	begin
    -- PC -- INSTRUCTION -- COMMENTAIRE
      ram_block(0 ) := x"E3A01010"; -- _main : MOV R1,#0x10   ; -- R1 <= 0x10
      ram_block(1 ) := x"E3A02000"; --         MOV R2,#0      ; -- R2 <= 0
      ram_block(2 ) := x"E6110000"; -- _loop : LDR R0,0(R1)   ; -- R0 <= MEM[R1]
      ram_block(3 ) := x"E0822000"; --         ADD R2,R2,R0   ; -- R2 <= R2 + R0
      ram_block(4 ) := x"E2811001"; --         ADD R1,R1,#1   ; -- R1 <= R1 + 1
      ram_block(5 ) := x"E351001A"; --         CMP R1,0x1A    ; -- R1 = 0x1A
      ram_block(6 ) := x"BAFFFFFB"; --         BLT loop       ; -- branchement à _loop si R1 inferieur a 0x1A
      ram_block(7 ) := x"E3A0100F"; --         MOV R1,#0xF    ; -- R1 = 0xF
      ram_block(8 ) := x"E6012000"; --         STR R2,0(R1)   ; -- MEM[R1] <= R2
      ram_block(9 ) := x"EAFFFFF6"; --         BAL main       ; -- branchement à _main
		-- ISR 0 : interruption 0
      --sauvegarde du contexte
      ram_block(16 ):= x"E60F1000"; --        STR R1,0(R15)  ; -- MEM[R15] <= R1
      ram_block(17) := x"E28FF001"; --         ADD R15,R15,1  ; -- R15 <= R15 + 1
      ram_block(18) := x"E60F2000"; --         STR R2,0(R15)  ; -- MEM[R15] <= R2
      --traitement
      ram_block(19) := x"E3A06001"; --         MOV R6,0x01    ; -- R6 <= 0x01
      ram_block(20) := x"E6162000"; --         LDR R2,0(R6)   ; -- R2 <= MEM[R6]
      ram_block(21) := x"E3A01040"; --         MOV R1,#0x40   ; -- R1 = 0x40
      ram_block(22) := x"E6012000"; --         STR R2,0(R1)   ; -- DATAMEM[R1] = R2
      -- restauration du contexte
      ram_block(23) := x"E61F2000"; --         LDR R2,0(R15)  ; -- R2 <= MEM[R15]
      ram_block(24) := x"E28FF0FF"; --         ADD R15,R15,-1 ; -- R15 <= R15 - 1
      ram_block(25) := x"E61F1000"; --         LDR R1,0(R15)  ; -- R1 <= MEM[R15]
      ram_block(26) := x"EB000000"; --         BX             ; -- instruction de fin d'interruption
      ram_block(27) := x"00000000";


    -- ISR1 : interruption 1
      --sauvegarde du contexte - R15 correspond au pointeur de pile
      ram_block(32) := x"E60F1000"; --         STR R1,0(R15)  ; -- MEM[R15] <= R1
      ram_block(33) := x"E28FF001"; --         ADD R15,R15,1  ; -- R15 <= R15 + 1
      ram_block(34) := x"E60F2000"; --         STR R2,0(R15)  ; -- MEM[R15] <= R2

      --traitement
      ram_block(35) := x"E2866001"; --         ADD R6,R6,#1   ; -- R6 <= R6 + 1
      ram_block(36) := x"E6162000"; --         LDR R2,0(R6)   ; -- R2 <= MEM[R6]
      ram_block(37) := x"E3A01040"; --         MOV R1,#0x40   ; -- R1 = 0x40
      ram_block(38) := x"E3520000"; --         CMP R2,0x00    ; -- R2 = 0x00
      ram_block(39) := x"0A000001"; --         BEQ _end       ; -- branchement à _end
      ram_block(40) := x"E6012000"; --         STR R2,0(R1)   ; -- DATAMEM[R1] = R2

      -- restauration du contexte
      ram_block(41) := x"E61F2000"; --         LDR R2,0(R15)  ; -- R2 <= MEM[R15]
      ram_block(42) := x"E28FF0FF"; --         ADD R15,R15,-1 ; -- R15 <= R15 - 1
      ram_block(43) := x"E61F1000"; --         LDR R1,0(R15)  ; -- R1 <= MEM[R15]
      ram_block(44) := x"EB000000"; --         BX             ; -- instruction de fin d'interruption
      ram_block(46 to 63) := (others=> x"00000000");
		return ram_block;
	end init_mem;
	signal mem: RAM64x32 := init_mem;
begin
	Instruction <= mem(to_integer (unsigned (PC)));
end architecture;
