library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;  -- Import all definitions from the package

-- Opcode:
-- ADD -> 000
-- busB   -> 001
-- SUbusB -> 010
-- busA   -> 011
-- OR  -> 100
-- AND -> 101
-- XOR -> 110
-- NOT -> 111

-- OP: opcode
-- RA: Bus d’adresses en lecture du port busA sur 4 bits
-- RB: Bus d’adresses en lecture du port busB sur 4 bits
-- RW: Bus d’adresses en écriture sur 4 bits
-- CLK: Horloge,
-- RST : reset asynchrone (actif à l’état haut) non représenté sur le schéma
-- RegWr: Register Write Enable sur 1 bit
-- WrEn: Memory Write Enable sur 1 bit
-- FLAGS: Flags (NZCV)
entity Processing_Unit is
  port (
        OP : in op_t;
        RA, RB, RW: in reg_addr_t;
        CLK, RST, WrEn, RegWr, immCom, resCom: in Std_logic;
        FLAGS : out flags_t;
        Imm : imm_t
      );
end entity;

architecture Behaviour of Processing_Unit is
  signal busA, busB, aluOut, dataOut, busW, muxOut, immOut : word_t;
begin

  REGS : entity work.Registers port Map
  (
    W => busW,
    RA => RA,
    RB => RB,
    RW => RW,
    A => busA,
    B => busB,
    CLK => CLK,
    RST => RST,
    WE => RegWr
  );

  ALU : entity work.ALU
  port map (
    OP => OP,
    A => busA,
    B => muxOut,
    S => aluOut,
    FLAGS => FLAGS
  );

  muxPreALU : entity work.mux generic map (n => 32)
  port map (
    A => busB,
    B => immOut,
    COM => immCom,
    S => muxOut
  );

  muxPostALU : entity work.mux generic map (n => 32)
  port map (
    A => aluOut,
    B => dataOut,
    COM => resCom,
    S => busW
  );

  MEM : entity work.Memory port Map
  (
    Addr => ALUout(5 downto 0),
    DataIn => busB,
    DataOut => dataOut,
    CLK => CLK,
    RST => RST,
    WE => WrEn
  );

  IMM_EXT : entity work.sign_extender generic map(n => 32)
  port Map
  (
    E => Imm,
    S => immOut
  );

end architecture;

