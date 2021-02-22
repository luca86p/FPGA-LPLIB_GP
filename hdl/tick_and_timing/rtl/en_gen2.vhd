-- =============================================================================
-- Whatis        : programmable enable pulse generator
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : en_gen2.vhd
-- Language      : VHDL-93
-- Module        : en_gen2
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Pulse generator, with prescaler(s).
--      * pulse_out1 period is (div1+2) clock cycles.
--      * pulse_out2 period is (div2+1) pulse_out1 cycles 
--                          = (div1+2)*(div2+1) clock cycles.
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


entity en_gen2 is
    generic (
        RST_POL         : std_logic := '0';
        NBIT            : positive  := 8        
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic;
        div1            : in  std_logic_vector(NBIT-1 downto 0);
        div2            : in  std_logic_vector(NBIT-1 downto 0);
        pulse_out1      : out std_logic;
        pulse_out2      : out std_logic
    );
end en_gen2;

architecture rtl of en_gen2 is

    -- div chain
    signal cnt1             : unsigned(NBIT-1 downto 0);
    signal cnt2             : unsigned(NBIT-1 downto 0);
    signal toc1             : std_logic;
    signal toc2             : std_logic;


begin

    -- div counter
    -- ----------------------------------------------------------------
    proc_div: process(clk, rst)
    begin
        if rst=RST_POL then
            cnt1    <= (others=>'0');
            cnt2    <= (others=>'0');
            toc1    <= '0';
            toc2    <= '0';
        elsif rising_edge(clk) then
            -- default
            toc1    <= '0';
            toc2    <= '0';
            --
            if en='0' then
                --
                cnt1    <= (others=>'0');
                cnt2    <= (others=>'0');
                --
            else
                --
                cnt1    <= cnt1 + 1;
                --
                if cnt1=unsigned(div1) then                    
                    toc1    <= '1';
                    if cnt2=unsigned(div2) then
                        toc2    <= '1';
                    end if;
                end if;
                --
                if toc1='1' then
                    cnt1    <= (others=>'0');
                    cnt2    <= cnt2 + 1;
                    if toc2='1' then
                        cnt2    <= (others=>'0');
                    end if;
                end if;
                --
            end if;
        end if;
    end process proc_div;

    pulse_out1 <= toc1;
    pulse_out2 <= toc2;


end rtl;
