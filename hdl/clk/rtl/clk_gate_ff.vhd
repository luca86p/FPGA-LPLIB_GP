-- =============================================================================
-- Whatis        : neg-edge FF clock enable gate
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : clk_gate_ff.vhd
-- Language      : VHDL-93
-- Module        : clk_gate_ff
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
-- 2020-02-24  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity clk_gate_ff is
    generic (
        RST_POL     : std_logic := '0'
    );
    port (
        rst         : in  std_logic;
        clk         : in  std_logic;
        en          : in  std_logic;
        clk_g       : out std_logic
    );
end clk_gate_ff;

architecture rtl of clk_gate_ff is

    signal clk_en   : std_logic;

begin

    -- neg-edge ff
    proc_ff: process(clk, rst)
    begin
        if rst=RST_POL then
            clk_en      <= '0';
        elsif falling_edge(clk) then
            clk_en      <= en;
        end if;
    end process proc_ff;

    -- and gating
    clk_g   <= clk and clk_en;

end rtl;
