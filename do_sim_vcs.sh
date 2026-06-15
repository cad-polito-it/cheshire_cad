#!/usr/bin/env bash
make chs-sim-all

# modify for your needs 
export BINARY="../../../sw/tests/helloworld.dram.memh"
export BOOTMODE=0
export PRELMODE=3
export USE_DRAMSYS=0
export SELCFG=0

cd $CHS_ROOT/target/sim/vcs;

# polito_cad folder #
#cd $CHS_ROOT/target/fsim/vc_zoix;

source compile.cheshire_soc.sh;
source start.cheshire_soc.sh;