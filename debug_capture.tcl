proc chs_try_vcd_add {path {recursive 0}} {
    if {$recursive} {
        if {[catch {vcd add -r $path} err]} {
            puts "\[DEBUG_VCD\]\[SKIP\] $path :: $err"
        }
    } else {
        if {[catch {vcd add $path} err]} {
            puts "\[DEBUG_VCD\]\[SKIP\] $path :: $err"
        }
    }
}

proc chs_debug_capture {} {
    if {![info exists ::DEBUG_VCD_FILE] || ![info exists ::DEBUG_VCD_RUN]} {
        puts "\[DEBUG_VCD\]\[ERROR\] DEBUG_VCD_FILE/DEBUG_VCD_RUN not set"
        quit -f
    }

    if {![info exists ::DEBUG_PROFILE]} {
        set ::DEBUG_PROFILE "minimal"
    }

    puts "\[DEBUG_VCD\] file=$::DEBUG_VCD_FILE run=$::DEBUG_VCD_RUN profile=$::DEBUG_PROFILE"
    vcd file $::DEBUG_VCD_FILE

    # Always capture EOC register path and reg demux path.
    foreach sig {
        /tb_cheshire_soc/fix/dut/i_regs/scratch_2_we
        /tb_cheshire_soc/fix/dut/i_regs/scratch_2_wd
        /tb_cheshire_soc/fix/dut/i_regs/scratch_2_qs
        /tb_cheshire_soc/fix/dut/i_regs/reg_we
        /tb_cheshire_soc/fix/dut/i_regs/reg_addr
        /tb_cheshire_soc/fix/dut/reg_in_req
        /tb_cheshire_soc/fix/dut/reg_in_rsp
        /tb_cheshire_soc/fix/dut/axi_reg_amo_req
        /tb_cheshire_soc/fix/dut/axi_reg_amo_rsp
        /tb_cheshire_soc/fix/dut/axi_reg_cut_req
        /tb_cheshire_soc/fix/dut/axi_reg_cut_rsp
        /tb_cheshire_soc/fix/dut/axi_ext_slv_req_o
        /tb_cheshire_soc/fix/dut/axi_ext_slv_rsp_i
    } {
        chs_try_vcd_add $sig 0
    }

    # Add LSU/store-buffer internals only when requested.
    if {$::DEBUG_PROFILE eq "lsu" || $::DEBUG_PROFILE eq "full"} {
        foreach path {
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/load_store_unit_i/*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/store_unit_i/*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/store_buffer_i/*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/lsu_bypass_i/*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/commit_stage_i/*
        } {
            chs_try_vcd_add $path 1
        }
    }

    # Full profile extends LSU capture with robust frontend PC visibility.
    if {$::DEBUG_PROFILE eq "full"} {
        foreach path {
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/issue_stage_i/*pc*
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/*pc*
        } {
            chs_try_vcd_add $path 1
        }
        chs_try_vcd_add {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/genblk2[0]/decoder_i/pc_i} 0

        # CSR mirati utili per debug pipeline/trap flow.
        foreach sig {
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/mstatus_q
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/mtvec_q
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/mepc_q
        } {
            chs_try_vcd_add $sig 0
        }

        # Controller ridotto ai segnali che impattano il flusso pipeline.
        foreach sig {
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/pc_commit_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/set_pc_commit_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_if_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_unissued_instr_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_id_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_ex_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/halt_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/halt_frontend_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/ex_valid_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/eret_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/resolved_branch_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_csr_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_commit_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_dcache_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/flush_dcache_ack_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/stall_cache_o
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/cache_busy_i
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/fence_active_q
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/fence_i_active_q
            /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/controller_i/fence_t_state_q
        } {
            chs_try_vcd_add $sig 0
        }
    }

    run $::DEBUG_VCD_RUN
    vcd flush
    quit -f
}

        ## Solo PC pipeline stages (ID/ISSUE/EX/COMMIT).
        #add wave -r /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/*pc*; \
        #add wave -r /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/issue_stage_i/*pc*; \
        #add wave -r /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/*pc*; \
        #add wave -r /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/commit_stage_i/*pc*; \
        ## AXI significativi per capire write verso BRAM (AW/W/B + remap path).
        #add wave /tb_cheshire_soc/fix/dut/axi_ext_slv_req_o; \
        #add wave /tb_cheshire_soc/fix/dut/axi_ext_slv_rsp_i; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_cut_req; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_cut_rsp; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_remap_req; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_remap_rsp; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_mst_req_o; \
        #add wave /tb_cheshire_soc/fix/dut/axi_llc_mst_rsp_i;
        #add wave /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/*; \