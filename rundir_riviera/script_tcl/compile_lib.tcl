# =============================================================================
# Whatis        : Tcl script for Aldec Riviera-PRO, HDL simulator
# Project       : 
# -----------------------------------------------------------------------------
# File          : compile_lib.tcl
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
#   Compile loop over "../list/lib.${lib}.lst" file of file path into ${lib}.
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
# 2021-02-03  Luca Pilato       file creation
# =============================================================================

#  Slurp up the data file
# -------------------------------------------
set baselib     [lindex $argv 0]
set lib         [lindex $argv 1]
set vhdlver     [lindex $argv 2]

set file_lst    "../list/lib.${lib}.lst"
set fp          [open ${file_lst} r]

set file_data   [read ${fp}]
close ${fp}

#  Create and map the library
# -------------------------------------------
set this_map "${baselib}/${lib}"
if ![file exists ${this_map}] {
    alib ${this_map}
    amap ${lib} ${this_map}
}

# removes all units in library
# -------------------------------------------
# adel -lib ${lib} -all

# detach lib
# -------------------------------------------
# amap -del ${lib}

# Process data file per lines
# -------------------------------------------
foreach line [split ${file_data} "\n"] {
    if {[regexp "^ *#" ${line}] || [regexp "^ *$" ${line}]} {
        # commented or empty line
  
    } else {
    
        # leading or trailing white space are removed. (spaces, tabs, newlines, and carriage returns)
        # -------------------------------------------
        set this_file [string trim ${line}]

        # little trick for path, old version with lib explicited in the file
        # -------------------------------------------
        # if {[regexp "lib:" ${line}]} {
        #   # create and map lib
        # }

        # file exists check
        # -------------------------------------------
        if ![file exists ${this_file}] {
            puts "... WARNING: missing file ${this_file}"
            continue
        }

        # compile
        # -------------------------------------------
        puts "... compiling ${this_file}"
        acom -dbg ${vhdlver} -work ${lib} ${this_file}
        # -O0 | -O1 | -O2 | -O3
        # -o | -reorder
        # -relax
    }
}

# Old, one liner command
# ------------------------------------------- 
# acom -dbg -reorder ${vhdlver} -work ${lib} "[cat ${file_lst} | grep -v '#']"


# Show library names and paths
# -------------------------------------------
puts ""
puts "... Lists library mappings"
alist

# Show library content, verbose
# -------------------------------------------
puts ""
puts "... Lists library mappings"
adir -witharch -lib ${lib} -l
