#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates AddCorrExpiredUpdate table in cmf_data            #
#                                                                            #
#Author:   Ahsan Ahmed                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2013/11/21     Amer Khan       Originally created                           #
#                                                                            #
#11/01/07      Ahsan Ahmed      Modified
###################################################################################

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

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = ""; # Initialize Var

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use lmscan
go
execute ev_event_extend
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject:   $prodserver ERROR - inserrting Extended Event rows to lmscan

Followinv status was received during updatingExtended Event that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime on $standbyserver: $currTime\n";
