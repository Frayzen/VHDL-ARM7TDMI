library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity PSR_TB is
end PSR_TB;


-- -----------------------------------
architecture RTL of PSR_TB is
-- -----------------------------------

    signal RST      : std_logic := '0';
    signal CLK      : std_logic := '0';
    signal WE       : std_logic := '0';
    signal DATAIN   : word_t := (others => '0');
    signal DATAOUT  : word_t := (others => '0');
    
begin
    proc: process
        procedure run_test(
            rst_val    : in std_logic;
            we_val : in std_logic;
            datain_val : in word_t;
            expected : in word_t
        ) is
        begin
            DATAIN <= datain_val;
            RST <= rst_val;
            WE  <= we_val;
            wait for 10 ns;
            
            if DATAOUT /= expected then
                assert false report "Test failed" severity error;
            else
                assert false report "Test passed" severity note;
            end if;
        end procedure;
        
    begin
        CLK <= '1';
        -- Test write ok
        run_test('0', '1', X"00005678", X"00005678");
                
        -- Test write nok, previous value
        run_test('0', '1', X"12345678", X"00005678");

        -- Test reset
        run_test('1', '1', X"12345678", X"00000000");

        
        wait;
    end process;

    uut: entity work.PSR port map (
        DATAIN => DATAIN,
        RST => RST,
        CLK => CLK,
        WE => WE,
        DATAOUT => DATAOUT
    );
end RTL;
