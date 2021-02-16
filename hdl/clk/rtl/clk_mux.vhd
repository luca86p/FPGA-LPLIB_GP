-- =============================================================================
-- Whatis        : glitch-free clock mux for 2 asynch clock signal
-- Project       : FPGA-LPLIB_ALU
-- -----------------------------------------------------------------------------
-- File          : clk_mux.vhd
-- Language      : VHDL-93
-- Module        : clk_mux
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
-- 2020-05-11  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity clk_mux is
    generic (
        RST_POL     : std_logic := '0'
    );
    port (
        rst         : in  std_logic;
        clk_in_0    : in  std_logic;
        clk_in_1    : in  std_logic;
        sel         : in  std_logic;
        clk_out     : out std_logic
    );
end clk_mux;

architecture rtl of clk_mux is

    signal clk_0_en     : std_logic;
    signal clk_0_en_s0  : std_logic;
    signal clk_0_en_s1  : std_logic;
    signal clk_0_en_g   : std_logic;
    signal clk_0_g      : std_logic;

    signal clk_1_en     : std_logic;
    signal clk_1_en_s0  : std_logic;
    signal clk_1_en_s1  : std_logic;
    signal clk_1_en_g   : std_logic;
    signal clk_1_g      : std_logic;

begin

    -- clk 0
    -- ----------------------------------------
    proc_synch_en_0: process(clk_in_0, rst)
    begin
        if rst=RST_POL then
            clk_0_en_s0     <= '0';
            clk_0_en_s1     <= '0';
        elsif rising_edge(clk_in_0) then
            clk_0_en_s0     <= (not sel) and clk_0_en;
            clk_0_en_s1     <= clk_0_en_s0;
        end if;
    end process proc_synch_en_0;

    proc_gating_0: process(clk_in_0, rst)
    begin
        if rst=RST_POL then
            clk_0_en_g      <= '0';
        elsif falling_edge(clk_in_0) then
            clk_0_en_g      <= clk_0_en_s1;
        end if;
    end process proc_gating_0;
    
    clk_0_g     <= clk_0_en_g and clk_in_0;

    clk_1_en    <= not clk_0_en_g;



    -- clk 1
    -- ----------------------------------------
    proc_synch_en_1: process(clk_in_1, rst)
    begin
        if rst=RST_POL then
            clk_1_en_s0     <= '0';
            clk_1_en_s1     <= '0';
        elsif rising_edge(clk_in_1) then
            clk_1_en_s0     <= sel and clk_1_en;
            clk_1_en_s1     <= clk_1_en_s0;
        end if;
    end process proc_synch_en_1;

    proc_gating_1: process(clk_in_1, rst)
    begin
        if rst=RST_POL then
            clk_1_en_g      <= '0';
        elsif falling_edge(clk_in_1) then
            clk_1_en_g      <= clk_1_en_s1;
        end if;
    end process proc_gating_1;
    
    clk_1_g     <= clk_1_en_g and clk_in_1;

    clk_0_en    <= not clk_1_en_g;



    -- or-ed switched clock
    -- ----------------------------------------
    clk_out     <= clk_0_g or clk_1_g;


end rtl;
