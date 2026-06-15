#set DUT "tb_cheshire_soc.fix.dut"
set DUT "tb_cheshire_soc.fix.dut.gen_cva6_cores[0].i_core_cva6.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile"
set CAMPAIGN_NAME "regifile"
set TEST_NAME "test_${CAMPAIGN_NAME}"

create_campaign \
    -args "-full64 -daidir simv.daidir -sff ../src/gen_faults.sff -overwrite \
    -campaign $CAMPAIGN_NAME \
    -dut $DUT"
    

set_config -global_max_jobs 10
#set_config -fsim_mode serial

set tc_args "+$TEST_NAME"
if {[info exists ::env(BOOTMODE)] && $::env(BOOTMODE) ne ""} {
    append tc_args " +BOOTMODE=$::env(BOOTMODE)"
}
if {[info exists ::env(PRELMODE)] && $::env(PRELMODE) ne ""} {
    append tc_args " +PRELMODE=$::env(PRELMODE)"
}
if {[info exists ::env(BINARY)] && $::env(BINARY) ne ""} {
    append tc_args " +BINARY=$::env(BINARY)"
}
if {[info exists ::env(IMAGE)] && $::env(IMAGE) ne ""} {
    append tc_args " +IMAGE=$::env(IMAGE)"
}

create_testcases \
    -name $TEST_NAME \
    -exec "./simv" \
    -args $tc_args \
    -fsim_args ""

#fdb_connect

fsim

dump \
    -fids "120"\
    -mode fm \
    -tc $TEST_NAME \
    -fsdb fm_${TEST_NAME}_120.fsdb

report -campaign $CAMPAIGN_NAME 

report \
    -campaign $CAMPAIGN_NAME \
    -report fsim_v.rpt \
    -overwrite