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
#May 02 2017	Amer Khan	Originally created                                #
#                                                                                 #
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

print "***Initiating purge At:".localtime()."***\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver <<EOF
use rev_hist
go
exec qsp_bcxref2_delete_days 14
go
exit
EOF
`;

print $sqlError."\n";

   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "$sqlError\nDated:".`date`."\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: rev_hist qsp_bcxref2_delete_days purge errors

$sqlError
EOF
`;
}
