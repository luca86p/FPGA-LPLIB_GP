-- =============================================================================
-- Whatis        : register file
-- Project       : FPGA-LPLIB_GP
-- -----------------------------------------------------------------------------
-- File          : reg_file_1w1r_mask.vhd
-- Language      : VHDL-93
-- Module        : reg_file_1w1r_mask
-- Library       : lplib_gp
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
-- 
--  1x write port (with logical mask)
--  1x read port
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
-- 2019-05-07  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity reg_file_1w1r_mask is
    generic (
        RST_POL         : std_logic := '0' ;
        DATA_WIDTH      : positive  := 8   ;
        ADDR_WIDTH      : positive  := 4
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clr             : in  std_logic;
        --
        wr_addr         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        wr_en           : in  std_logic;
        wr_data         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        wr_mask         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        --
        rd_addr         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        rd_data         : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity reg_file_1w1r_mask;


architecture rtl of reg_file_1w1r_mask is

    constant REG_LINES : integer := 2**ADDR_WIDTH;

    subtype t_data is std_logic_vector(DATA_WIDTH-1 downto 0);
    type t_reg_matrix is array (0 to REG_LINES-1) of t_data;
    signal reg_matrix   : t_reg_matrix;

    signal wr_addr_i    : integer range 0 to REG_LINES-1;
    signal rd_addr_i    : integer range 0 to REG_LINES-1;

begin

    wr_addr_i   <= TO_INTEGER(unsigned(wr_addr));

    proc_reg_matrix: process(clk,rst)
    begin
        if rst=RST_POL then
            reg_matrix <= (others=>(others=>'0'));
        elsif rising_edge(clk) then
            if clr='1' then
                reg_matrix <= (others=>(others=>'0'));
            elsif wr_en='1' then
                for i in 0 to DATA_WIDTH-1 loop
                    if wr_mask(i)='1' then
                        reg_matrix(wr_addr_i)(i) <= wr_data(i);
                    end if;
                end loop;
            end if;
        end if;
    end process proc_reg_matrix;

    rd_addr_i   <= TO_INTEGER(unsigned(rd_addr));
    rd_data     <= reg_matrix(rd_addr_i);

end rtl;
