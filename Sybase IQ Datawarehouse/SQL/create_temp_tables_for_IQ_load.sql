use cpscan
go     
PRINT '<<< Re-creating temp tables from cpscan load >>>'
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..driver_stats_ins from driver_stats_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..truck_stats_ins from truck_stats_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ac_ins from tttl_ac_address_correction_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_bi_ins from tttl_bi_bulk_inbound_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_cp_ins from tttl_cp_cod_package_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ct_ins from tttl_ct_cod_totals_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_dc_ins from tttl_dc_delivery_comment_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_dex_ins from tttl_dex_dlry_cross_ref_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_dp_ins from tttl_dp_daily_pickup_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_dr_ins from tttl_dr_delivery_record_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ev_ins from tttl_ev_event_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ex_ins from tttl_ex_exception_comment_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_fl_ins from tttl_fl_fuel_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_hc_ins from tttl_hc_hub_cod_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_hv_ins from tttl_hv_high_value_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_id_ins from tttl_id_driver_route_id_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ii_ins from tttl_ii_interline_inbound_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_io_ins from tttl_io_interline_outbound_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_lo_ins from tttl_lo_linehaul_outbound_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ma_ins from tttl_ma_manifest_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_mb_ins from tttl_mb_multiple_barcodes_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ms_ins from tttl_ms_missorts_iq
go     
select max(order_num) order_num into tempdb..tttl_or_ins from tttl_or_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_pa_ins from tttl_pa_parcel_iq
go     
--select max(pod_request_num) pod_request_num into tempdb..tttl_pd_ins from tttl_pd_iq
--go
--select max(pod_request_num) pod_request_num into tempdb..tttl_pp_ins from tttl_pp_iq
--go
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_pr_ins from tttl_pr_pickup_record_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_ps_ins from tttl_ps_pickup_shipper_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_pt_ins from tttl_pt_pickup_totals_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_rt_ins from tttl_rt_return_to_shipper_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_se_ins from tttl_se_search_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_up_ins from tttl_up_US_parcels_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..tttl_us_ins from tttl_us_iq
go     
select isnull(dateadd(dd,-1,max(inserted_on_cons)),'10/3/95') inserted_on_cons into tempdb..employee_ins from employee
go    

