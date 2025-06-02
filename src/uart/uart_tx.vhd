library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.types.all;  -- Import all definitions from the package

-- UART Transmitter (TX) module
-- This entity implements a UART transmitter that sends 8-bit data with start and stop bits
-- Configuration: 1 start bit (0), 8 data bits, 1 stop bit (1) - no parity
entity UART_TX is
    port (
        Clk     : in std_logic;          -- System clock
        Reset   : in std_logic;          -- Active-high reset
        LD      : in std_logic;          -- Load signal (initiates transmission when high)
        Din     : in uart_byte_t;         -- 8-bit data input to transmit
        Tick    : in std_logic;          -- Baud rate tick (16x or 1x baud rate)
        TxIrq   : out std_logic;         -- IRQ that raises at end of transmission  
        Tx_Busy : out std_logic;         -- Busy flag (high during transmission)
        Tx      : out std_logic          -- Serial output line
    );
end entity;

architecture RTL of UART_TX is
  -- State machine type definition
  type StateType is (
    Idle,       -- Waiting for transmission request
    Writing,    -- Actively transmitting bits
    Inc,        -- Increment bit counter
    Finishing   -- Finalizing transmission
  );
  
  signal state : StateType;              -- Current state of the FSM
  signal reg   : std_logic_vector(9 downto 0);  -- Shift register (holds start bit, data, stop bit)
  signal i     : integer range 0 to 15;  -- Bit counter (tracks which bit is being transmitted)
  
begin

-- Main state machine process
process(Clk, Reset) begin
    -- Asynchronous reset
    if Reset = '1' then
      state <= Idle; 
      i <= 0;
      Tx_Busy <= '0';
      Tx <= '1';  -- Idle state is high (mark)
      TxIrq <= '0';
    elsif rising_edge(Clk) then
      -- State machine implementation
      case state is
        -- Idle state: waits for load signal
        when Idle => 
          TxIrq <= '0';
          if LD = '1' then
            -- Load the shift register with: stop bit (1), data bits, start bit (0)
            reg <= '1' & Din & '0';
            Tx_Busy <= '1';  -- Signal that transmitter is busy
            i <= 0;          -- Reset bit counter
            state <= Writing; -- Move to writing state
          else
            Tx <= '1';  -- Maintain idle state (mark)
          end if;

        -- Writing state: transmits current bit when tick occurs
        when Writing => 
          if Tick = '1' then
            Tx <= reg(i);     -- Output current bit
            state <= Inc;    -- Move to increment state
          end if;

        -- Increment state: advances to next bit or finishes
        when Inc =>
          i <= i + 1;         -- Move to next bit
          if i >= 9 then      -- Check if all bits transmitted (start + 8 data + stop)
            state <= Finishing;
          else
            state <= Writing; -- Continue transmitting
          end if;

        -- Finishing state: clean up after transmission
        when Finishing =>
          Tx_Busy <= '0';    -- No longer busy
          i <= 0;           -- Reset bit counter
          state <= Idle;     -- Return to idle state
          TxIrq <= '1';
      end case;
    end if;
end process;

end architecture;
