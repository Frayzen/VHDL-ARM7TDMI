library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- Opcode:
-- ADD -> 000
-- B   -> 001
-- SUB -> 010
-- A   -> 011
-- OR  -> 100
-- AND -> 101
-- XOR -> 110
-- NOT -> 111

-- OP: opcode
-- RA: Bus d’adresses en lecture du port A sur 4 bits
-- RB: Bus d’adresses en lecture du port B sur 4 bits
-- RW: Bus d’adresses en écriture sur 4 bits
-- CLK: Horloge,
-- RST : reset asynchrone (actif à l’état haut) non représenté sur le schéma
-- WE: Write Enable sur 1 bit
-- FLAGS: Flags (NZCV)
entity Processing_Unit is
  port (
        OP : in op_t;
        RA, RB, RW: in reg_addr_t;
        CLK, RST, WE: in Std_logic;
        FLAGS : out flags_t
      );
end entity;

architecture Behaviour of Processing_Unit is
  signal A, B, RES : word_t;
begin

  REGS : entity work.Registers port Map
  (
    W => RES,
    RA => RA,
    RB => RB,
    RW => RW,
    A => A,
    B => B,
    CLK => CLK,
    RST => RST,
    WE => WE
  );

  ALU : entity work.ALU
  port map (
    OP => OP,
    A => A,
    B => B,
    S => RES,
    FLAGS => FLAGS
  );

end architecture;

