#!/usr/bin/perl -w

###################################################################################
#Script:   This script deletes all records from DELETED_delivery_address          #
#          which are more than a month old.                                       #
#          This script is scheduled to run every week                             #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#01/19/05	Amer Khan	Originally created                                #
#                                                                                 #
###################################################################################

#Usage Restrictions
if ($#ARGV != 1){
   print "Usage:purge_DELETED_delivery_address.pl CPDATA1 cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Store inputs
$server = $ARGV[0];
$database = $ARGV[1];


print "\n###Running purge on Database:$database from Server:$server on Host:".`hostname`."###\n";


print "***Initiating purge At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -S$server <<EOF
use cpscan
go
delete DELETED_delivery_address
where DELETED_ON < dateadd(mm,-1,getdate())
go
exit
EOF
`;

print $sqlError."\n";

   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "$sqlError\nDated:".`date`."\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: DELETED_delivery_address purge errors

$sqlError
EOF
`;
}
