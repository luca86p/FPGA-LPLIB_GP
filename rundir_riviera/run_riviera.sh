#!/usr/bin/bash
# =============================================================================
# Whatis        : Launcher for Aldec Riviera-PRO, HDL simulator
# Project       :
# -----------------------------------------------------------------------------
# File          : run_riviera.sh
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
#   source ../script_bash/rmclean_fun.sh
#   ./script_tcl/compile_lib.tcl
#   ./script_tcl/genws.tcl
#   ./script_tcl/simulate_lib.tcl
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

function printmenu {
  cat << ENDOFART

... Usage:

    ./run_riviera.sh clean
    ./run_riviera.sh compile liblist <lib>            [-93|-2002|-2008]
    ./run_riviera.sh compile source  <file> [lib]     [-93|-2002|-2008]
    ./run_riviera.sh libinfo         <lib>  [verbose]
    ./run_riviera.sh genws           <wsname>
    ./run_riviera.sh simulate        <lib>  [no]gui

ENDOFART
  return
}


# utility functions
# --------------------------------
source ../script_bash/have_fun.sh
source ../script_bash/rmclean_fun.sh


# Print Presentation
# --------------------------------
printlogo
printinfo


# arg(s) check?
# --------------------------------
echo
[[ -z $@ ]] && echo "... ERROR: missing arg(s)" && printmenu && exit


# global parameters
BASELIB='lib'
# every compiled library is in $BASELIB dir, create it if not exsists
[[ -d $BASELIB ]] || mkdir $BASELIB


# Main options
# --------------------------------
if [[ $1 == "clean" ]]; then

    echo
    echo "... $@"
    printline

    # clean all
    rmclean

elif [[ $1 == "compile" ]]; then

    echo
    echo "... $@"
    printline

    # arg(s) check?
    [[ -z $2 ]] && echo "... ERROR: missing arg(s)" && printmenu && exit

    if [[ $2 == "liblist" ]]; then
        
        # compile what library?
        LIB=$3
        LIBLIST_PATH="../list/lib.$LIB.lst"
        [[ ! -f $LIBLIST_PATH ]] && echo "... ERROR: $LIBLIST_PATH not found!" && exit

        # if the lib path exists: delete
        [[ -d $BASELIB/$LIB ]] && rm -rf $BASELIB/$LIB

        if [[ -z $4 ]]; then
            VHDLVER="-93"
        else
            VHDLVER=$4
        fi

        # set the compiler commands
        LOG_OPT="compile.$LIB.log"
        DO_OPT="./script_tcl/compile_lib.tcl"

        # run Riviera with tcl/do script for lib.$LIB.lst parsing
        # -------------------------------------------------------
        echo
        echo "... calling vsimsa to slurp lib.$LIB.lst file and compile"
        printline
        echo "exit" | vsimsa -l $LOG_OPT -do $DO_OPT $BASELIB $LIB $VHDLVER
    
    elif [[ $2 == "source" ]]; then
        
        # compile what file?
        FILE_PATH=$3
        [[ ! -f $FILE_PATH ]] && echo "... ERROR: $FILE_PATH not found!" && exit

        FILE_NAME=$(basename $FILE_PATH)

        # compile what library?
        # use lplib as default library
        LIB=$4
        [[ -z $LIB ]] && LIB="lplib"
        
        # create lib path if not exists 
        [[ -d $BASELIB/$LIB ]] || mkdir $BASELIB/$LIB

        # alib/amap
        vsimsa -do "alib $BASELIB/$LIB; exit"
        vsimsa -do "amap $LIB $BASELIB/$LIB; exit"

        if [[ -z $5 ]]; then
            VHDLVER="-93"
        else
            VHDLVER=$5
        fi

        # set the compiler commands
        LOG_OPT="compile.$FILE_NAME.log"
        DO_OPT="acom -dbg $VHDLVER -work $LIB $FILE_PATH"

        # run Riviera with do command
        # -------------------------------------------------------
        echo
        echo "... calling vsimsa to compile $FILE_PATH"
        printline
        # this is a trick ...
        echo "exit" | vsimsa -l $LOG_OPT -do $DO_OPT
    
    fi

    # check into *.log
    errlog

elif [[ $1 == "libinfo" ]]; then

    echo
    echo "... $@"
    printline

    # arg(s) check?
    [[ -z $2 ]] && echo "... ERROR: missing arg(s)" && printmenu && exit

    # info what library?
    LIB=$2

    # short info
    printline
    echo "exit" | vsimsa -do "adir -witharch -lib $LIB"
    printline

    # long info
    if [[ $3 == "verbose" ]]; then
        printline
        echo "exit" | vsimsa -do "adir -l -lib $LIB"
    fi

elif [[ $1 == "genws" ]]; then

    echo
    echo "... $@"
    printline

    # arg(s) check?
    [[ -z $2 ]] && echo "... ERROR: missing arg(s)" && printmenu && exit

    # set the workspace name
    WSNAME=$2

    # set the script file
    DOFILE="./script_tcl/genws.tcl"

    # set the log commands
    LOG_FILE="ws_${WSNAME}.log"

    # run Riviera with custom tcl/do script for workspace
    # -------------------------------------------------------
    echo
    printline
    echo "exit" | vsimsa -l $LOG_FILE -do $DOFILE $WSNAME

    # check into *.log
    errlog

    # move the log file in its directory
    mv $LOG_FILE $(ls -dr1 ws_${WSNAME}_* | head -1)

elif [[ $1 == "simulate" ]]; then

    echo
    echo "... $@"
    printline

    # arg(s) check?
    [[ -z $2 || -z $3 ]] && echo "... ERROR: missing arg(s)" && printmenu && exit

    # simulate what library?
    TBLIB=$2
    [[ ! -d $BASELIB/$TBLIB ]] && echo "... ERROR: $BASELIB/$TBLIB not found!" && exit

    GUINOGUI=$3

    # set the compiler commands
    LOG_OPT="simulate.$TBLIB.log"
    DO_OPT="./script_tcl/simulate_lib.tcl"

    if [[ $GUINOGUI == "gui" ]]; then
        riviera -l $LOG_OPT -do $DO_OPT $TBLIB
    elif [[ $GUINOGUI == "nogui" ]]; then
        echo "exit" | vsimsa  -l $LOG_OPT -do $DO_OPT $TBLIB
    else
        echo "... ERROR: $GUINOGUI not an option!" && printmenu && exit
    fi

else

    echo "... ERROR: $@ not an option!" && printmenu

fi
