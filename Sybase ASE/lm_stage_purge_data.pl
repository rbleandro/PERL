#!/usr/bin/perl -w

#Description:	Deletes old data from auxiliary tables in lm_stage database.
#Author:    	Amer Khan
#Revision:
#Date           Name            Description
#------------------------------------------------------------------------------------------------------
#Jun 12	2013	Amer Khan 		Originally created
#Sep 01	2019	Rafael Leandro	Modified to call a procedure to cleanup the ev_event table. 
#								The proc will cleanup the table in several small transactions to prevent locks in the database and reduce replication stress


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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "lm_stage_purge_data StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use lm_stage
go
delete employee_login where scanner_drained_at < dateadd(dd,-40,getdate())
go
delete tttl_dr_delivery_record where conv_time_date < dateadd(dd,-40,getdate())
go
delete tttl_ex_exception_comment where updated_on_cons < dateadd(dd,-40,getdate())
go
delete tttl_io_interline_outbound where updated_on_cons < dateadd(dd,-40,getdate())
go
delete tttl_pr_pickup_record where updated_on_cons < dateadd(dd,-40,getdate())
go
delete tttl_ps_pickup_shipper where updated_on_cons < dateadd(dd,-40,getdate())
go
delete tttl_pt_pickup_totals where updated_on_cons < dateadd(dd,-40,getdate())
go
exec purge_tttl_ev_event
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - lm_stage_purge_data

Following status was received during lm_stage_purge_data that started on $currTime
$sqlError
EOF
`;

die "There were errors in this lm_stage_purge_data at $currTime \n";
}

$currTime = localtime();
print "lm_stage_purge_data FinTime: $currTime\n";

