library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Assuming this contains op_t, reg_addr_t, flags_t definitions

entity Processing_Unit_TB is
end entity Processing_Unit_TB;

architecture Testbench of Processing_Unit_TB is
    -- Component declaration
    component Processing_Unit is
        port (
            OP : in op_t;
            RA, RB, RW : in reg_addr_t;
            CLK, RST, WE : in std_logic;
            FLAGS : out flags_t
        );
    end component;

    -- Test signals
    signal OP : op_t;
    signal RA, RB, RW : reg_addr_t;
    signal CLK, RST, WE, FINISHED : std_logic := '0';
    signal FLAGS : flags_t;
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Helper function to convert integer to reg_addr_t
    function to_reg_addr(value : integer) return reg_addr_t is
    begin
        return std_logic_vector(to_unsigned(value, reg_addr_t'length));
    end function;
begin
    -- Instantiate the Processing Unit
    DUT: Processing_Unit
        port map (
            OP => OP,
            RA => RA,
            RB => RB,
            RW => RW,
            CLK => CLK,
            RST => RST,
            WE => WE,
            FLAGS => FLAGS
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2 when finished /= '1' else '0';
    
    -- Stimulus process
    STIM_PROC: process
    begin
        -- Initialize inputs
        OP <= (others => '0');
        RA <= (others => '0');
        RB <= (others => '0');
        RW <= (others => '0');
        WE <= '0';
        
        -- Reset the system
        RST <= '1';
        wait for CLK_PERIOD;
        RST <= '0';
        wait for CLK_PERIOD;
        
        -- Test sequence:
        -- 1. R(1) = R(15) (A operation - just copy)
        report "Test 1: R(1) = R(15)";
        OP <= "011";  -- A operation (copy)
        RA <= to_reg_addr(15);  -- Read from R15
        RB <= to_reg_addr(0);   -- Don't care
        RW <= to_reg_addr(1);   -- Write to R1
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (FLAGS = "0000") report "Error: unexpected value of FLAGS (got " & to_bstring(FLAGS) & " expected 0000)" severity error;
        wait for CLK_PERIOD;

        
        -- 2. R(1) = R(1) + R(15) (ADD operation)
        report "Test 2: R(1) = R(1) + R(15)";
        OP <= "000";  -- ADD operation
        RA <= to_reg_addr(1);   -- Read from R1
        RB <= to_reg_addr(15);   -- Read from R15
        RW <= to_reg_addr(1);   -- Write to R1
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (FLAGS = "0000") report "Error: unexpected value of FLAGS (got " & to_bstring(FLAGS) & " expected 0000)" severity error;
        wait for CLK_PERIOD;
        
        -- 3. R(2) = R(1) + R(15) (ADD operation)
        report "Test 3: R(2) = R(1) + R(15)";
        OP <= "000";  -- ADD operation
        RA <= to_reg_addr(1);   -- Read from R1
        RB <= to_reg_addr(15);  -- Read from R15
        RW <= to_reg_addr(2);   -- Write to R2
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (FLAGS = "0000") report "Error: unexpected value of FLAGS (got " & to_bstring(FLAGS) & " expected 0000)" severity error;
        wait for CLK_PERIOD;
        
        -- 4. R(3) = R(1) - R(15) (SUB operation)
        report "Test 4: R(3) = R(1) - R(15)";
        OP <= "010";  -- SUB operation
        RA <= to_reg_addr(1);   -- Read from R1
        RB <= to_reg_addr(15);  -- Read from R15
        RW <= to_reg_addr(3);   -- Write to R3
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (FLAGS = "0000") report "Error: unexpected value of FLAGS (got " & to_bstring(FLAGS) & " expected 0000)" severity error;
        wait for CLK_PERIOD;
        
        -- 5. R(5) = R(7) - R(15) (SUB operation)
        report "Test 5: R(5) = R(7) - R(15)";
        OP <= "010";  -- SUB operation
        RA <= to_reg_addr(7);   -- Read from R7
        RB <= to_reg_addr(15);  -- Read from R15
        RW <= to_reg_addr(5);   -- Write to R5
        WE <= '1';
        wait for CLK_PERIOD;
        WE <= '0';
        assert (FLAGS = "1010") report "Error: unexpected value of FLAGS (got " & to_bstring(FLAGS) & " expected 1000)" severity error;
        wait for CLK_PERIOD;
        
        -- Additional test cases could be added here
        -- For example, test other operations (AND, OR, XOR, NOT)
        
        -- End simulation
        report "Testbench completed successfully";
        finished <= '1';
        wait;
    end process;
    
    -- Monitoring process (optional)
    MONITOR_PROC: process(CLK)
    begin
        if rising_edge(CLK) and WE = '1' then
            report "Operation: " & to_string(OP) & 
                   ", RA: " & to_string(RA) & 
                   ", RB: " & to_string(RB) & 
                   ", RW: " & to_string(RW) &
                   ", FLAGS: " & to_string(FLAGS);
        end if;
    end process;
    
end architecture Testbench;
