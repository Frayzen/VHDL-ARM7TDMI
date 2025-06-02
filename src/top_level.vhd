library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

entity top_level is
    port (
      CLOCK_50 : in std_logic;
      GPIO      : inout std_logic_vector(35 downto 0);
      KEY			 	:  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      SW 				:  IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
      HEX0 		 	:  OUT  STD_LOGIC_VECTOR(0 TO 6);
      HEX1 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
      HEX2 			:  OUT  STD_LOGIC_VECTOR(0 TO 6);
      HEX3 			:  OUT  STD_LOGIC_VECTOR(0 TO 6)
    );
end entity;

architecture rtl of top_level is
  signal RegDisp : word_t;
  signal RST, IRQ0 : std_logic;
begin

  RST <= not KEY(0);
  IRQ0 <= not KEY(1);

  REG_PSR : entity work.processor
  port map (
    RST => RST,
    CLK => CLOCK_50,
    RegDisp => RegDisp,
    GPIO => GPIO,
    IRQ0 => IRQ0
  );

  SEG1 : entity work.SEVEN_SEG
  port map (
    Segout => HEX0,
    Data => RegDisp(3 downto 0),
    Pol => SW(9)
  );

  SEG2 : entity work.SEVEN_SEG
  port map (
    Segout => HEX1,
    Data => RegDisp(7 downto 4),
    Pol => SW(9)
  );

  SEG3 : entity work.SEVEN_SEG
  port map (
    Segout => HEX2,
    Data => RegDisp(11 downto 8),
    Pol => SW(9)
  );

  SEG4 : entity work.SEVEN_SEG
  port map (
    Segout => HEX3,
    Data => RegDisp(15 downto 12),
    Pol => SW(9)
  );

end architecture;
