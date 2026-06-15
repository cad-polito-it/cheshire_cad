# #!/usr/bin/env bash
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

TESTBENCH=tb_cheshire_soc

# Set full path to c++ compiler.
if [ -z "${CXX_PATH}" ]; then
    if [ -z "${CXX}" ]; then
        CXX="g++"
    fi
    CXX_PATH=`which ${CXX}`
fi

# Set default VCS binary
[[ -z "${VERDI_VERSION}" ]] && VERDI_VERSION=""
[[ -z "${VCS_VERSION}" ]]   && VCS_VERSION=""
[[ -z "${VCS_BIN}" ]]       && VCS_BIN="${VCS_VERSION} vcs"

flags="-full64 -kdb  "
#fsim flags
flags+="+vcs+fsdbon -fsim=portfaults -notice -fsim -fsim=dut:tb_cheshire_soc "
# Set default to fast simulation flags.
if [ -z "${VCSARGS}" ]; then
    # Use -debug_access+all for waveform debugging
    flags+="-O2 -debug_access+all -lca  " #-debug_region=1,${TESTBENCH}
fi

flags+="-cpp ${CXX_PATH} "
[[ -n "${SELCFG}" ]]   && flags+="-pvalue+SelectedCfg=${SELCFG} "

pargs=""
[[ -n "${BOOTMODE}" ]] && pargs+="+BOOTMODE=${BOOTMODE} "
[[ -n "${PRELMODE}" ]] && pargs+="+PRELMODE=${PRELMODE} "
[[ -n "${BINARY}" ]]   && pargs+="+BINARY=${BINARY} "
[[ -n "${IMAGE}" ]]    && pargs+="+IMAGE=${IMAGE} "

# DRAMSys
if [ -n "${USE_DRAMSYS}" ]; then
    flags+="-pvalue UseDramSys=${USE_DRAMSYS} "
    if [[ "${USE_DRAMSYS}" == 1 ]]; then
        DRAMSYS_ROOT="../sim/dramsys"
        DRAMSYS_LIB="${DRAMSYS_ROOT}/build/lib"
        pargs+="+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
        pargs+="-sv_lib ${DRAMSYS_LIB}/libDRAMSys_Simulator "
    fi
fi

COLOR_NC='\e[0m'
COLOR_BLUE='\e[0;34m'

${VCS_BIN} ${flags} ../../sim/src/elfloader.cpp ${TESTBENCH} | tee elaborate.log


# vc_fcc -full64  -sff gen_faults.sff -daidir simv.daidir  -suppress_cell  -overwrite -report gen_faults_report.sff  
#tb_cheshire_soc.fix.dut.gen_cva6_cores[0].i_core_cva6.ex_stage_i.alu_i

# Start simulation
printf ${COLOR_BLUE}"${VCS_VERSION} ${VERDI_VERSION} ./simv ${pargs}"${COLOR_NC}"\n"
 ./simv -no_save  ${pargs} | tee simulate.log
