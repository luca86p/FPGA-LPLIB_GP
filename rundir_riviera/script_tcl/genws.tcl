# =============================================================================
# Whatis        : Tcl script for Aldec Riviera-PRO, HDL simulator
# Project       : 
# -----------------------------------------------------------------------------
# File          : genws.tcl
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
#   Workspace generation and setup.
#   One design foreach library.
#   
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


# procedure to add files to the current design
# -------------------------------------------
proc add_liblist {lib} {
    set file_lst    "../../list/lib.${lib}.lst"
    set fp          [open ${file_lst} r]
    set file_data   [read ${fp}]
    close ${fp}
    foreach line [split ${file_data} "\n"] {
        if {[regexp "^ *#" ${line}] || [regexp "^ *$" ${line}]} {
            # commented or empty line
    
        } else {

            # leading or trailing white space are removed. (spaces, tabs, newlines, and carriage returns)
            # -------------------------------------------
            set this_file [string trim "../${line}"]

            # file exists check
            # -------------------------------------------
            if ![file exists ${this_file}] {
                puts "... WARNING: missing file ${this_file}"
                continue
            }

            # add to workspace design
            # -------------------------------------------
            puts "... add ${this_file}"
            design.file.add ${this_file}

        }
}
}


# Generate the unique Workspace name
# ------------------------------------------------------------------------------
set TAG [clock format [clock seconds] -format %Y%m%d_%H%M%S]

set WSNAME  [lindex $argv 0]

workspace.create ws_${WSNAME}_${TAG} .


# ------------------------------------------------------------------------------
set DESIGN  basic
set LIB     lplib_$DESIGN
workspace.design.create $DESIGN . -library $LIB
workspace.design.setactive $DESIGN
#
amap $LIB $DESIGN/$LIB/$LIB.lib
#
add_liblist $LIB
#
design.compile $DESIGN

# ------------------------------------------------------------------------------
set DESIGN  basic_verif
set LIB     lplib_$DESIGN
workspace.design.create $DESIGN . -library $LIB
workspace.design.setactive $DESIGN
# 
amap $LIB $DESIGN/$LIB/$LIB.lib
#
add_liblist $LIB
#
# Dependencies: for workspace/design compile
workspace.dependencies.add $DESIGN basic
# Map the "outside" design libraries
amap lplib_basic basic/lplib_basic/lplib_basic.lib
#
design.compile $DESIGN


# ------------------------------------------------------------------------------
# workspace.dependencies.graph.show

# design.simulation.initialize tb
# log -recursive sim:/*
# wave -recursive sim:/tb/*
# run -all

# 1. Prepare a library (alib)
# 2. Compile (acom)
# 3. Initialize (asim)
# 4. Simulate (run)
