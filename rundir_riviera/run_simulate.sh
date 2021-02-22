#!/usr/bin/bash
# =============================================================================
# Whatis        : Launcher for Aldec Riviera-PRO, HDL simulator
# Project       :
# -----------------------------------------------------------------------------
# File          : run_simulate.sh
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
#   See the printmenu function
#   
# -----------------------------------------------------------------------------
# Dependencies
#
#   source ../script_bash/have_fun.sh
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


# utility functions
# --------------------------------
source ../script_bash/have_fun.sh

echo 
printline '#'
echo "##    TIMESTAMP START: $(date)"
printline '#'

# SIMULATE
# --------------------------------
funtic
#
if [[ $1 == "gui" ]]; then
    ./run_riviera.sh simulate lplib_gp_verif gui
else
    ./run_riviera.sh simulate lplib_gp_verif nogui
fi
#
echo "Simulation time $(($(funtoc)/1000)) s"


# VERIFICATION and DIFFs
# --------------------------------
errlog

echo
printline '#'
echo "##    TIMESTAMP END: $(date)"
printline '#'
 