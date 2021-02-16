-- =============================================================================
-- Whatis        : basetime generator for milliseconds range
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : basetime_ms.vhd
-- Language      : VHDL-93
-- Module        : basetime_ms
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Pulse generator, function of basetime period.
--      * CLK_FREQ      : clk frequency in Hz.
--      * BASE_PERIOD   : the basetime in ms.
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


entity basetime_ms is
    generic (
        RST_POL         : std_logic := '0';
        CLK_FREQ        : positive  := 20000000; -- Hz
        BASE_PERIOD     : positive  := 1 -- ms
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        dbg_x10         : in  std_logic;
        base_out        : out std_logic
    );
end basetime_ms;


architecture rtl of basetime_ms is

     -- setup counter for the basetime period
    constant TIMEOUT        : integer := integer(real(CLK_FREQ)*real(BASE_PERIOD)/1.0e3);
    constant TIMEOUT_10     : integer := integer(real(TIMEOUT)/10.0);
    constant TOP_OF_CNT     : integer := TIMEOUT-1;
    constant TOP_OF_CNT_10  : integer := TIMEOUT_10-1;
    constant NBIT           : integer := integer(CEIL(LOG2(real(TIMEOUT))));
    --
    signal cnt              : unsigned(NBIT-1 downto 0);
    signal cnt_top          : integer range 0 to TOP_OF_CNT;

     -- internal base out
    signal base_out_s       : std_logic;

begin

    cnt_top <= TOP_OF_CNT when dbg_x10='0' else TOP_OF_CNT_10;

    -- basetime timer
    -- ----------------------------------------------------------------
    proc_basetime: process(clk,rst)
    begin
        if rst=RST_POL then
            cnt         <= (others=>'0');
            base_out_s  <= '0';
        elsif rising_edge(clk) then
            --
            base_out_s  <= '0'; -- default
            --
            if en='1' then
                if cnt/=cnt_top then
                    cnt         <= cnt + 1;
                else
                    cnt         <= (others=>'0');
                    base_out_s  <= '1';
                end if;
            else
                cnt         <= (others=>'0');
            end if;
            --
        end if;
    end process proc_basetime;

    base_out    <= base_out_s;


end rtl;
