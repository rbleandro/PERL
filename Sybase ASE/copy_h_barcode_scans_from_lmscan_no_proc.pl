#!/usr/bin/perl -w

#Usage Restrictions
open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep copy_h_barcode_scans_from_lmscan.pl|grep -v grep|grep -v $my_pid|grep -v "vim copy_h_barcode_scans_from_lmscan.pl"|grep -v "less copy_h_barcode_scans_from_lmscan.pl"`;

print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}


print "copy_h_barcode_scans_from_lmscan StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cpscan
go
set clientapplname \'copy_h_barcode_scans_from_lmscan\'
go
declare
	\@start_date datetime,
	\@end_date	datetime
select
	\@start_date = null,
	\@end_date = null
	
-- Default
if (\@start_date is null or \@end_date is null)
begin
	select \@end_date 	= getdate()
	select \@start_date = convert(date, dateadd(day, -2, \@end_date))
end

select
ev.alt_barcode as reference_num, ev.scan_time_date, ev.conv_time_date, ev.employee_num
into #delete_this
from lmscan..tttl_ma_barcode mb
join cpscan..tttl_ev_event_hospital ev on (mb.reference_num=ev.alt_barcode)
where mb.inserted_on between \@start_date and \@end_date

print \"Deleting from tttl_ev_event_hospital\"
delete cpscan..tttl_ev_event_hospital
from #delete_this m
join cpscan..tttl_ev_event_hospital ev on (m.reference_num = ev.alt_barcode and m.conv_time_date=ev.conv_time_date and m.employee_num=ev.employee_num)

print \"Deleting from tttl_dr_delivery_record_hospital\"
delete cpscan..tttl_dr_delivery_record_hospital
from #delete_this m
join cpscan..tttl_dr_delivery_record_hospital lm on (m.conv_time_date=lm.conv_time_date and m.employee_num=lm.employee_num)

print \"Deleting from tttl_dc_delivery_comment_hospital\"
delete cpscan..tttl_dc_delivery_comment_hospital
from #delete_this m
join cpscan..tttl_dc_delivery_comment_hospital lm on (m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)

print \"Deleting from tttl_ex_exception_comment_hospital\"
delete cpscan..tttl_ex_exception_comment_hospital
from #delete_this m
join cpscan..tttl_ex_exception_comment_hospital lm on (m.reference_num=lm.reference_num and m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)
    
print \"Deleting from tttl_ps_pickup_shipper_hospital\"
delete cpscan..tttl_ps_pickup_shipper_hospital
from #delete_this m
join cpscan..tttl_ps_pickup_shipper_hospital lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)

print \"Deleting from tttl_pr_pickup_record_hospital\"
delete cpscan..tttl_pr_pickup_record_hospital 
from #delete_this m
join cpscan..tttl_pr_pickup_record_hospital lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)

print \"Deleting from COSDataCapture_hospital\"
delete cpscan..COSDataCapture_hospital
from #delete_this m
join cpscan..COSDataCapture_hospital lm on (lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num)
    
print \"Deleting from PictureDataCapture_hospital\"
delete cpscan..PictureDataCapture_hospital
from #delete_this m
join cpscan..PictureDataCapture_hospital lm
on 
(
    lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num
    and lm.service_type=\'\' and lm.shipper_num=\'\' -- Required for the index in PictureDataCapture
)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------- COPYING RECORDS FROM THE HOSPITAL TO CPSCAN ----------------------------------

-- First, get the list of all the events that exist in lmscan, but not in cpscan
select
	id = identity(10),
	ex.service_type as h_st, ex.shipper_num as h_sn, ex.reference_num as h_rn,
	lm_ev.alt_barcode as reference_num, lm_ev.conv_time_date, lm_ev.employee_num, lm_ev.scan_time_date
into #missing_ev
from
	cpscan..tttl_ev_event_extended ex
	join cpscan..tttl_ev_event_hospital lm_ev
		on (lm_ev.alt_barcode=ex.alt_barcode)
	left join cpscan..tttl_ev_event cp_ev (index tttl_ev_pkey)
		on (
			-- Check if the barcode from ev_extended exists in ev_event
			cp_ev.service_type=ex.service_type and cp_ev.shipper_num=ex.shipper_num and cp_ev.reference_num=ex.reference_num
			-- And check if it is the same event as what lmscan has
			and cp_ev.conv_time_date=lm_ev.conv_time_date and cp_ev.employee_num=lm_ev.employee_num and cp_ev.status=lm_ev.status
		)
where
	ex.inserted_on_cons between \@start_date and \@end_date
	and ex.service_type = \'H\'
	and cp_ev.reference_num is null

create clustered index idx_id on #missing_ev (id)

/* 
* Loop through the missing events, and start inserting the important rows
* (this is necessary because tttl_ev_event has a trigger that only fires for a single row, so each row needs to be inserted seperately)
*/

-- Prep the vars
declare 
	\@i 		int,
	\@max_i 	int,
	\@log_ctd datetime,
	\@log_en	char(6)
select
	\@i 		= 1,
	\@max_i 	= (select max(id) from #missing_ev)

-- Perform the loop
while (\@i <= \@max_i)
begin
	/* Log the current row, to help the DBAs troubleshoot bad data */
	select
		\@log_ctd = conv_time_date,
		\@log_en	 = employee_num
	from
		#missing_ev
	where
		id = \@i
	
	-- Output the current row to the log
	print \"Using cpscan..tttl_ev_event_hospital where conv_time_date=\'%1!\' and employee_num=\'%2!\'\", \@log_ctd, \@log_en
	
	
	/* Insert the event into cpscan */
	print \"Inserting into tttl_ev_event\"
	insert cpscan..tttl_ev_event
		(reference_num, service_type, shipper_num, conv_time_date, employee_num, status, scan_time_date, terminal_num, pickup_shipper_num, postal_code, additional_serv_flag, mod10b_fail_flag, multiple_barcode_flag, multiple_shipper_flag, comments_flag, inserted_on_cons, updated_on_cons)
	select
		m.h_rn, m.h_st, m.h_sn, -- Insert the H barcode 
		ev.conv_time_date, ev.employee_num, ev.status, ev.scan_time_date, ev.terminal_num, ev.pickup_shipper_num, ev.postal_code, ev.additional_serv_flag, ev.mod10b_fail_flag, ev.multiple_barcode_flag, ev.multiple_shipper_flag, ev.comments_flag, 
		getdate(), getdate()
	from
		#missing_ev m
		join cpscan..tttl_ev_event_hospital ev
			on (m.reference_num = ev.alt_barcode and m.conv_time_date=ev.conv_time_date and m.employee_num=ev.employee_num)
	where
		m.id = \@i
		
	
	/* Insert the tttl_dr_delivery_record into cpscan */
	print \"Inserting into tttl_dr_delivery_record\"
	if not exists (select * from #missing_ev m join cpscan..tttl_dr_delivery_record lm on (m.conv_time_date=lm.conv_time_date and m.employee_num=lm.employee_num) where m.id = \@i)
	begin
		insert cpscan..tttl_dr_delivery_record
			(conv_time_date, employee_num, delivery_rec_num, multiple_del_rec_flag, manual_entry_flag, consignee_name, consignee_num, consignee_unit_number_name, consignee_street_number, consignee_street_name, consignee_more_address, consignee_city, consignee_postal_code, residential_flag, inserted_on_cons, updated_on_cons, signature)
		select
			lm.conv_time_date, lm.employee_num, lm.delivery_rec_num, lm.multiple_del_rec_flag, lm.manual_entry_flag, lm.consignee_name, lm.consignee_num, lm.consignee_unit_number_name, lm.consignee_street_number, lm.consignee_street_name, lm.consignee_more_address, lm.consignee_city, lm.consignee_postal_code, lm.residential_flag, 
			getdate(), getdate(),
			lm.signature
		from
			#missing_ev m
			join cpscan..tttl_dr_delivery_record_hospital lm
				on (m.conv_time_date=lm.conv_time_date and m.employee_num=lm.employee_num)
		where
			m.id = \@i
	end
	
	
	
	/* Insert the tttl_dc_delivery_comment into cpscan */
	print \"Inserting into tttl_dc_delivery_comment\"
	if not exists (select * from #missing_ev m join cpscan..tttl_dc_delivery_comment lm on (m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num) where m.id = \@i)
	begin
		insert cpscan..tttl_dc_delivery_comment
			(scan_time_date, employee_num, status, comments, inserted_on_cons, updated_on_cons)
		select
			lm.scan_time_date, lm.employee_num, lm.status, lm.comments, 
			getdate(), getdate()
		from
			#missing_ev m
			join cpscan..tttl_dc_delivery_comment_hospital lm
				on (m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)
		where
			m.id = \@i
	end
	
	
	/* Insert the tttl_ex_exception_comment into cpscan */
	print \"Inserting into tttl_ex_exception_comment\"
	if not exists (select * from #missing_ev m join cpscan..tttl_ex_exception_comment lm on (lm.service_type=m.h_st and lm.shipper_num=m.h_sn and lm.reference_num=m.h_rn and m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num) where m.id = \@i)
	begin
		insert cpscan..tttl_ex_exception_comment
			(reference_num, service_type, shipper_num, scan_time_date, employee_num, status, exception_data, comments, inserted_on_cons, updated_on_cons)
		select
			m.h_rn, m.h_st, m.h_sn, -- Insert the H barcode 
			lm.scan_time_date, lm.employee_num, lm.status, lm.exception_data, lm.comments,
			getdate(), getdate()
		from
			#missing_ev m
			join cpscan..tttl_ex_exception_comment_hospital lm
				on (m.reference_num=lm.reference_num and m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)
		where
			m.id = \@i
	end
	
		
	/* Insert the tttl_ps_pickup_shipper into cpscan */
	print \"Inserting into tttl_ps_pickup_shipper\"
	if not exists (select * from #missing_ev m join cpscan..tttl_ps_pickup_shipper lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num) where m.id = \@i)
	begin
		insert cpscan..tttl_ps_pickup_shipper
			(shipper_num, conv_time_date, employee_num, multiple_shipper_flag, no_package_flag, missed_pickup_flag, manual_entry_flag, terminal_num, inserted_on_cons, updated_on_cons)
		select
			lm.shipper_num, lm.conv_time_date, lm.employee_num, lm.multiple_shipper_flag, lm.no_package_flag, lm.missed_pickup_flag, lm.manual_entry_flag, lm.terminal_num,
			getdate(), getdate()
		from
			#missing_ev m
			join cpscan..tttl_ps_pickup_shipper_hospital lm
				on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)
		where
			m.id = \@i
	end
	
	
	/* Insert the tttl_pr_pickup_record into cpscan */
	print \"Inserting into tttl_pr_pickup_record\"
	if not exists (select * from #missing_ev m join cpscan..tttl_pr_pickup_record lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num) where m.id = \@i)
	begin
		insert cpscan..tttl_pr_pickup_record
			(pickup_rec_num, conv_time_date, employee_num, num_pickup_packages, num_pickup_cod, num_pickup_select, multiple_pickup_rec_flag, manifest_flag, not_scanned_flag, manual_entry_flag, inserted_on_cons, updated_on_cons, modified_pickup_record)
		select
			lm.pickup_rec_num, lm.conv_time_date, lm.employee_num, lm.num_pickup_packages, lm.num_pickup_cod, lm.num_pickup_select, lm.multiple_pickup_rec_flag, lm.manifest_flag, lm.not_scanned_flag, lm.manual_entry_flag,
			getdate(), getdate(),
			lm.modified_pickup_record
		from
			#missing_ev m
			join cpscan..tttl_pr_pickup_record_hospital lm
				on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)
		where
			m.id = \@i
	end
	
	
	/* Insert the COSDataCapture into cpscan */
	print \"Inserting into COSDataCapture\"
	insert cpscan..COSDataCapture
		(service_type, reference_num, shipper_num, scan_time_date, employee_num, COSSignature, COSPicture, inserted_on_cons, updated_on_cons)
	select
		m.h_rn, m.h_st, m.h_sn, -- Insert the H barcode 
		lm.scan_time_date, lm.employee_num, lm.COSSignature, lm.COSPicture,
		getdate(), getdate()
	from
		#missing_ev m
		join cpscan..COSDataCapture_hospital lm
			on (lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num)
	where
		m.id = \@i
		
		
	/* Insert the PictureDataCapture into cpscan */
	print \"Inserting into PictureDataCapture\"
	insert cpscan..PictureDataCapture
		(status, service_type, reference_num, shipper_num, scan_time_date, employee_num, PDC_picture, inserted_on_cons, updated_on_cons)
	select
		lm.status, 
		m.h_rn, m.h_st, m.h_sn, -- Insert the H barcode 
		lm.scan_time_date, lm.employee_num, lm.PDC_picture, 
		getdate(), getdate()
	from
		#missing_ev m
		join cpscan..PictureDataCapture_hospital lm
			on (
				lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num
				and lm.service_type=\'\' and lm.shipper_num=\'\' -- Required for the index in PictureDataCapture
			)
	where
		m.id = \@i


	-- Increment to the next row
	select \@i = \@i + 1
end -- End of while loop

------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------- CLEANING UP COPIED RECORDS FROM THE HOSPITAL TABLES --------------------------------------------------------------
print \"Cleaning tttl_ev_event_hospital\"
delete cpscan..tttl_ev_event_hospital
from #missing_ev m
join cpscan..tttl_ev_event_hospital ev on (m.reference_num = ev.alt_barcode and m.conv_time_date=ev.conv_time_date and m.employee_num=ev.employee_num)

print \"Cleaning tttl_dr_delivery_record_hospital\"
delete cpscan..tttl_dr_delivery_record_hospital
from #missing_ev m
join cpscan..tttl_dr_delivery_record_hospital lm on (m.conv_time_date=lm.conv_time_date and m.employee_num=lm.employee_num)

print \"Cleaning tttl_dc_delivery_comment_hospital\"
delete cpscan..tttl_dc_delivery_comment_hospital
from #missing_ev m
join cpscan..tttl_dc_delivery_comment_hospital lm on (m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)

print \"Cleaning tttl_ex_exception_comment_hospital\"
delete cpscan..tttl_ex_exception_comment_hospital
from #missing_ev m
join cpscan..tttl_ex_exception_comment_hospital lm on (m.reference_num=lm.reference_num and m.scan_time_date=lm.scan_time_date and m.employee_num=lm.employee_num)
    
print \"Cleaning tttl_ps_pickup_shipper_hospital\"
delete cpscan..tttl_ps_pickup_shipper_hospital
from #missing_ev m
join cpscan..tttl_ps_pickup_shipper_hospital lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)

print \"Cleaning tttl_pr_pickup_record_hospital\"
delete cpscan..tttl_pr_pickup_record_hospital 
from #missing_ev m
join cpscan..tttl_pr_pickup_record_hospital lm on (lm.conv_time_date=m.conv_time_date and lm.employee_num=m.employee_num)

print \"Cleaning COSDataCapture_hospital\"
delete cpscan..COSDataCapture_hospital
from #missing_ev m
join cpscan..COSDataCapture_hospital lm on (lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num)
    
print \"Cleaning PictureDataCapture_hospital\"
delete cpscan..PictureDataCapture_hospital
from #missing_ev m
join cpscan..PictureDataCapture_hospital lm
on 
(
    lm.reference_num=m.reference_num and lm.scan_time_date=m.scan_time_date and lm.employee_num=m.employee_num
    and lm.service_type=\'\' and lm.shipper_num=\'\' -- Required for the index in PictureDataCapture
)

go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - copy_h_barcode_scans_from_lmscan

Following status was received during copy_h_barcode_scans_from_lmscan that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "copy_h_barcode_scans_from_lmscan FinTime: $currTime\n";

