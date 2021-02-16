-- =============================================================================
-- Whatis        : digital debouncer input filter
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : debounce_filter.vhd
-- Language      : VHDL-93
-- Module        : debounce_filter
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  Non-Linear input filter, sample the input if stable for a time.
--  The input x is considered already synchronized.
--  N is the width of the counters defining:
--      * the filter reject time window.
--      * the filter acceptance stability window.
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


entity debounce_filter is
    generic (
        RST_POL     : std_logic := '0';
        RST_VAL     : std_logic := '0';
        N           : positive  := 16   -- 65536 Tclk
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        x           : in  std_logic;
        y           : out std_logic
    );
end debounce_filter;

architecture rtl of debounce_filter is

    signal cnt        : unsigned(N-1 downto 0);
    signal filtery    : std_logic;

begin

    proc_debounce: process(clk,rst)
    begin
        if rst=RST_POL then
            cnt         <= (others=>'0');
            filtery     <= RST_VAL;
            y           <= RST_VAL;
        elsif rising_edge(clk) then

            -- default
            y           <= filtery;
            cnt         <= cnt + 1;

            -- filter
            if filtery='0' then
                if x='1' then
                    if cnt=2**N-1 then
                        filtery <= '1';
                    end if;
                else
                    cnt <= (others=>'0');
                end if;
            else -- filtery='1'
                if x='0' then
                    if cnt=2**N-1 then
                        filtery <= '0';
                    end if;
                else
                    cnt <= (others=>'0');
                end if;
            end if;
        end if;
    end process proc_debounce;

end rtl;
