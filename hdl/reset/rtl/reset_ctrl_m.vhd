-- =============================================================================
-- Whatis        : reset controller: krst -> mrst
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : reset_ctrl_m.vhd
-- Language      : VHDL-93
-- Module        : reset_ctrl_m
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  Asynch Reset Assertion / Synch Reset Deassertion.
--
--  * krst (king reset)     : 3 clk deassert latency            from rst
--  * mrst (master reset)   : MRST_TIME clk deassert latency    from krst 
--      * SIM_REDUCTION used for simulation -> act as MRST_TIME = 255
-- 
--  Features:
--  * mrst has 4x requests inputs.
--  * mrst_log register holds the last reset reqest. (krst domain)
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


entity reset_ctrl_m is
    generic (
        RST_POL         : std_logic := '0';
        MRST_POL        : std_logic := '0';
        MRST_TIME       : positive  := 100000; -- 100_000 clk cycles (after krst)
        SIM_REDUCTION   : boolean   := false   -- time-stretch reduction (255) for simulation
    );
    port (
        rst             : in  std_logic; -- external asynch
        clk             : in  std_logic;
        krst            : out std_logic; -- king: glitch free
        --
        mrst            : out std_logic; -- master: usually the sys reset
        --
        mrst_req        : in  std_logic_vector(3 downto 0); -- 4 lines of req        
        mrst_log        : out std_logic_vector(3 downto 0); -- log rst cause
        clr_log         : in  std_logic
    );
end entity reset_ctrl_m;


architecture rtl of reset_ctrl_m is

    -- king reset (glitch free)
    signal rst_d1   : std_logic;
    signal rst_d2   : std_logic;
    signal rst_d3   : std_logic;
    signal krst_s   : std_logic;

    -- timing selection
    function fun_mrst_time (SIM_REDUCTION : in boolean)
        return positive is
    begin
        if SIM_REDUCTION then
            return 255;
        else
            return MRST_TIME;
        end if;
    end function fun_mrst_time;

    -- time-stretch MRST
    constant MRST_TMR_i : positive := fun_mrst_time(SIM_REDUCTION);
    constant MRST_TMR_b : positive := integer(CEIL(LOG2(real(MRST_TMR_i))));
    constant MRST_TMR_u : unsigned(MRST_TMR_b-1 downto 0) := TO_UNSIGNED(MRST_TMR_i, MRST_TMR_b);
    signal mrst_timer   : unsigned(MRST_TMR_b-1 downto 0);
    signal mrst_s       : std_logic;

    -- reset log register
    signal mrst_log_s   : std_logic_vector(3 downto 0);

begin

    -- king reset (glitch free)
    -- ----------------------------------------------------------------
    proc_rst_synch: process(clk, rst)
    begin
        if rst=RST_POL then
            rst_d1 <= RST_POL;
            rst_d2 <= RST_POL;
            rst_d3 <= RST_POL;
        elsif rising_edge(clk) then
            rst_d1 <= not RST_POL;
            rst_d2 <= rst_d1;
            rst_d3 <= rst_d2;
        end if;
    end process proc_rst_synch;

    krst_s  <= rst_d3;
    krst    <= krst_s;


    -- reset log register
    -- ----------------------------------------------------------------
    proc_mrst_log: process(clk, krst_s)
    begin
        if krst_s=RST_POL then
            mrst_log_s  <= (others=>'0');
        elsif rising_edge(clk) then
            if clr_log='1' then
                mrst_log_s  <= (others=>'0');
            else
                -- self-latch
                mrst_log_s  <= mrst_log_s or mrst_req;
            end if;
        end if;
    end process proc_mrst_log;

    mrst_log <= mrst_log_s;



    -- master reset (with req and stretch)
    -- ----------------------------------------------------------------
    proc_mrst: process(clk, krst_s)
    begin
        if krst_s=RST_POL then
            mrst_timer  <= MRST_TMR_u;
            mrst_s      <= MRST_POL;
        elsif rising_edge(clk) then
            if mrst_s/=MRST_POL then
                if (mrst_req/="0000") then
                    mrst_timer  <= MRST_TMR_u;
                    mrst_s      <= MRST_POL;
                end if;
            else
                if mrst_timer=0 then
                    mrst_s      <= not MRST_POL;
                else
                    mrst_timer  <= mrst_timer-1;
                    mrst_s      <= MRST_POL; -- redundant, hold mrst active
                end if;
            end if;
        end if;
    end process proc_mrst;

    mrst    <= mrst_s;


end rtl;
