#!/usr/bin/bash
# =============================================================================
# Whatis        : collection of bash functions
# Project       : 
# -----------------------------------------------------------------------------
# File          : have_fun.sh
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
#       printline
#       here
#       printlogo
#       printinfo
#       gettag
#       testanddel
#       errlog
#       findtab
#       funtic
#       funtoc
# 
#  To use the functions, first load the script with:
#       source ../script_bash/have_fun.sh
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
# 2019-05-10  Luca Pilato       file creation
# =============================================================================



function printline {
    local C
    if [[ -z $1 ]]; then
        C='-'
    else
        C=$1
    fi
    printf "%80s" | tr ' ' $C
    printf '\n'
    return
}



function here {
    local HEREPATH
    if [[ $(uname) == CYGWIN* ]]; then
        HEREPATH=$(cygpath -w $(pwd))
    else
        HEREPATH=$(pwd)
    fi;
    echo $HEREPATH
    return
}




# ASCII art
# URL  : patorjk.com/software/taag/
# Font : Stop

function printlogo {
    echo
    echo "# ============================================================================ #"
    echo "#      _       ______                           ______  _     _ ______         #"
    echo "#     | |     (_____ \                         (_____ \| |   | |  ___ \        #"
    echo "#     | |      _____) )       o_    _o          _____) ) |   | | |   | |       #"
    echo "#     | |     |  ____/          \__/           (_____ (| |   | | |   | |       #"
    echo "#     | |_____| |       (\__/)  |@@|  (\__/)         | | |___| | |   | |       #"
    echo "#     |_______)_|         \_\__ \**/ __/_/           |_|\______|_|   |_|       #"
    echo "#                              |----|                                          #"
    echo "# ============================================================================ #"
    echo
    return
}




function printinfo {
    echo
    printline

    echo "... hostname : $(hostname)"
    echo "... uname    : $(uname -srmo)"
    echo "... herepath : $(here)"
    echo "... whoami   : $(whoami)"
    echo "... date     : $(date)"

    printline
    echo
    return
}


# to use with MYTAG=$(gettag)
# --------------------------------
function gettag {
    echo $(date +%Y%m%d_%H%M%S)
    return
}




function testanddel {
    echo
    if [[ $# -eq 0 ]]; then
        echo "... ${FUNCNAME[0]} warning: no argument(s)"
        return
    fi

    for arg in $@; do
        if [[ -d $arg ]]; then
            rm -rf $arg
            echo "... found '$arg' dir and removed"
        elif [[ -f $arg ]]; then
            rm -f $arg
            echo "... found '$arg' file and removed"
        fi
    done
    return
}



function errlog {
    echo
    echo "... ${FUNCNAME[0]}"
    printline

    grep -Hin "warn"    *.log | grep -v "puts" | grep -iv  "0 warn"
    grep -Hin "error"   *.log | grep -v "puts" | grep -iv  "0 error"

    printline
    echo "... ${FUNCNAME[0]} ... done"
    return
}




function findtab {
    local Color_Off='\033[0m'       # Text Reset
    local Red='\033[0;31m'          # Red
    echo
    echo "... ${FUNCNAME[0]}"
    printline
    
    if [[ -z $1 ]]; then
        echo "... ${FUNCNAME[0]} warning: no argument(s)"
        return
    fi

    for fn in `find $1 -type f`; do
        grep -qP '\t' $fn
        if [[ $? -eq 0 ]]; then
            echo -e "... the file $Red $fn $Color_Off have TAB(s)"
        fi
    done

    printline
    echo "... ${FUNCNAME[0]} ... done"
    return
}




function funtic {
    tic_ms=$(($(date +%s%N)/1000000))
}

function funtoc {
    toc_ms=$(($(date +%s%N)/1000000-$tic_ms))
    echo $toc_ms
}
