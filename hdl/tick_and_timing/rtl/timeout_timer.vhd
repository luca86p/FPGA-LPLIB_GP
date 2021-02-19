-- =============================================================================
-- Whatis        : 
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : timeout_timer.vhd
-- Language      : VHDL-93
-- Module        : timeout_timer
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
-- 2019-09-06  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity timeout_timer is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8;
        USE_PIPE        : integer range 0 to 1 := 0
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        load            : in  std_logic;
        load_value      : in  std_logic_vector(NBIT-1 downto 0);
        timer_cnt       : out std_logic_vector(NBIT-1 downto 0);
        timer_to        : out std_logic
    );
end entity timeout_timer;


architecture rtl of timeout_timer is

    signal cnt      : unsigned (NBIT-1 downto 0);

    signal to_s     : std_logic;
    signal to_p     : std_logic;

begin

    proc_timer: process(clk,rst)
    begin
        if rst=RST_POL then
            cnt     <= (others=>'0');
        elsif rising_edge(clk) then
            if load='1' then
                cnt     <= unsigned(load_value);
            elsif cnt/=0 then
                cnt     <= cnt - 1;
            end if;
        end if;
    end process proc_timer;

    timer_cnt   <= std_logic_vector(cnt);

    to_s    <= '1' when cnt=0 else '0';

    gen_to_PIPE_0: if USE_PIPE=0 generate
        to_p    <= to_s;
    end generate gen_to_PIPE_0;

    gen_to_PIPE_1: if USE_PIPE=1 generate
        proc_to_pipe: process (rst,clk)
        begin
            if rst=RST_POL then
                to_p    <= '1';
            elsif rising_edge(clk) then
                to_p    <= to_s;
            end if;
        end process proc_to_pipe;
    end generate gen_to_PIPE_1;

    timer_to    <= to_p;


end rtl;
