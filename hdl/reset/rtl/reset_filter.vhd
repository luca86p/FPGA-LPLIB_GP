-- =============================================================================
-- Whatis        : reset filter: asynch assertion - synch deassertion
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : reset_filter.vhd
-- Language      : VHDL-93
-- Module        : reset_filter
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  * krst (king reset) has 3 x ff deassertion latency
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
-- 2019-09-26  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity reset_filter is
    generic (
        RST_POL         : std_logic := '0'
    );
    port (
        rst             : in  std_logic;
        clk             : in  std_logic;
        krst            : out std_logic
    );
end entity reset_filter;


architecture rtl of reset_filter is

    -- king reset (glitch free)
    signal rst_d1   : std_logic;
    signal rst_d2   : std_logic;
    signal rst_d3   : std_logic;
    signal krst_s   : std_logic;

begin

    -- king reset (glitch free)
    -- ----------------------------------------
    proc_rst_synch: process(clk,rst)
    begin
        if rst=RST_POL then
            rst_d1 <= RST_POL;
            rst_d2 <= RST_POL;
            rst_d3 <= RST_POL;
        elsif rising_edge(clk) then
            rst_d1 <= not RST_POL;
            rst_d2 <= rst_d1;
            rst_d3 <= rst_d2;
        end if;
    end process proc_rst_synch;

    krst_s  <= rst_d3;
    krst    <= krst_s;

end rtl;
