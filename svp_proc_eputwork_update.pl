#!/usr/bin/perl -w

##############################################################################
#                                                                            #
#Author:    Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 28 2008	Amer Khan 	Originally created                           #
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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "svp_proc_eputwork StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
execute svp_proc_eputwork --1,'2009-07-15 00:00:00','2009-07-15 23:59:59'   
go
execute svp_proc_eput
go
execute svp_proc_eput_linkage_update
go
exit
EOF
`;
print $sqlError."\n";


if($sqlError =~ /Msg|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com
Subject: STATUS :updating sp_proc_eputwork

Following status was received during sp_proc_eputwork  that started on $currTime
$sqlError
EOF
`;
}

if($sqlError =~ /Msg/ && $sqlError !~ /2601/ ){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - sp_proc_eputwork

Following status was received during sp_proc_eputwork that started on $currTime
$sqlError
EOF
`;
}

$currTime = localtime();
print "svp_proc_eputwork FinTime: $currTime\n";

###Executing url for eput batch###
`/opt/sap/cron_scripts/svp_eput_url_execution.pl > /opt/sap/cron_scripts/cron_logs/svp_eput_url_execution.log`;


$currTime = localtime();
print "svp_proc_eput FinTime: $currTime\n";

`touch /tmp/svp_eput_proc_done`;
