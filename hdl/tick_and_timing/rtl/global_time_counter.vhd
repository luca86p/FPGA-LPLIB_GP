-- =============================================================================
-- Whatis        : 
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : global_time_counter.vhd
-- Language      : VHDL-93
-- Module        : global_time_counter
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Global time counter with millisecond(s) basetime and s,m,h,d ticks
--  Used for FSM scheduler of tasks.
--  Used for (RTC like)-tag for sensors data labelling.
--
--  * basetime counter for the base_1ms
--  * cnt_ms : [0:999] ms     counter (10 bit)  -> tick_1s
--  * cnt_s  : [0:59]  second counter (6-bit)   -> tick_1m
--  * cnt_m  : [0:59]  minute counter (6-bit)   -> tick_1h
--  * cnt_h  : [0:23]  hour   counter (5-bit)   -> tick_1d
--  * cnt_d  : [:]     day    counter (10-bit)
--
--  2y = 730d = 17.520h = 1.051.200m = 63.072.000s
--  log2(63.072.000) = 25.9 -> 26 bit unsigned for standalone s counter
--
-- DEBUG
--  dbg_fast_ms_x10 : 0 -> base_1ms = 1 ms
--                    1 -> base_1ms = 100 us  (speed ms-basetime of 10)
--  dbg_fast_s_x50  : 0 -> tick_1s  = 1000 ms (if ms_x10=0) 100 ms (if ms_x10=1)
--                    1 -> tick_1s  =   20 ms (if ms_x10=0)   2 ms (if ms_x10=1) 
--
--  e.g. ms_x10=1; s_x50=0 ==> scaling factor = 10
--      1s*=100ms, 1m*=6s, 1h*=6m, 1d*=144m, ...
--
--  e.g. ms_x10=0; s_x50=1 ==> scaling factor = 50
--      1s*=20ms, 1m*=1.2s, 1h*=72s, 1d*=28.8m, ...

--  e.g. ms_x10=1; s_x50=1 ==> scaling factor = 500
--      1s*=2ms, 1m*=120ms, 1h*=7.2s, 1d*=172.8s, ...
--
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
-- 2019-09-09  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User lib
-- ----------------------------------------
library lplib_gp;


entity global_time_counter is
    generic (
        RST_POL         : std_logic := '0';
        CLK_FREQ        : positive  := 20000000 -- Hz
    );
    port (
        rst             : in  std_logic;
        clk             : in  std_logic;
        en              : in  std_logic;
        dbg_fast_ms_x10 : in  std_logic;
        dbg_fast_s_x50  : in  std_logic;
        --
        base_1ms        : out std_logic;
        --
        tick_1s         : out std_logic;
        tick_1m         : out std_logic;
        tick_1h         : out std_logic;
        tick_1d         : out std_logic;
        --
        gtime_ms        : out std_logic_vector(9 downto 0);
        gtime_s         : out std_logic_vector(5 downto 0);
        gtime_m         : out std_logic_vector(5 downto 0);
        gtime_h         : out std_logic_vector(4 downto 0);
        gtime_d         : out std_logic_vector(9 downto 0)
    );
end entity global_time_counter;

architecture rtl of global_time_counter is

    constant NBIT_ms        : positive := 10;
    signal base_1ms_s       : std_logic;
    signal tick_toc_1s      : std_logic_vector(NBIT_ms-1 downto 0);

    constant NBIT_s         : positive := 6;
    signal tick_toc_1m      : std_logic_vector(NBIT_s-1 downto 0);

    constant NBIT_m         : positive := 6;
    signal tick_toc_1h      : std_logic_vector(NBIT_m-1 downto 0);

    constant NBIT_h         : positive := 5;
    signal tick_toc_1d      : std_logic_vector(NBIT_h-1 downto 0);

    constant NBIT_d         : positive := 10;
    signal tick_toc_days    : std_logic_vector(NBIT_d-1 downto 0);

    --
    signal tick_1s_s        : std_logic;
    signal tick_1m_s        : std_logic;
    signal tick_1h_s        : std_logic;
    signal tick_1d_s        : std_logic;

