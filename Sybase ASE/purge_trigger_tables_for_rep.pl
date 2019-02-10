#!/usr/bin/perl

###################################################################################
#Script:   This script purges tables that record any inserts, updates or deletes  #
#          in event and parcel tables                                             #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date		Name		Description                                       #
#---------------------------------------------------------------------------------#
#May 9,05	Amer Khan	Originally created                                #
#                                                                                 #
#09/01/07       Ahsan Ahmed     Modified                                          #
#                                                                                 #
###################################################################################

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

#Setting Sybase environment is set properly

#require "/opt/sap/cron_scripts/set_sybase_env.pl";

#Execute purge now 

$error = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -n -b -s'\t'<<EOF 2>&1
use cmf_data
go
delete rc_zwdisc_inserts where inserted_on < dateadd(dd,-2,getdate())
go
exit
EOF
`;
print $error."\n";


if($error =~ /error/i || $error =~ /msg/i){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Trigger Tables Deleted...

$error
EOF
`;
}

