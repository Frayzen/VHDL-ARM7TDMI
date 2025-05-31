library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity Processing_Unit_TB is
end entity Processing_Unit_TB;

architecture Testbench of Processing_Unit_TB is
    -- Test signals
    signal OP : op_t;
    signal RA, RB, RW : reg_addr_t;
    signal CLK, RST, MemWr, RegWr, immCom, resCom : std_logic := '0';
    signal FLAGS : flags_t;
    signal Imm : imm_t;
    signal dbgRegAOut, dbgRegBOut : word_t;
    
    constant CLK_PERIOD : time := 10 ns;
    signal FINISHED : std_logic := '0';
    
    function to_reg_addr(value : integer) return reg_addr_t is
    begin
        return std_logic_vector(to_unsigned(value, reg_addr_t'length));
    end function;
    
    function to_imm(value : integer) return imm_t is
    begin
        return std_logic_vector(to_signed(value, imm_t'length));
    end function;

    function word_to_string(w: word_t) return string is
    begin
        return integer'image(to_integer(signed(w)));
    end function;
begin
  DUT: entity work.Processing_Unit
        port map (
            OP => OP,
            RA => RA,
            RB => RB,
            RW => RW,
            CLK => CLK,
            RST => RST,
            MemWr => MemWr,
            RegWr => RegWr,
            immCom => immCom,
            resCom => resCom,
            FLAGS => FLAGS,
            Imm => Imm,
            dbgRegAOut => dbgRegAOut,
            dbgRegBOut => dbgRegBOut
        );
    
    CLK <= not CLK after CLK_PERIOD / 2 when FINISHED /= '1' else '0';
    
    STIM_PROC: process
    begin
        -- Initialize all registers to known values
        RST <= '1';
        wait for CLK_PERIOD*2;
        RST <= '0';
        wait for CLK_PERIOD;
        
        -- 1. Initialize R1 with 5 (immediate)
        report "Test 1: R1 = 5 (immediate value)";
        OP <= "001";  -- busB operation
        RW <= to_reg_addr(1);
        Imm <= to_imm(5);
        immCom <= '1';
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        immCom <= '0';
        RA <= to_reg_addr(1);
        wait for CLK_PERIOD;
        assert dbgRegAOut = x"00000005" report "R1 should be 5 after immediate write" severity error;

        -- 2. Initialize R2 with 10 (immediate)
        report "Test 2: R2 = 5 (immediate value)";
        OP <= "001";  -- busB operation
        RW <= to_reg_addr(2);
        Imm <= to_imm(10);
        immCom <= '1';
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        immCom <= '0';
        RA <= to_reg_addr(2);
        wait for CLK_PERIOD;
        assert dbgRegAOut = x"0000000A" report "Reg2 should be 10 after immediate write" severity error;

        -- 3. R3 = R1 + R2 (5 + 10 = 15)
        report "Test 3: R3 = R1 + R2 (5 + 10 = 15)";
        OP <= "000";  -- ADD
        RA <= to_reg_addr(1);
        RB <= to_reg_addr(2);
        RW <= to_reg_addr(3);
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        RB <= to_reg_addr(3);
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after addition, got " & to_string(FLAGS) severity error;
        assert dbgRegBOut = x"0000000F" report "Reg3 should be 15, got " & word_to_string(dbgRegBOut) severity error;
        
        -- 4. R4 = R1 + 7 (5 + 7 = 12)
        report "Test 4: R4 = R1 + 7 (immediate)";
        OP <= "000";  -- ADD
        RA <= to_reg_addr(1);
        RW <= to_reg_addr(4);
        Imm <= to_imm(7);
        immCom <= '1';
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        immCom <= '0';
        RA <= to_reg_addr(4);
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after immediate add, got " & to_string(FLAGS) severity error;
        assert dbgRegAOut = x"0000000C" report "Reg7 should be 12, got " & word_to_string(dbgRegAOut) severity error;
        
        -- 5. R5 = R2 - R1 (10 - 5 = 5)
        report "Test 5: R5 = R2 - R1 (10 - 5 = 5)";
        OP <= "010";  -- SUB
        RA <= to_reg_addr(2);
        RB <= to_reg_addr(1);
        RW <= to_reg_addr(5);
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        RB <= to_reg_addr(5);
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after subtraction, got " & to_string(FLAGS) severity error;
        assert dbgRegBOut = x"00000005" report "Reg5 should be 5, got " & word_to_string(dbgRegBOut) severity error;
        
        -- 6. R6 = R2 - 3 (10 - 3 = 7)
        report "Test 6: R6 = R2 - 3 (immediate)";
        OP <= "010";  -- SUB
        RA <= to_reg_addr(2);
        RW <= to_reg_addr(6);
        Imm <= to_imm(3);
        immCom <= '1';
        RegWr <= '1';
        wait for CLK_PERIOD;
        RA <= to_reg_addr(6);
        RegWr <= '0';
        immCom <= '0';
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after immediate sub, got " & to_string(FLAGS) severity error;
        assert dbgRegAOut = x"00000007" report "Reg7 should be 7, got " & word_to_string(dbgRegAOut) severity error;
        
        -- 7. R7 = R3 (copy value 15)
        report "Test 7: R7 = R3 (copy value 15)";
        OP <= "011";  -- busA
        RA <= to_reg_addr(3);
        RW <= to_reg_addr(7);
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        RA <= to_reg_addr(7);
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after copy, got " & to_string(FLAGS) severity error;
        assert dbgRegAOut = x"0000000F" report "Reg7 should be 15, got " & word_to_string(dbgRegAOut) severity error;
        
        -- 8. MEM[R5] = R3 (address 5 = value 15)
        report "Test 8: MEM[R5] = R3 (address 5 = value 15)";
        OP <= "011";  -- busA (address)
        RA <= to_reg_addr(5);  -- Address (5)
        RB <= to_reg_addr(3);  -- Data (15)
        resCom <= '1';         -- Memory operation
        MemWr <= '1';
        wait for CLK_PERIOD;
        MemWr <= '0';
        resCom <= '0';
        wait for CLK_PERIOD;
        
        -- 9. R8 = MEM[R5] (should be 15)
        report "Test 9: R8 = MEM[R5] (should be 15)";
        OP <= "011";  -- busA (address)
        RA <= to_reg_addr(5);  -- Address (5)
        RW <= to_reg_addr(8);  -- Destination
        resCom <= '1';         -- Memory operation
        RegWr <= '1';
        wait for CLK_PERIOD;
        RegWr <= '0';
        resCom <= '0';
        RA <= to_reg_addr(8);
        wait for CLK_PERIOD;
        assert FLAGS = "0000" report "Flags should be 0000 after memory read, got " & to_string(FLAGS) severity error;
        assert dbgRegAOut = x"0000000F" report "Reg8 should be 15 for address, got " & word_to_string(dbgRegAOut) severity error;
        
        report "All tests completed successfully";
        FINISHED <= '1';
        wait;
    end process;
    
end architecture Testbench;
