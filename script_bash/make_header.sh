#!/usr/bin/bash
# =============================================================================
# Whatis        : bash script to print a source file header
# Project       : 
# -----------------------------------------------------------------------------
# File          : make_header.sh
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
# 2021-02-02  Luca Pilato       file creation
# =============================================================================

function printmenu {
    cat << ENDOFART

... Usage:

    ./make_header.sh <file> [comment]

ENDOFART
    return
}

# arg(s) check?
# --------------------------------
echo
[[ -z $@ ]] && echo "... ERROR: missing arg(s)" && printmenu && exit

# file check
# --------------------------------
FPATH=$1
[[ ! -f $FPATH ]] && echo "... ERROR: $FPATH not found!" && exit
FNAME=$(basename $FPATH)

# Comment character(s)
# --------------------------------
if [[ -z $2 ]]; then
    CCHAR='--'
else
    CCHAR=$2
fi

BOLDLINE='============================================================================='
LIGHTLINE='-----------------------------------------------------------------------------'
DATE_YEAR=$(date +%Y)
DATE_MONTH=$(date +%m)
DATE_DAY=$(date +%d)

echo "$CCHAR $BOLDLINE"
echo "$CCHAR Whatis        : "
echo "$CCHAR Project       : "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR File          : $FNAME"
echo "$CCHAR Language      : "
echo "$CCHAR Module        : "
echo "$CCHAR Library       : "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>"
echo "$CCHAR                 "
echo "$CCHAR Company       : "
echo "$CCHAR Addr          : "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR Description"
echo "$CCHAR "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR Dependencies"
echo "$CCHAR "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR Issues"
echo "$CCHAR "
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR Copyright (c) $DATE_YEAR Luca Pilato"
echo "$CCHAR MIT License"
echo "$CCHAR $LIGHTLINE"
echo "$CCHAR date        who               changes"
echo "$CCHAR $DATE_YEAR-$DATE_MONTH-$DATE_DAY  Luca Pilato       file creation"
echo "$CCHAR $BOLDLINE"
