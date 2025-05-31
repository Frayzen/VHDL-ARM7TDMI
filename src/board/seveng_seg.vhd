-- SevenSeg.vhd
-- ------------------------------
--   squelette de l'encodeur sept segment
-- ------------------------------

--
-- Notes :
--  * Order is : Segout(1)=Seg_A, ... Segout(7)=Seg_G
--
--  * Display Layout :
--
--       A=Seg(1)
--      -----
--    F|     |B=Seg(2)
--     |  G  |
--      -----
--     |     |C=Seg(3)
--    E|     |
--      -----
--        D=Seg(4)


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- ------------------------------
    Entity SEVEN_SEG is
-- ------------------------------
  port ( Data   : in  std_logic_vector(3 downto 0); -- Displayed value
         Pol    : in  std_logic;                    -- '0' if active LOW
         Segout : out std_logic_vector(1 to 7) );   -- Segments A, B, C, D, E, F, G
end entity SEVEN_SEG;

-- -----------------------------------------------
    Architecture COMB of SEVEN_SEG is
-- ------------------------------------------------

  signal raw_segments : std_logic_vector(1 to 7);

begin
  with Data select
    raw_segments <= 
              "1111110" when x"0",
              "0110000" when x"1",
              "1101101" when x"2",
              "1111001" when x"3",
              "0110011" when x"4",
              "1011011" when x"5",
              "1011111" when x"6",
              "1110000" when x"7",
              "1111111" when x"8",
              "1111011" when x"9",
              "1110111" when x"A",
              "0011111" when x"B",
              "1001110" when x"C",
              "0111101" when x"D",
              "1001111" when x"E",
              "1000111" when x"F",
              "-------" when others;	
  Segout <= raw_segments when Pol = '1' else not raw_segments;
end architecture COMB;


