library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

Entity UART_DEV is
  Port (  CLK       : in  std_logic;                          -- System Clock at Fxtal
          RST       : in  std_logic;                          -- Asynchronous Reset active high
          UART_Conf : uart_byte_t;                            -- Byte to send
          GPIO      : inout std_logic_vector(35 downto 0);    -- GPIO ports
          GO        : in  std_logic                           -- 1 to Send the byte
       );
end UART_DEV;


Architecture RTL of UART_DEV is
  signal tick_tx, TxBusy, Tx, LD : std_logic;
begin

GPIO(0) <= Tx;
LD <= GO and not TxBusy;  

fdiv_tx: entity work.FDIV
    port map (
        Clk       => CLK,
        Reset     => RST,
        Tick      => TICK_TX,
        Tick_half => open
    );

UART_TX: entity work.UART_TX
    port map (
        Clk   => CLK,
        Reset => RST,
        LD    => LD,
        Din  => UART_Conf,
        Tick  => TICK_TX,
        Tx_Busy => TxBusy,
        Tx    => Tx
    );

end RTL;
