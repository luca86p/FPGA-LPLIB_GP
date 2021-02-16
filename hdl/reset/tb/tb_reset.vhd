-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_reset.vhd
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
    signal mrst_req     : std_logic_vector(3 downto 0);
    signal srst_req     : std_logic_vector(3 downto 0);
    signal clr_log      : std_logic;


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
    i_reset_filter: entity lplib_gp.reset_filter(rtl)
        generic map (
            RST_POL         => RST_POL
        )
        port map (
            rst             => rst      ,
            clk             => clk      ,
            krst            => open
        );


    i_reset_ctrl_m: entity lplib_gp.reset_ctrl_m(rtl)
        generic map (
            RST_POL         => RST_POL,
            MRST_POL        => RST_POL,
            MRST_TIME       => 100000,
            SIM_REDUCTION   => true
        )
        port map (
            rst             => rst      ,
            clk             => clk      ,
            krst            => open     ,
            mrst            => open     ,
            mrst_req        => mrst_req ,
            mrst_log        => open     ,
            clr_log         => clr_log
        );
 
 
 
    i_reset_ctrl_ms: entity lplib_gp.reset_ctrl_ms(rtl)
        generic map (
            RST_POL         => RST_POL,
            MRST_POL        => RST_POL,
            MRST_TIME       => 100000,
            SRST_POL        => RST_POL,
            SRST_TIME       => 100000,
            SIM_REDUCTION   => true
        )
        port map (
            rst             => rst      ,
            clk             => clk      ,
            krst            => open     ,
            mrst            => open     ,
            srst            => open     ,
            mrst_req        => mrst_req ,
            mrst_log        => open     ,
            srst_req        => srst_req ,
            srst_log        => open     ,
            clr_log         => clr_log
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
        mrst_req    <= (others=>'0');
        srst_req    <= (others=>'0');
        clr_log     <= '0';
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
        wait for 1 ms;
        --
        -- ========
        tcase           <= 2;
        wait until rising_edge(clk);
        --
        srst_req   <= "0010";
        wait until rising_edge(clk);
        srst_req   <= "0000";
        --
        wait for 1 ms;
        --
        -- ========
        tcase           <= 3;
        wait until rising_edge(clk);
        --
        mrst_req   <= "0001";
        wait until rising_edge(clk);
        mrst_req   <= "0000";
        --
        wait for 1 ms;
        --
        -- ========
        tcase           <= 4;
        wait until rising_edge(clk);
        --
        clr_log    <= '1';
        wait until rising_edge(clk);
        clr_log    <= '0';
        wait until rising_edge(clk);
        --
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        --
        mrst_req   <= "0001";
        srst_req   <= "0010";
        wait until rising_edge(clk);
        mrst_req   <= "0000";
        srst_req   <= "0000";
        --
        wait for 1 ms;
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
