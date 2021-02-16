-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_input_filter.vhd
-- Language      : VHDL-93
-- Module        : tb
-- Library       : lplib_gp_verif
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


-- STD lib
-- ----------------------------------------
use std.textio.all;

-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;

-- User lib
-- ----------------------------------------
library lplib_gp;


entity tb is
end entity tb;


architecture beh of tb is

    -- TB common parameters and signals
    -- ----------------------------------------
    constant RST_POL    : std_logic := '0';
    -- constant CLK_FREQ   : positive := 50000000; -- 50 MHz (20 ns)
    -- constant CLK_FREQ   : positive := 33000000; -- 33 MHz (30.303 ns)
    -- constant CLK_FREQ   : positive := 25000000; -- 25 MHz (40 ns)
    -- constant CLK_FREQ   : positive := 20000000; -- 20 MHz (50 ns)
    constant CLK_FREQ   : positive := 10000000; -- 10 MHz (100 ns)
    --
    constant TCLK       : time := 1.0e10/real(CLK_FREQ) * (0.1 ns); -- clock period
    constant DUTYCLK    : real := 0.5; -- clock duty-cycle

    signal en_clk       : std_logic;
    --
    signal clk          : std_logic := '0';
    signal rst          : std_logic := RST_POL;
    --
    signal tcase        : integer := 0;


    -- Check Process
    -- ----------------------------------------
    signal err_counter          : integer   := 0;
    signal check_err_counter    : integer   := 0;


    -- Signals
    -- ----------------------------------------
    signal en           : std_logic;
    signal synch_in     : std_logic;
    signal synch_out    : std_logic;
    --
    signal x1           : std_logic;
    signal y1           : std_logic;
    signal yp1          : std_logic;
    --
    signal x2           : std_logic;
    signal y2           : std_logic;
    signal yp2          : std_logic;

begin

    -- clock generator 50%
    -- ----------------------------------------
    clk <= not clk after TCLK/2 when en_clk='1' else '0';
    
    
    -- clock generator DUTYCLK% 
    -- ----------------------------------------
    -- proc_clk: process(clk, en_clk)
    -- begin
    --     if en_clk='1' then
    --         if clk='0' then
    --             clk <= '1' after TCLK*(1.0-DUTYCLK);
    --         else
    --             clk <= '0' after TCLK*DUTYCLK;
    --         end if;
    --     else
    --         clk <= '0'
    --     end if;
    -- end process proc_clk;



    i_uut_synch: entity lplib_gp.synch(rtl)
        generic map (
            RST_POL         => '0',
            RST_VAL         => '0',
            N               => 2
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            en              => en           ,
            synch_in        => synch_in     ,
            synch_out       => synch_out    ,
            synch_out_chain => open
        );

    i_uut_pulse1: entity lplib_gp.pulse_filter(rtl)
        generic map (
            RST_POL         => '0',
            RST_VAL         => '0',
            N               =>  4 , -- 2^4 +1 = 16clk +1 = 1.7us
            MODE            =>  1
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            x               => x1           ,
            y               => y1           ,
            yp              => yp1
        );

    x1 <= synch_out;

    i_uut_pulse2: entity lplib_gp.pulse_filter(rtl)
        generic map (
            RST_POL         => '0',
            RST_VAL         => '0',
            N               =>  4 ,
            MODE            =>  2
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            x               => x2           ,
            y               => y2           ,
            yp              => yp2
        );

    x2 <= synch_out;


    i_uut_debouce: entity lplib_gp.debounce_filter(rtl)
        generic map (
            RST_POL         => '0',
            RST_VAL         => '0',
            N               =>  4
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            x               => synch_out    ,
            y               => open
        );


    -- Drive Process
    -- ----------------------------------------   
    proc_drive: process
    begin
        -- ========
        tcase       <= 0;
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        --
        en          <= '0';
        synch_in    <= '0';
        --
        --
        wait for 123 ns;
        en_clk     <= '1';
        wait for 123 ns;
        wait until falling_edge(clk);
        -- reset release
        rst        <= not RST_POL;
        wait for 123 ns;
        wait until rising_edge(clk);
        --
        --
        -- ========
        tcase           <= 1;
        wait until rising_edge(clk);
        --
        en          <= '1';
        wait until rising_edge(clk);
        --
        wait until rising_edge(clk);
        synch_in    <= '1';
        wait for 2 us;
        wait until rising_edge(clk);
        synch_in    <= '0';
        wait for 4 us;
        --
        wait until rising_edge(clk);
        synch_in    <= '1';
        wait for 1 us;
        wait until rising_edge(clk);
        synch_in    <= '0';
        wait for 4 us;
        --
        -- ======== noisy
        tcase           <= 2;
        wait until rising_edge(clk);
        --
        wait until rising_edge(clk);
        for i in 0 to 20 loop
            synch_in    <= '1';
            wait for i*123 ns;
            synch_in    <= '0';
            wait for 555 ns;
        end loop;
        wait for 4 us;
        --
        --
        -- ======== Power Off
        tcase   <= -1;
        wait until rising_edge(clk);
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        rst        <= '0';
        wait for 333 ns;
        en_clk     <= '0';
        wait for 333 ns;
        --
        -- err_counter <= err_counter + check_err_counter;
        -- wait for 333 ns;
        -- --
        -- if err_counter /= 0 then
        --     REPORT "... ==|[ TEST FAILED ]|== ...";
        -- else
        --     REPORT "... ==|[ TEST SUCCESS ]|== ...";
        -- end if;
        -- REPORT "... ==|[ err_counter: " & integer'image(err_counter) & " ]|== ...";
        -- REPORT "... ==|[ proc_drive: SIMULATION END ]|== ...";
        --
        ASSERT FALSE
            REPORT "... ==|[ proc_drive: SIMULATION END ]|== ..."
                SEVERITY FAILURE;
        --
        wait;
    end process proc_drive;


end beh;
