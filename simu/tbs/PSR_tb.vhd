library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PSR_TB is
end PSR_TB;


-- -----------------------------------
architecture RTL of PSR_TB is
-- -----------------------------------

    component PSR
        port (
            DATAIN   : in  std_logic_vector(31 downto 0);
            RST      : in  std_logic;
            CLK      : in  std_logic;
            WE       : in  std_logic;
            DATAOUT  : out std_logic_vector(31 downto 0)
        );
    end component;


    signal DATAIN   : std_logic_vector(31 downto 0) := (others => '0');
    signal RST      : std_logic := '0';
    signal CLK      : std_logic := '0';
    signal WE       : std_logic := '0';
    signal DATAOUT  : std_logic_vector(31 downto 0) := (others => '0');
    
begin
    proc: process
        procedure run_test(
            rst_val    : in std_logic;
            we_val : in std_logic;
            datain_val : in std_logic_vector(31 downto 0);
            expected : in std_logic_vector(31 downto 0)) is
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

    uut: PSR port map (
        DATAIN => DATAIN,
        RST => RST,
        CLK => CLK,
        WE => WE,
        DATAOUT => DATAOUT
    );
end RTL;