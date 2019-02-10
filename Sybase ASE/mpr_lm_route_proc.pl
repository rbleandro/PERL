#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Jan 20 2014	Amer Khan 	Originally created                           #
#                                                                            #
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
if ($prodserver eq "CPDB2" ) {
    $standbyserver = "CPDB1"; 
}
else
{
   $standbyserver = "CPDB2";
}

#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));
$startMonth=sprintf('%02d',((localtime())[4]));
$startDay=sprintf('%02d',((localtime())[3]));
$startYear=sprintf('%02d',((localtime())[5]));

$startMonth += 1; #Month in perl starts from 0 and ends on 11.
$startYear += 1900; #Needed to get correct 4digit year.

$today = "$startMonth/$startDay/$startYear";

print "mpr_lm_route_proc For Loomis StartTime: $currTime, Hour: $startHour, Min: $startMin\n";
#if (1==2){
$my_pid = getppid();
$isProcessRunning =`ps -ef|grep sybase|grep mpr_lm_route_proc.pl|grep -v grep|grep -v $my_pid|grep -v "vim mpr_lm_route_proc.pl"|grep -v "less mpr_lm_route_proc.pl"`;

#print "My pid: $my_pid\n";
print "Running: $isProcessRunning \n";

if ($isProcessRunning){
die "\n Can not run, previous process is still running \n";

}else{
print "No Previous process is running, continuing\n";
}

print "mpr_lm_route_proc StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   unless (-e "/tmp/mpr_lm_bcxref_work_update_lod_procs_done"){# && -e "/tmp/emp_time_load_done"){ 
      sleep(5);
   }else{
      last;
   }
}

$currTime = localtime();
print "\nAll flags are set running proc now $currTime\n\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data_lm
go
execute mpr_route_proc
go
exit
EOF
`;
print $sqlError."\n";

$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_lm_route_proc

Following status was received during mpr_lm_route_proc that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_lm_route_proc at $currTime \n";
}

$currTime = localtime();
print "mpr_lm_route_proc FinTime: $currTime\n";

`touch /tmp/mpr_lm_route_proc_done`;

