-- =============================================================================
-- Whatis        : digital pulse input filter
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : pulse_filter.vhd
-- Language      : VHDL-93
-- Module        : pulse_filter
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  Non-Linear input filter, pulse if the input if stable for a time.
--  The input x is considered already synchronized.
--  N is the width of the counters defining:
--      * the filter reject time window.
--      * the filter acceptance stability window.
--
--  MODE:
--      0 - pulse on stable falling edge
--      1 - pulse on stable rising edge (default)
--      2 - pulse on both stable edges
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
-- 2019-06-25  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity pulse_filter is
    generic (
        RST_POL     : std_logic := '0';
        RST_VAL     : std_logic := '0';
        N           : positive  := 4;
        MODE        : integer range 0 to 2 := 1 -- rising default
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        x           : in  std_logic;
        y           : out std_logic;
        yp          : out std_logic
    );
end pulse_filter;

architecture rtl of pulse_filter is

    signal cnt        : unsigned(N-1 downto 0);
    signal filtery    : std_logic;
    signal filtery_d  : std_logic;

begin

    y <= filtery_d; -- aligned with yp

    proc_pulse: process(clk,rst)
    begin
        if rst=RST_POL then
            cnt         <= (others=>'0');
            filtery     <= RST_VAL;
            filtery_d   <= RST_VAL;
            yp          <= '0'; -- registered for timing
        elsif rising_edge(clk) then

            -- default
            filtery_d   <= filtery;
            cnt         <= cnt + 1;

            -- pulse flip-flop -- registered for timing
            if MODE=0 then -- falling edge
                yp        <= (not filtery) and filtery_d;
            elsif MODE=1 then -- rising edge
                yp        <= filtery and (not filtery_d);
            elsif MODE=2 then -- both edges
                yp        <= filtery xor filtery_d;
            end if;

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
    end process proc_pulse;

end rtl;
