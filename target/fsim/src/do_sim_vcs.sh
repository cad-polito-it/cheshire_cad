#!/usr/bin/env bash

make chs-sim-all

# modify for your needs
#export BINARY="../../../sw/tests/helloworld.dram.memh"
export BINARY="../../../sw/tests/custom_alu.dram.memh"

export BOOTMODE=0
export PRELMODE=3
export USE_DRAMSYS=0
export SELCFG=0

MODE=$1

if [[ -z "${MODE}" ]]; then
    echo "Usage:"
    echo "  $0 vcs-cli"
    echo "  $0 vcs-gui"
    echo "  $0 vcs-fsim"
    exit 1
fi



cd $CHS_ROOT/target/fsim/vc_zoix

if [ ! -f simv ]; then
    source $CHS_ROOT/target/fsim/src/compile.cheshire_soc.sh
else
    echo "SIMV EXISTS ===> SKIP COMPILE"
fi

export SIM_MODE=${MODE}

source $CHS_ROOT/target/fsim/src/start.cheshire_soc.sh