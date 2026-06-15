# #!/usr/bin/env bash
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

TESTBENCH=tb_cheshire_soc
#$CHS_ROOT/target/sim/src/tb_cheshire_soc.sv

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

flags=" -full64 \
        -kdb \
        -sverilog \
        +vcs+fsdbon \
        +vcs+initreg+random \
        +fault+var \
        -notice \
        -fsim \
        -fsim=portfaults \
        -fsim=dut:tb_cheshire_soc.fix.dut.gen_cva6_cores[0].i_core_cva6.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile \
        -O2 \
        -debug_access+all \
        -debug_region=cell+lib
        -lca \
        -l compile.log "
#-fsim=portfaults \

#-fsim=dut:tb_cheshire_soc.fix.dut \
#/home/p.bevilacqua/rigoletto/cheshire_cad/target/sim/src/dump_strobe_pkg.sv \
#/home/p.bevilacqua/rigoletto/cheshire_cad/target/sim/src/strobe.sv \

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

# Comando base
vcs_cmd=(
    ./simv
    +vcs+initreg+0
    +fault+portfault
    +fault+var
    +fault+expr
    +fsdb+all 
    +fsdb+mda 
    +vcs+dumparrays
    -no_save
)

case "${SIM_MODE}" in

    vcs-cli)
        echo "[RUN MODE] VCS CLI"

        "${vcs_cmd[@]}" ${pargs} \
            | tee simulate.log
        ;;

    vcs-gui)
        echo "[RUN MODE] VCS GUI"

        "${vcs_cmd[@]}" \
            -gui \
            ${pargs} \
            | tee simulate.log
        ;;

    vcs-fsim)
        echo "[RUN MODE] VCS FSIM"

        "${vcs_cmd[@]}" \
            ${pargs} \
            | tee simulate.log

        echo "[FSIM] Running vc_fcc..."

        vc_fcc -full64 \
            +vcs+initreg+0 \
            +fault+portfault \
            +fault+var \
            +fault+expr \
            -sff ../src/gen_faults.sff \
            -daidir simv.daidir \
            -overwrite \
            -report ../src/gen_faults_report.sff 
        #-suppress_cell \#

        echo "[FSIM] Running vc_fcm..."

        vc_fcm -tcl_script ../src/fcm.tcl -connect
        ;;

    *)
        echo "ERROR: Unknown mode '${SIM_MODE}'"
        echo "Valid modes:"
        echo "  vcs-cli"
        echo "  vcs-gui"
        echo "  vcs-fsim"
        exit 1
        ;;

esac