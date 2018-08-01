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

#Usage Restrictions
if ($#ARGV != 0){
   print "Usage:purge_DELETED_delivery_address.pl cpscan \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

#Setting Sybase environment is set properly

#require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Store inputs
$database = $ARGV[0];


print "\n###Running purge on Database:$database from Server:$prodserver on Host:".`hostname`."###\n";


print "***Initiating purge At:".localtime()."***\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF
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
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: DELETED_delivery_address purge errors

$sqlError
EOF
`;
}
