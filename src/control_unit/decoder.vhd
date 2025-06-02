library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity decoder is
    port (
        instruction : in word_t;
        PSR         : in word_t;

        nPCSel      : out std_logic;
        RegWr       : out std_logic;
        ALUSrc      : out std_logic;
        ALUCtr      : out std_logic_vector(2 downto 0);
        PSREn       : out std_logic;
        MemWr       : out std_logic;
        WrSrc       : out std_logic;
        RegSel      : out std_logic;
        RegAff      : out std_logic;
        IRQEnd      : out std_logic;
        current_instruction : out enum_instruction
    );
end entity;

architecture rtl of decoder is
  signal curr_instruction : enum_instruction;
begin
  current_instruction <= curr_instruction;

    process(instruction)
    begin
        -- Opcode
        case instruction(31 downto 20) is
            when X"E3A" => -- MOV
                curr_instruction <= MOV;
            when X"E08" => -- ADDr
                curr_instruction <= ADDr;
            when X"E28" => -- ADDi
                curr_instruction <= ADDi;
            when X"E35" => -- CMP
                curr_instruction <= CMP;
            when X"E61" => -- LDR
                curr_instruction <= LDR;
            when X"E60" => -- STR
                curr_instruction <= STR;
            when X"EAF" => -- BAL
                curr_instruction <= BAL;
            when X"0A0" => -- BEQ
                curr_instruction <= BEQ;
            when X"BAF" => -- BLT
                curr_instruction <= BLT;
            when X"EB0" => -- BX
                curr_instruction <= BX;
            when others => 
                curr_instruction <= NOP;
        end case;
    end process;

    process(curr_instruction, PSR)
    begin
        -- Set a 0 
        nPCSel <= '0';
        RegWr  <= '0';
        ALUSrc <= '0';
        ALUCtr <= "000";
        PSREn  <= '0';

        MemWr  <= '0';
        WrSrc  <= '0';
        RegSel <= '0';
        RegAff <= '0';
	IRQEnd <= '0';
        case curr_instruction is

            when MOV =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "001";

            when ADDi =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "000";

            when ADDr =>
                RegWr  <= '1';
                ALUSrc <= '0';
                ALUCtr <= "000";

            when CMP =>
                ALUSrc <= '1';
                ALUCtr <= "010";
                PSREn  <= '1';

            when LDR =>
                RegWr  <= '1';
                ALUSrc <= '1';
                ALUCtr <= "000";
                WrSrc  <= '1';
                RegSel <= '1';

            when STR =>
                ALUSrc <= '1';
                ALUCtr <= "000";
                MemWr  <= '1';
                RegSel <= '1';
                RegAff <= '1';

            when BAL =>
                nPCSel <= '1';

            when BLT =>
                if PSR(3) = '1' then -- on check le flag N (NZCV)
                    nPCSel <= '1';
                end if;

            when BEQ =>
                if PSR(2) = '1' then -- on check le flag Z (NZCV)
                    nPCSel <= '1';
                end if;

            when BX =>
                IRQEnd <= '1';
            when others =>
                null;

        end case;

    end process;

end architecture;
