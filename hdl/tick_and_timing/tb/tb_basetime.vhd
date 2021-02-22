-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_basetime.vhd
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
-- 2020-02-20  Luca Pilato       file creation
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


    -- Signals
    -- ----------------------------------------
    signal en           : std_logic;
    signal dbg_x10      : std_logic;
    signal base12us     : std_logic;
    signal base1ms      : std_logic;


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



    -- Unit(s) Under Test
    -- ----------------------------------------
    i_basetime_us: entity lplib_gp.basetime_us(rtl)
        generic map (
            RST_POL         => '0'          ,
            CLK_FREQ        => CLK_FREQ     ,
            BASE_PERIOD     => 12 -- us
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            en              => en           ,
            dbg_x10         => dbg_x10      ,
            base_out        => base12us
        );

    i_basetime_ms: entity lplib_gp.basetime_ms(rtl)
        generic map (
            RST_POL         => '0'          ,
            CLK_FREQ        => CLK_FREQ     ,
            BASE_PERIOD     => 1 -- ms
        )
        port map (
            clk             => clk          ,
            rst             => rst          ,
            en              => en           ,
            dbg_x10         => dbg_x10      ,
            base_out        => base1ms
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
        dbg_x10     <= '0';
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
        wait for 50 us;
        wait until rising_edge(clk);
        --
        en          <= '0';
        wait for 5 us;
        wait until rising_edge(clk);
        --
        en          <= '1';
        wait for 10 us;
        wait until rising_edge(clk);
        --
        -- ========
        tcase           <= 2;
        wait until rising_edge(clk);
        --
        wait for 1 ms;
        wait until rising_edge(clk);
        --
        -- ======== speed up
        tcase           <= 3;
        wait until rising_edge(clk);
        --
        en          <= '0';
        wait for 5 us;
        wait until rising_edge(clk);
        --
        en          <= '1';
        dbg_x10     <= '1';
        wait for 120 us;
        wait until rising_edge(clk);
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
