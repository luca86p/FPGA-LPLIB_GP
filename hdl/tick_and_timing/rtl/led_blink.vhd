-- =============================================================================
-- Whatis        : 
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : led_blink.vhd
-- Language      : VHDL-93
-- Module        : led_blink
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
-- 2019-10-17  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity led_blink is
    generic (
        RST_POL         : std_logic := '0'
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        base_1ms        : in  std_logic;
        blink_sel       : in  std_logic_vector(2 downto 0);
        led             : out std_logic
    );
end entity led_blink;


architecture rtl of led_blink is

    signal led_blink_cnt    : unsigned(9 downto 0);
    signal led_s            : std_logic;

begin

    proc_led_blink_cnt: process (rst,clk)
    begin
        if rst=RST_POL then
            led_blink_cnt   <= (others=>'0');
            led_s           <= '0';
        elsif rising_edge(clk) then
            if en='0' then -- no blink = off
                led_blink_cnt   <= (others=>'0');
                led_s           <= '0';
            elsif base_1ms='1' then
                --
                led_blink_cnt <= led_blink_cnt + 1;
                --
                if blink_sel="000" then -- no blink = off
                    led_s           <= '0';
                elsif blink_sel="001" then
                    led_s           <= led_blink_cnt(9); -- 1024 ms
                elsif blink_sel="010" then
                    led_s           <= led_blink_cnt(8); -- 512 ms
                elsif blink_sel="011" then
                    led_s           <= led_blink_cnt(7); -- 256 ms
                elsif blink_sel="100" then
                    led_s           <= led_blink_cnt(6); -- 128 ms
                elsif blink_sel="101" then
                    led_s           <= led_blink_cnt(5); -- 64 ms
                elsif blink_sel="110" then
                    led_s           <= led_blink_cnt(4); -- 32 ms
                elsif blink_sel="111" then
                    led_s           <= '1'; -- always on
                end if; -- blink_sel
            end if; -- base_1ms
        end if; -- clk
    end process proc_led_blink_cnt;

    led     <= led_s;

end architecture rtl;
