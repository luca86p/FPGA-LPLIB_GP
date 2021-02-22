-- =============================================================================
-- Whatis        : 
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : wd_death.vhd
-- Language      : VHDL-93
-- Module        : wd_death
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  The watchdog is a down-counter.
--  * when enabled, if the counter expires it rise the eoc flag.
--  * when kicked, the counter load the timeout value.
--  Once the eoc is high a death timer starts to down-count from wd_death_timeout.
--  When the second timer expires wd_death_eoc is rised.
--  Once the death flag is high it is suppose to reset the system.
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
-- 2019-02-28  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity wd_death is
    generic (
        RST_POL             : std_logic := '0'
    );
    port (
        rst                 : in  std_logic;
        clk                 : in  std_logic;
        --
        wd_en               : in  std_logic;
        wd_timeout          : in  std_logic_vector(31 downto 0);
        wd_kick             : in  std_logic;
        wd_counter          : out std_logic_vector(31 downto 0);
        wd_eoc              : out std_logic;
        wd_death_timeout    : in  std_logic_vector(31 downto 0);
        wd_death_counter    : out std_logic_vector(31 downto 0);
        wd_death_eoc        : out std_logic
    );
end wd_death;


architecture rtl of wd_death is

    signal cnt          : unsigned(31 downto 0);
    signal eoc          : std_logic;
    signal death_cnt    : unsigned(31 downto 0);
    signal death_eoc    : std_logic;


begin

    -- watchdog timer
    proc_wd_counter: process(rst,clk)
    begin
        if rst=RST_POL then
            cnt <= (others=>'1');
            eoc <= '0';
        elsif rising_edge(clk) then
            if wd_kick='1' then
                cnt <= unsigned(wd_timeout);
            elsif wd_en='1' then
                if cnt=0 then
                    eoc <= '1';
                else
                    cnt <= cnt - 1;
                end if;
            end if;
        end if;
    end process proc_wd_counter;

    wd_counter  <= std_logic_vector(cnt);
    wd_eoc      <= eoc;

    -- death timer
    proc_wd_death: process(rst,clk)
    begin
        if rst=RST_POL then
            death_cnt <= (others=>'0');
            death_eoc <= '0';
        elsif rising_edge(clk) then
            if eoc='0' then
                death_cnt <= unsigned(wd_death_timeout);
            else -- the watchdog is expired, eoc='1'
                if death_cnt=0 then
                    death_eoc <= '1';
                else
                    death_cnt <= death_cnt - 1;
                end if;
            end if;
        end if;
    end process proc_wd_death;

    wd_death_counter  <= std_logic_vector(death_cnt);
    wd_death_eoc      <= death_eoc;

end rtl;
