#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates lh_actual in linehaul_data                    #
#                                                                            #
#Author:   Ahsan Ahmed                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2014/06/3     Ahsan Ahmed     Originally created                           #
#                                                                            #
#2014/06/3      Ahsan Ahmed      Modified
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
use linehaul_data
go
execute lh_routegen
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no\s|not/ || $sqlError =~ /error/i){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject:   $prodserver ERROR - inserrting lh_actual rows to linehaul_data

Followinv status was received during update in linehaul..lh_actual that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime on $standbyserver: $currTime\n";
