set DUT "tb_cheshire_soc"
set TEST_NAME "test_alu"
set CAMPAIGN_NAME "alu_campaign"

create_campaign \
    -args "-full64 -daidir simv.daidir -sff gen_faults.sff -overwrite\
    -campaign $CAMPAIGN_NAME \
    -dut $DUT"
    

set_config -global_max_jobs 4

create_testcases \
    -name $TEST_NAME \
    -exec "./simv" \
    -args "+$TEST_NAME" \
    -fsim_args ""

fsim

dump \
    -fids "120"\
    -mode fm \
    -tc $TEST_NAME \
    -fsdb fm_${TEST_NAME}_120.fsdb

report \
    -campaign $CAMPAIGN_NAME \
    -report fsim_v.rpt \
    -overwrite