library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX is
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Rx           : in std_logic;                    -- GPIO input
        Tick_halfbit : in std_logic;
        Clear_fdiv   : out std_logic;
        Err          : out std_logic;                   -- Error
        Dav          : out std_logic;                   -- Data available
        Data         : out std_logic_vector(7 downto 0) -- Data
    );
end UART_RX;

architecture RTL of UART_RX is
  type StateType is (Idle,Setup,WaitHTick,InitBit,StartRead,Reading,Inc,EndRead,CheckBit,ErrRaise,Finishing);
  signal state : StateType;
  signal reg : std_logic_vector(7 downto 0);
  signal Dav_sig, Err_sig          : std_logic;
  signal i : integer range 0 to 15;
begin

  Data <= reg;
  Dav <= Dav_sig;
  Err <= Err_sig;

  process (Clk, Reset)
  begin
    if Reset = '1' then
      state <= Idle; 
      i <= 0;
      Err_sig <= '0';
      Dav_sig <= '0';
      reg <= x"00";
      Clear_fdiv <= '0';
    elsif rising_edge(Clk) then
      case state is

      when Idle => if Rx = '0' then
        Clear_fdiv <= '1';
        i <= 0;
        state <= Setup;
      end if;

      when Setup =>
          Err_sig <= '0';
          Dav_sig <= '0';
          state <= WaitHTick;
          reg <= x"00";
          Clear_fdiv <= '0';

      when WaitHTick =>
        if Tick_halfbit = '1' then
          if Rx = '1' then
            state <= ErrRaise;
          else
            state <= InitBit;
          end if;
        end if;

      when InitBit =>
        if Tick_halfbit = '1' then
          state <= StartRead;
        end if;

      when StartRead =>
        if Tick_halfbit = '1' then
          reg(i) <= Rx;
          state <= Inc;
        end if;

      when Reading => 
        if Tick_halfbit = '1' then
          reg(i) <= Rx;
          state <= Inc;
        end if;

      when Inc => 
        if Tick_halfbit = '1' then
          if i = 7 then
            state <= EndRead;
          else 
            i <= i + 1;
            state <= Reading;
          end if;
        end if;

      when EndRead =>
        if Tick_halfbit = '1' then
          state <= CheckBit;
        end if;

      when CheckBit =>
        if Tick_halfbit = '1' then
          if Rx = '0' then
            state <= ErrRaise;
          else
            state <= Finishing;
          end if;
        end if;

      when Finishing =>
        Dav_sig <= '1';
        i <= 0;
        state <= Idle;

      when ErrRaise =>
        Err_sig <= '1';
        state <= Idle;
      end case;
    end if;
  end process;

end RTL;

