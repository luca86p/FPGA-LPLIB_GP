-- =============================================================================
-- Whatis        : programmable enable pulse generator
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : en_gen.vhd
-- Language      : VHDL-93
-- Module        : en_gen
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Pulse generator, with prescaler.
--      * pulse_out period is (div+2) clock cycles.
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
-- 2019-09-06  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity en_gen is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        div             : in  std_logic_vector(NBIT-1 downto 0);
        pulse_out       : out std_logic
    );
end en_gen;

architecture rtl of en_gen is

    -- div chain
    signal cnt              : unsigned(NBIT-1 downto 0);
    signal toc              : std_logic;


begin

    -- div counter
    -- ----------------------------------------------------------------
    proc_div: process(clk, rst)
    begin
        if rst=RST_POL then
            cnt     <= (others=>'0');
            toc     <= '0';
        elsif rising_edge(clk) then
            --
            toc     <= '0';
            --
            if en='0' then
                --
                cnt     <= (others=>'0');
                --
            else
                --
                cnt     <= cnt + 1;
                --
                if cnt=unsigned(div) then
                    toc     <= '1';
                end if;
                --
                if toc='1' then
                    cnt     <= (others=>'0');
                end if;
                --
            end if;
        end if;
    end process proc_div;

    pulse_out  <= toc;




end rtl;
