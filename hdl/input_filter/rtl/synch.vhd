-- =============================================================================
-- Whatis        : N-stages FF synchronizer
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : synch.vhd
-- Language      : VHDL-93
-- Module        : synch
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
-- -----------------------------------------------------------------------------
-- Dependencies
-- 
-- -----------------------------------------------------------------------------
-- Issues
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2019-09-09  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity synch is
    generic (
        RST_POL         : std_logic := '0';
        RST_VAL         : std_logic := '0';
        N               : positive  := 2
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        synch_in        : in  std_logic;
        synch_out       : out std_logic;
        synch_out_chain : out std_logic_vector(N-1 downto 0)
    );
end synch;

architecture rtl of synch is

    signal synch_chain : std_logic_vector(N-1 downto 0);

begin

    proc_synch: process(clk,rst)
    begin
        if rst=RST_POL then
            synch_chain <= (others=>RST_VAL);
        elsif rising_edge(clk) then
            if en='1' then
                synch_chain(0) <= synch_in;
                synch_chain(N-1 downto 1) <= synch_chain(N-2 downto 0);
            else
                synch_chain <= (others=>'0');
            end if;
        end if;
    end process proc_synch;

    synch_out       <= synch_chain(N-1);
    synch_out_chain <= synch_chain;

end rtl;
