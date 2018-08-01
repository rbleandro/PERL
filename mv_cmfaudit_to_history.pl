#!/usr/bin/perl -w

##############################################################################
#Script:   This script process move records that are old from cmfaudit       #
#          to cmf_audit_history                                              #
#                                                                            #
#                                                                            #
#Author:   Amer Khan                                                         #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#                                                                            #
#Apr/27/2011	Amer Khan	Created
###################################################################################

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

require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

#Execute move_cmfaudit_to_history

$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$prodserver -w300 <<EOF 2>&1
use cmf_data    
go   
execute move_cmfaudit_to_history
go    
exit
EOF
`;
print "CurrTime: $currTime\n".$sqlError."\n";

 if (($sqlError =~ /Error/i || $sqlError =~ /no/i || $sqlError =~ /message/i) && ($sqlError !~ /Duplicate row was ignored/i)){
      print "Messages From move_cmfaudit_to_history...\n";
      print "$sqlError\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: move_cmfaudit_to_history

CurrTime: $currTime
$sqlError
EOF
`;
}
