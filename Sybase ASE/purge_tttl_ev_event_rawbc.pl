#!/usr/bin/perl -w

###################################################################################
#Script:   This script deletes all records from tttl_ev_event_rawbc               #
#          which are more than a month old.                                       #
#          This script is scheduled to run every day                              #
#                                                                                 #
#										  #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#Dec 12 2015	Amer Khan	Originally created                                #
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
use lmscan
go
exec purge_eventrawbc
go
exit
EOF
`;

print $sqlError."\n";

   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "$sqlError\nDated:".`date`."\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: tttl_ev_event_rawbc purge errors

$sqlError
EOF
`;
}
