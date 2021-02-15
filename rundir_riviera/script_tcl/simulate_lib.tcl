# =============================================================================
# Whatis        : Tcl script for Aldec Riviera-PRO, HDL simulator
# Project       : 
# -----------------------------------------------------------------------------
# File          : simulate_lib.tcl
# Language      : Tcl
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
#   Simulate the tb entity of the passed worklib.
#   Log all the signals and run all.
# 
# -----------------------------------------------------------------------------
# Dependencies
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

# worklib
# ------------------------------------------------------------------------------
set worklib [lindex $argv 0]

# run Riviera
# ------------------------------------------------------------------------------
asim -ieee_nowarn -advdataflow ${worklib}.tb

# -t ns
# -advdataflow

# -0vitalwiredelay
# -ieee_nowarn
# -access_leak_report


# store all the signals in the simulation database
# ----------------------------------------
log -recursive sim:/*


# run
# ----------------------------------------
run -all



# run + VCD (to save VCD portion)
# ----------------------------------------
# run 100 us
# vcd file dump.vcd
# vcd add -r sim:/tb/i_uut/i_top_level/i_block/*
# vcd add /tb/i_uut/i_top_level/i_block/signal
# vcd on
# run 100 us
# vcd off
# run 100 us
# vcd on
# run 450 us
# vcd off
# run -all
