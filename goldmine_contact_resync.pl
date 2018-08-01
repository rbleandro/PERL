#!/usr/bin/perl -w

##############################################################################
#Script:   This script updates cmfshipr table in cmf_data with info          #
#          from MS goldmine CONTACT1                                         #
#                                                                            #
#Author:    Ahsan Ahmed							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Apr 9 2007	Amer Khan 	Originally created                           #
#                                                                            #
##############################################################################

#Usage Restrictions
open (PROD, "</opt/sybase/cron_scripts/passwords/check_prod");
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

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use cmf_data
go
set replication off
go
execute sync_goldmine_contact
go
exit
EOF
`;
print $sqlError."\n";


if($sqlError =~ /no|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating goldmine CONTACT1

Following status was received during updating goldmine CONTACT1 that started on $currTime
$sqlError
EOF
`;
}
$currTime = localtime();
print "FinTime: $currTime\n";
