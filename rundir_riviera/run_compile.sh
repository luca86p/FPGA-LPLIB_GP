#!/usr/bin/env bash
# =============================================================================
# Whatis        : Task Sequencer for Aldec Riviera-PRO, HDL simulator
# Project       : 
# -----------------------------------------------------------------------------
# File          : run_compile.sh
# Language      : bash
# Module        : 
# Library       : 
# -----------------------------------------------------------------------------
# Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
#                 
# Company       : 
# Addr          : 
# -----------------------------------------------------------------------------
# Description
# 
#   Clean and compile all the design files.
# 
# -----------------------------------------------------------------------------
# Dependencies
# 
#   ./run_riviera.sh
# 
# -----------------------------------------------------------------------------
# Issues
# 
# -----------------------------------------------------------------------------
# Copyright (c) 2021 Luca Pilato
# MIT License
# -----------------------------------------------------------------------------
# date        who               changes
# 2019-05-28  Luca Pilato       file creation
# =============================================================================

# CLEAN
./run_riviera.sh clean

# COMPILE SUBMODULES
# grep -v '#' ../FPGA-LPLIB_UTIL/list/lib.lplib_util.lst | sed -e "s/^\.\./\.\.\/FPGA-LPLIB_UTIL/" > ../list/lib.lplib_util.lst
# ./run_riviera.sh compile liblist lplib_util
# rm ../list/lib.lplib_util.lst

# COMPILE
./run_riviera.sh compile liblist lplib_gp

# COMPILE FOR VERIFICATION
./run_riviera.sh compile liblist lplib_gp_verif -2008
