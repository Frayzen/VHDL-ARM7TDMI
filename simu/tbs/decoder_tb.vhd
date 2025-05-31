library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder_tb is
end decoder_tb;

architecture RTL of decoder_tb is

    signal instruction : std_logic_vector(31 downto 0);
    signal PSR         : std_logic_vector(31 downto 0) := (others => '0');

    signal nPCSel  : std_logic;
    signal RegWr   : std_logic;
    signal ALUSrc  : std_logic;
    signal ALUCtr  : std_logic_vector(2 downto 0);
    signal PSREn   : std_logic;
    signal MemWr   : std_logic;
    signal WrSrc   : std_logic;
    signal RegSel  : std_logic;
    signal RegAff  : std_logic;

begin

    process
        procedure run_test(
            instr_val     : in std_logic_vector(31 downto 0);
            psr_val       : in std_logic_vector(31 downto 0);
            expected_nPCSel  : in std_logic;
            expected_RegWr : in std_logic;
            expected_ALUSrc : in std_logic;
            expected_ALUCtr : in std_logic_vector(2 downto 0);
            expected_PSREn  : in std_logic;
            expected_MemWr : in std_logic;
            expected_WrSrc  : in std_logic;
            expected_RegSel : in std_logic;
            expected_RegAff : in std_logic
        ) is
        begin
            instruction <= instr_val;
            PSR <= psr_val;
            wait for 10 ns;

            assert nPCSel = expected_nPCSel report "nPCSel failed" severity failure;
            assert RegWr  = expected_RegWr report "RegWr failed" severity failure;
            assert ALUSrc = expected_ALUSrc report "ALUSrc failed" severity failure;
            assert ALUCtr = expected_ALUCtr report "ALUCtr failed" severity failure;
            assert PSREn  = expected_PSREn  report "PSREn failed" severity failure;
            assert MemWr  = expected_MemWr report "MemWr failed" severity failure;
            assert WrSrc  = expected_WrSrc  report "WrSrc failed" severity failure;
            assert RegSel = expected_RegSel report "RegSel failed" severity failure;
            assert RegAff = expected_RegAff report "RegAff failed" severity failure;

            report "Test passed" severity note;
        end procedure;
    begin

        -- ADDi R2, R2, #1
        run_test(X"E2883032", (others => '0'), '0', '1', '1', "000", '0', '0', '0', '0', '0');

        -- ADDr R2, R2, R0
        run_test(X"E0812005", (others => '0'), '0', '1', '0', "000", '0', '0', '0', '0', '0');

        -- BAL
        run_test(X"EAFFFFF7", (others => '0'), '1', '0', '0', "000", '0', '0', '0', '0', '0');

        -- BLT avec N=1
        run_test(X"BAFFFFFB", X"00000008", '1', '0', '0', "000", '0', '0', '0', '0', '0');

        -- BLT avec N=0
        run_test(X"BAFFFFFB", (others => '0'), '0', '0', '0', "000", '0', '0', '0', '0', '0');

        -- CMP R2, #0x20
        run_test(X"E3520020", (others => '0'), '0', '0', '1', "010", '1', '0', '0', '0', '0');        
        
        -- LDR R0, [R1]
        run_test(X"E6121000", (others => '0'), '0', '1', '1', "000", '0', '0', '1', '1', '0');

        -- MOV R1, #0x20
        run_test(X"E3A01020", (others => '0'), '0', '1', '1', "001", '0', '0', '0', '0', '0');

        -- STR R0, [R1]
        run_test(X"E6012000", (others => '0'), '0', '0', '1', "000", '0', '1', '0', '1', '1');

        -- NOP
        run_test(X"FFFFFFFF", (others => '0'), '0', '0', '0', "000", '0', '0', '0', '0', '0');

        wait;
    end process;

    uut: entity work.decoder
        port map (
            instruction => instruction,
            PSR         => PSR,
            nPCSel      => nPCSel,
            RegWr       => RegWr,
            ALUSrc      => ALUSrc,
            ALUCtr      => ALUCtr,
            PSREn       => PSREn,
            MemWr       => MemWr,
            WrSrc       => WrSrc,
            RegSel      => RegSel,
            RegAff      => RegAff
        );

end RTL;
