#!/usr/bin/perl -w

##############################################################################
#Script:   This script checks SVP URL delays                                 #
#                                                                            #
#Author:	Amer Khan						     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Oct 12 2016	Amer Khan	Created					     #
##############################################################################

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

if ($prodserver eq 'CPDB2'){ $stbyserver = 'CPDB1'; } else { $stbyserver = 'CPDB2'; }

print "Prod: $prodserver....Stby: $stbyserver \n";

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep dump_tran_trunc_only.pl|grep -v grep|grep -v $my_pid|grep -v "vim dump_tran_trunc_only.pl"|grep -v "less dump_tran_trunc_only.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";


$sqlError = `. /opt/sap/SYBASE.sh
isql -Usybmaint -P\`/opt/sap/cron_scripts/getpass.pl sybmaint\` -S$prodserver <<EOF 2>&1
use master
go
dump transaction canada_post with truncate_only
go
dump transaction canship_webdb  with truncate_only
go
dump transaction canshipws with truncate_only
go
dump transaction cdpvkm with truncate_only
go
dump transaction cmf_data with truncate_only
go
dump transaction cmf_data_lm with truncate_only
go
dump transaction collectpickup with truncate_only
go
dump transaction collectpickup_lm with truncate_only
go
dump transaction cpscan  with truncate_only
go
dump transaction dqm_data_lm with truncate_only
go
dump transaction eput_db with truncate_only
go
dump transaction evkm_data with truncate_only
go
dump transaction liberty_db with truncate_only
go
dump transaction linehaul_data with truncate_only
go
dump transaction lm_stage with truncate_only
go
dump transaction lmscan with truncate_only
go
dump transaction mpr_data with truncate_only
go
dump transaction mpr_data_lm with truncate_only
go
dump transaction pms_data with truncate_only
go
dump transaction rate_update with truncate_only
go
dump transaction rev_hist with truncate_only
go
dump transaction rev_hist_lm with truncate_only
go
dump transaction shippingws with truncate_only
go
dump transaction sort_data with truncate_only
go
dump transaction svp_cp with truncate_only
go
dump transaction svp_lm with truncate_only
go
dump transaction tempdb with truncate_only
go
dump transaction tempdb1 with truncate_only
go
dump transaction tempdb2 with truncate_only
go
dump transaction tempdb3 with truncate_only
go
dump transaction tempdb4 with truncate_only
go
dump transaction tempdb5 with truncate_only
go
dump transaction tempdb6 with truncate_only
go
dump transaction tempdb7 with truncate_only
go
dump transaction tempdb8 with truncate_only
go
dump transaction termexp with truncate_only
go
dump transaction uss with truncate_only
go
exit
EOF
`;

print "SQL Messages: $sqlError \n";

if ($sqlError =~ /Msg/ || $sqlError =~ /Possible Issue Found/){
print $sqlError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - dump_tran_trunc_only at $finTime

$sqlError
EOF
`;
die;
}

$finTime = localtime();
print "Time Finished: $finTime\n";
