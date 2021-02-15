#!/usr/bin/bash
# =============================================================================
# Whatis        : remove and clean function of the rundir_* dir(s)
# Project       : 
# -----------------------------------------------------------------------------
# File          : rmclean_fun.sh
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
#  Available functions:
#       rmclean
# 
#  To use the functions, first load the script with:
#       source ../script_bash/rmclean_fun.sh
# 
# -----------------------------------------------------------------------------
# Dependencies
#
#   source ../script_bash/have_fun.sh
# 
# -----------------------------------------------------------------------------
# Issues
# 
# -----------------------------------------------------------------------------
# Copyright (c) 2021 Luca Pilato
# MIT License
# -----------------------------------------------------------------------------
# date        who               changes
# 2019-05-10  Luca Pilato       file creation
# =============================================================================


# Dependencies
# --------------------------------
source ../script_bash/have_fun.sh


# Remove and clean all the temp/log/elab files and dirs for:
#   * rundir_riviera
#   * rundir_modelsim
# --------------------------------
function rmclean {
    echo
    echo "... ${FUNCNAME[0]}"
    printline

    testanddel lib compile 
    testanddel library.cfg dataset.asdb dataset.tmp
    testanddel modelsim.ini transcript vsim.wlf xml_interfaces
    testanddel *.log

    printline
    echo "... ${FUNCNAME[0]} ... done"
    return
}
