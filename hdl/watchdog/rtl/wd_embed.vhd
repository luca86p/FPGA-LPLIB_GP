-- =============================================================================
-- Whatis        : embedded watchdog
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : wd_embed.vhd
-- Language      : VHDL-93
-- Module        : wd_embed
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
-- 2019-02-28  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity wd_embed is
    generic (
        RST_POL         : std_logic := '0';
        CLK_FREQ        : positive  := 20000000; -- Hz
        WD_TIME         : positive  := 10;       -- ms
        WD_POL          : std_logic := '0'
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        wd_kick         : in  std_logic;
        wd_pulse        : out std_logic
    );
end wd_embed;

architecture rtl of wd_embed is

    -- setup down-counter for the wd period
    constant TIMEOUT        : integer := integer(real(CLK_FREQ)*real(WD_TIME)/1.0e3);
    constant TOP_OF_CNT     : integer := TIMEOUT-1;
    -- use downcount and pulse on code 1
    constant NBIT           : integer := integer(ceil(log2(real(TIMEOUT)))); 
    signal clock_cnt        : unsigned(NBIT-1 downto 0);

     -- internal base out
    signal wd_pulse_s       : std_logic;

begin

    -- counter and tick for the basetime
    -- ----------------------------------------------------------------
    proc_wd: process(clk,rst)
    begin
        if rst=RST_POL then
            clock_cnt       <= (others=>'0');
            wd_pulse_s      <= not WD_POL;
        elsif rising_edge(clk) then
            --
            wd_pulse_s      <= not WD_POL; -- default
            --
            if en='1' then
                --
                if wd_kick='1' then
                    clock_cnt       <= TO_UNSIGNED(TOP_OF_CNT, NBIT);   
                elsif clock_cnt/=0 then
                    clock_cnt       <= clock_cnt-1;
                end if;
                --
                if clock_cnt=1 then
                    wd_pulse_s      <= WD_POL;
                end if;
                --
            else
                clock_cnt       <= (others=>'0');
            end if; -- en
        end if; -- clk
    end process proc_wd;

    wd_pulse    <= wd_pulse_s;


end rtl;
