#!/usr/bin/perl

###################################################################################
#Script:   This script purges tables that record any inserts, updates or deletes  #
#          in event and parcel tables                                             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#May 9,05	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage:purge_events_procs_trig_tables.pl CPDATA1\n";
   die;
}
#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Initialize vars
$server = $ARGV[0];

#Execute purge now 

$error = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server -n -b -s'\t'<<EOF 2>&1
use cpscan
go
truncate table tttl_ev_event_deletes
go
truncate table tttl_ev_event_inserts
go
truncate table tttl_ev_event_updates
go
truncate table tttl_pa_parcel_deletes
go
truncate table tttl_pa_parcel_inserts
go
truncate table tttl_pa_parcel_updates
go
truncate table tttl_batchdown_deletes
go
truncate table tttl_batchdown_inserts
go
truncate table tttl_ma_COD_deletes
go
truncate table tttl_ma_COD_inserts
go
truncate table tttl_ma_barcode_deletes
go
truncate table tttl_ma_barcode_inserts
go
truncate table tttl_ma_document_deletes
go
truncate table tttl_ma_document_inserts
go
truncate table tttl_ma_manifest_deletes
go
truncate table tttl_ma_manifest_inserts
go
truncate table tttl_ma_other_deletes
go
truncate table tttl_ma_other_inserts
go
truncate table tttl_ma_shipment_deletes
go
truncate table tttl_ma_shipment_inserts
go
truncate table tttl_sortation_deletes
go
truncate table tttl_sortation_inserts
go
use rev_hist
go
truncate table bcxref_iq_deletes
go
truncate table bcxref_iq_inserts
go
truncate table cwparcel_deletes
go
truncate table cwparcel_inserts
go
truncate table cwscans_iq_deletes
go
truncate table cwscans_iq_inserts
go
truncate table cwshipment_iq_deletes
go
truncate table cwshipment_iq_inserts
go
truncate table revhstf1_iq_deletes
go
truncate table revhstf1_iq_inserts
go
truncate table revhstf_iq_deletes
go
truncate table revhstf_iq_inserts
go
truncate table revhsth_iq_deletes
go
truncate table revhsth_iq_inserts
go
truncate table revhstr_iq_deletes
go
truncate table revhstr_iq_inserts
go
truncate table revhstz_iq_deletes
go
truncate table revhstz_iq_inserts
go
exit
EOF
`;
print $error."\n";


if($error =~ /error/i || $error =~ /msg/i){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Trigger Tables Deleted...

$error
EOF
`;
}

