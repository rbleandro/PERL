use tempdb
go	
IF OBJECT_ID('dbo.truck_stats_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.truck_stats_ins
    IF OBJECT_ID('dbo.truck_stats_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.truck_stats_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.truck_stats_ins >>>'
END
go    
IF OBJECT_ID('dbo.truck_stats_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.truck_stats_upd
    IF OBJECT_ID('dbo.truck_stats_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.truck_stats_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.truck_stats_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ac_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ac_ins
    IF OBJECT_ID('dbo.tttl_ac_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ac_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ac_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ac_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ac_upd
    IF OBJECT_ID('dbo.tttl_ac_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ac_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ac_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_bi_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_bi_ins
    IF OBJECT_ID('dbo.tttl_bi_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_bi_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_bi_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_bi_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_bi_upd
    IF OBJECT_ID('dbo.tttl_bi_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_bi_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_bi_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_cp_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_cp_ins
    IF OBJECT_ID('dbo.tttl_cp_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_cp_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_cp_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_cp_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_cp_upd
    IF OBJECT_ID('dbo.tttl_cp_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_cp_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_cp_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ct_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ct_ins
    IF OBJECT_ID('dbo.tttl_ct_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ct_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ct_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ct_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ct_upd
    IF OBJECT_ID('dbo.tttl_ct_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ct_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ct_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dc_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dc_ins
    IF OBJECT_ID('dbo.tttl_dc_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dc_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dc_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dc_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dc_upd
    IF OBJECT_ID('dbo.tttl_dc_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dc_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dc_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dex_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dex_ins
    IF OBJECT_ID('dbo.tttl_dex_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dex_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dex_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dex_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dex_upd
    IF OBJECT_ID('dbo.tttl_dex_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dex_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dex_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dp_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dp_ins
    IF OBJECT_ID('dbo.tttl_dp_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dp_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dp_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dp_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dp_upd
    IF OBJECT_ID('dbo.tttl_dp_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dp_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dp_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dr_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dr_ins
    IF OBJECT_ID('dbo.tttl_dr_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dr_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dr_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_dr_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_dr_upd
    IF OBJECT_ID('dbo.tttl_dr_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_dr_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_dr_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ev_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ev_ins
    IF OBJECT_ID('dbo.tttl_ev_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ev_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ev_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ev_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ev_upd
    IF OBJECT_ID('dbo.tttl_ev_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ev_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ev_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ex_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ex_ins
    IF OBJECT_ID('dbo.tttl_ex_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ex_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ex_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ex_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ex_upd
    IF OBJECT_ID('dbo.tttl_ex_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ex_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ex_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_fl_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_fl_ins
    IF OBJECT_ID('dbo.tttl_fl_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_fl_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_fl_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_fl_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_fl_upd
    IF OBJECT_ID('dbo.tttl_fl_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_fl_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_fl_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_hc_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_hc_ins
    IF OBJECT_ID('dbo.tttl_hc_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_hc_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_hc_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_hc_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_hc_upd
    IF OBJECT_ID('dbo.tttl_hc_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_hc_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_hc_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_hv_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_hv_ins
    IF OBJECT_ID('dbo.tttl_hv_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_hv_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_hv_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_hv_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_hv_upd
    IF OBJECT_ID('dbo.tttl_hv_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_hv_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_hv_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_id_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_id_ins
    IF OBJECT_ID('dbo.tttl_id_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_id_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_id_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_id_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_id_upd
    IF OBJECT_ID('dbo.tttl_id_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_id_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_id_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ii_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ii_ins
    IF OBJECT_ID('dbo.tttl_ii_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ii_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ii_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ii_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ii_upd
    IF OBJECT_ID('dbo.tttl_ii_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ii_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ii_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_io_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_io_ins
    IF OBJECT_ID('dbo.tttl_io_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_io_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_io_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_io_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_io_upd
    IF OBJECT_ID('dbo.tttl_io_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_io_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_io_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_lo_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_lo_ins
    IF OBJECT_ID('dbo.tttl_lo_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_lo_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_lo_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_lo_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_lo_upd
    IF OBJECT_ID('dbo.tttl_lo_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_lo_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_lo_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ma_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ma_ins
    IF OBJECT_ID('dbo.tttl_ma_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ma_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ma_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ma_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ma_upd
    IF OBJECT_ID('dbo.tttl_ma_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ma_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ma_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_mb_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_mb_ins
    IF OBJECT_ID('dbo.tttl_mb_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_mb_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_mb_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_mb_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_mb_upd
    IF OBJECT_ID('dbo.tttl_mb_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_mb_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_mb_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ms_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ms_ins
    IF OBJECT_ID('dbo.tttl_ms_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ms_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ms_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ms_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ms_upd
    IF OBJECT_ID('dbo.tttl_ms_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ms_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ms_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_or_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_or_ins
    IF OBJECT_ID('dbo.tttl_or_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_or_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_or_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pa_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pa_ins
    IF OBJECT_ID('dbo.tttl_pa_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pa_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pa_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pa_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pa_upd
    IF OBJECT_ID('dbo.tttl_pa_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pa_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pa_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pr_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pr_ins
    IF OBJECT_ID('dbo.tttl_pr_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pr_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pr_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pr_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pr_upd
    IF OBJECT_ID('dbo.tttl_pr_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pr_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pr_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ps_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ps_ins
    IF OBJECT_ID('dbo.tttl_ps_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ps_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ps_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_ps_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_ps_upd
    IF OBJECT_ID('dbo.tttl_ps_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_ps_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_ps_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pt_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pt_ins
    IF OBJECT_ID('dbo.tttl_pt_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pt_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pt_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_pt_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_pt_upd
    IF OBJECT_ID('dbo.tttl_pt_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_pt_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_pt_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_rt_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_rt_ins
    IF OBJECT_ID('dbo.tttl_rt_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_rt_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_rt_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_rt_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_rt_upd
    IF OBJECT_ID('dbo.tttl_rt_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_rt_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_rt_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_se_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_se_ins
    IF OBJECT_ID('dbo.tttl_se_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_se_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_se_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_se_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_se_upd
    IF OBJECT_ID('dbo.tttl_se_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_se_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_se_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_up_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_up_ins
    IF OBJECT_ID('dbo.tttl_up_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_up_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_up_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_up_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_up_upd
    IF OBJECT_ID('dbo.tttl_up_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_up_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_up_upd >>>'
END
go    
IF OBJECT_ID('dbo.tttl_us_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_us_ins
    IF OBJECT_ID('dbo.tttl_us_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_us_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_us_ins >>>'
END
go    
IF OBJECT_ID('dbo.tttl_us_upd') IS NOT NULL
BEGIN
    DROP TABLE dbo.tttl_us_upd
    IF OBJECT_ID('dbo.tttl_us_upd') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.tttl_us_upd >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.tttl_us_upd >>>'
END
go    	
IF OBJECT_ID('dbo.driver_stats_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.driver_stats_ins
    IF OBJECT_ID('dbo.driver_stats_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.driver_stats_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.driver_stats_ins >>>'
END
go     
IF OBJECT_ID('dbo.employee_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.employee_ins
    IF OBJECT_ID('dbo.employee_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.employee_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.employee_ins >>>'
END
go    

