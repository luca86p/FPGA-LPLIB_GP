-- =============================================================================
-- Whatis        : 
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : ticker.vhd
-- Language      : VHDL-93
-- Module        : ticker
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Pulse generator, function of tick_toc prescaler.
--      * tick_out period is (tick_toc+1) tick_in cycles.
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


entity ticker is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        tick_in         : in  std_logic;
        tick_out        : out std_logic;
        tick_toc        : in  std_logic_vector(NBIT-1 downto 0);
        tick_cnt        : out std_logic_vector(NBIT-1 downto 0)
    );
end ticker;

architecture rtl of ticker is

    signal cnt_un       : unsigned(NBIT-1 downto 0);
    signal last_cnt     : std_logic;

begin

    -- tick counter
    -- ----------------------------------------------------------------
    proc_tick: process(clk,rst)
    begin
        if rst=RST_POL then
            cnt_un      <= (others=>'0');
            tick_out    <= '0';
        elsif rising_edge(clk) then
            if en='1' then
                if tick_in='1' then
                    if last_cnt='1' then
                        cnt_un      <= (others=>'0');
                        tick_out    <= '1';
                    else
                        cnt_un      <= cnt_un + 1;
                    end if;
                end if;
            else 
                cnt_un      <= (others=>'0');
                tick_out    <= '0';
            end if;
        end if;
    end process proc_tick;

    last_cnt    <= '1' when cnt_un=unsigned(tick_toc) else '0';
    --
    tick_cnt    <= std_logic_vector(cnt_un);

end rtl;
