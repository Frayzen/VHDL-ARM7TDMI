library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;  -- Import all definitions from the package

entity vector_int_controller_tb is
end vector_int_controller_tb;

architecture RTL of vector_int_controller_tb is
    
    signal CLK      : std_logic := '0';
    signal RST    : std_logic := '1';
    signal IRQServ : std_logic := '0';
    signal IRQ0     : std_logic := '0';
    signal IRQ1     : std_logic := '0';
    signal IRQ      : std_logic;
    signal VICPC    : word_t;
    
    signal finished : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;
begin
    
    clk <= not clk after CLK_PERIOD / 2 when finished /= '1' else '0';
    
    process
        procedure run_test(
            reset_val    : in std_logic;
            irq0_val     : in std_logic;
            irq1_val     : in std_logic;
            irq_serv_val : in std_logic;
            exp_irq      : in std_logic;
            exp_vicpc    : in std_logic_vector(31 downto 0)
        ) is
        begin
            RST    <= reset_val;
            IRQ0     <= irq0_val;
            IRQ1     <= irq1_val;
            IRQServ <= irq_serv_val;
            wait for CLK_PERIOD * 2;

            assert IRQ = exp_irq report "IRQ is not as expected" severity error;
            assert VICPC = exp_vicpc report "VICPC is not as expected" severity error;
        end procedure;
    begin
        -- reset_val, irq0_val, irq1_val, irq_serv_val, exp_irq, exp_vicpc
        -- Initial reset
        RST <= '1';
        wait for CLK_PERIOD;

        RST <= '0';
        wait for CLK_PERIOD;
        
        -- Test IRQ0
        
        run_test('0', '1', '0', '0', '1', X"00000010");
        run_test('0', '0', '0', '1', '0', X"00000000");
        
        -- Test IRQ1

        run_test('0', '0', '1', '0', '1', X"00000020");
        run_test('0', '0', '0', '1', '0', X"00000000");
        
        -- Priorite
        run_test('0', '1', '1', '0', '1', X"00000010");
        run_test('0', '0', '0', '1', '1', X"00000020");
        
        -- Sans acquittement

        run_test('0', '1', '0', '0', '1', X"00000010");
        -- L'etat ne change pas
        run_test('0', '0', '0', '0', '1', X"00000010");
        -- Acquittement recu, on reset
        run_test('0', '0', '0', '1', '0', X"00000000");
        
        
        finished <= '1';
        wait;
    end process;

    uut: entity work.vector_int_controller
        port map(
            CLK      => CLK,
            RST    => RST,
            IRQServ => IRQServ,
            IRQ0     => IRQ0,
            IRQ1     => IRQ1,
            IRQ      => IRQ,
            VICPC    => VICPC
        );
end RTL;