begin

    -- clk to ms
    i_base_1ms: entity lplib_gp.basetime_ms(rtl)
        generic map (
            RST_POL         => RST_POL,
            CLK_FREQ        => CLK_FREQ, -- Hz
            BASE_PERIOD     => 1 -- ms
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            dbg_x10         => dbg_fast_ms_x10,
            base_out        => base_1ms_s
        );

    base_1ms    <= base_1ms_s;


    -- ms to s
    i_gtime_ms: entity lplib_gp.ticker(rtl)
        generic map (
            RST_POL         => RST_POL,
            NBIT            => NBIT_ms,
            OUT_BUF         => 0 -- combinational forward tick_out
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            tick_in         => base_1ms_s,
            tick_out        => tick_1s_s,
            tick_toc        => tick_toc_1s,
            tick_cnt        => gtime_ms
        );

    tick_1s     <= tick_1s_s;
    -- 1000 ms (or 20 ms if dbg_fast_s_x50)
    tick_toc_1s <= std_logic_vector(TO_UNSIGNED(1000-1,NBIT_ms)) when dbg_fast_s_x50='0' else
                    std_logic_vector(TO_UNSIGNED(20-1,NBIT_ms));


    -- s to m
    i_gtime_s: entity lplib_gp.ticker(rtl)
        generic map (
            RST_POL         => RST_POL,
            NBIT            => NBIT_s,
            OUT_BUF         => 0 -- combinational forward tick_out
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            tick_in         => tick_1s_s,
            tick_out        => tick_1m_s,
            tick_toc        => tick_toc_1m,
            tick_cnt        => gtime_s
        );

    tick_1m     <= tick_1m_s;
    -- 60 s
    tick_toc_1m <= std_logic_vector(TO_UNSIGNED(60-1,NBIT_s));


    -- m to h
    i_gtime_m: entity lplib_gp.ticker(rtl)
        generic map (
            RST_POL         => RST_POL,
            NBIT            => NBIT_m,
            OUT_BUF         => 0 -- combinational forward tick_out
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            tick_in         => tick_1m_s,
            tick_out        => tick_1h_s,
            tick_toc        => tick_toc_1h,
            tick_cnt        => gtime_m
        );

    tick_1h     <= tick_1h_s;
    -- 60 m
    tick_toc_1h <= std_logic_vector(TO_UNSIGNED(60-1,NBIT_m));
  

    -- h to d
    i_gtime_h: entity lplib_gp.ticker(rtl)
        generic map (
            RST_POL         => RST_POL,
            NBIT            => NBIT_h,
            OUT_BUF         => 0 -- combinational forward tick_out
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            tick_in         => tick_1h_s,
            tick_out        => tick_1d_s,
            tick_toc        => tick_toc_1d,
            tick_cnt        => gtime_h
        );

    tick_1d     <= tick_1d_s;
    -- 24 h
    tick_toc_1d <= std_logic_vector(TO_UNSIGNED(24-1,NBIT_h));
 
 
    -- d to NULL (wrap-around days)
    i_gtime_d: entity lplib_gp.ticker(rtl)
        generic map (
            RST_POL         => RST_POL,
            NBIT            => NBIT_d,
            OUT_BUF         => 0 -- combinational forward tick_out
        )
        port map (
            clk             => clk,
            rst             => rst,
            en              => en,
            tick_in         => tick_1d_s,
            tick_out        => open,
            tick_toc        => tick_toc_days,
            tick_cnt        => gtime_d
        );

    -- full range NBIT_d-counter
    tick_toc_days <= std_logic_vector(TO_UNSIGNED(2**NBIT_d-1,NBIT_d));



end rtl;
