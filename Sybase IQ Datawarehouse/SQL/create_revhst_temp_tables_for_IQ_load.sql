use rev_hist
go     
PRINT '<<< Re-creating temp tables for rev_hist load >>>'
go     
select max(isnull(record_id,0)) record_id into tempdb..bcxref_ins from bcxref_iq
go     
select '0' shipper_num into tempdb..revhstd_ins
go     
select '0' shipper_num into tempdb..revhstd1_ins
go    
select convert(int,0) linkage into tempdb..revhstf_ins 
go     
select max(isnull(record_id,0)) record_id into tempdb..revhstf1_ins from revhstf1_iq
go     
select convert(int,0) linkage into tempdb..revhsth_ins
go    
select '0' invoice into tempdb..revhstm_ins 
go    
select convert(int,0) linkage into tempdb..revhstr_ins 
go     
select max(isnull(record_id,0)) record_id into tempdb..revhstz_ins from revhstz_iq
go     
select max(reference_num) reference_num into tempdb..dimweight_ins from dimweight_iq
go     
