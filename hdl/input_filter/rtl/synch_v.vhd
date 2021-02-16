-- =============================================================================
-- Whatis        : N-stages FF vector synchronizer
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : synch_v.vhd
-- Language      : VHDL-93
-- Module        : synch_v
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
--  lplib_gp.synch(rtl)
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


entity synch_v is
    generic (
        RST_POL         : std_logic := '0';
        RST_VAL         : std_logic := '0';
        N_STAGE         : positive  := 2;
        V_WIDTH         : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        en              : in  std_logic_vector(V_WIDTH-1 downto 0);
        synch_in        : in  std_logic_vector(V_WIDTH-1 downto 0);
        synch_out       : out std_logic_vector(V_WIDTH-1 downto 0)
    );
end synch_v;


architecture rtl of synch_v is

begin

    gen_synch_v: for i in 0 to V_WIDTH-1 generate
        i_synch: entity lplib_gp.synch(rtl)
            generic map (
                RST_POL         => RST_POL  ,
                RST_VAL         => RST_VAL  ,
                N               => N_STAGE
            )
            port map (
                clk             => clk          ,
                rst             => rst          ,
                en              => en(i)        ,
                synch_in        => synch_in(i)  ,
                synch_out       => synch_out(i) ,
                synch_out_chain => open
            );
    end generate gen_synch_v;

end rtl;
