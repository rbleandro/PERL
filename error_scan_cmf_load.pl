#!/usr/bin/perl 

###################################################################################
#Script:   This script scans for errors during  cmf_data load from pervasive      #
#                                                                                 #
#Author:   Amer Khan                                                              #
#Revision:                                                                        #
#Date           Name            Description                                       #
#---------------------------------------------------------------------------------#
#Jun 11,08	Amer Khan       Originally created                                #
#                                                                                 #
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

#Setting Time
$currDate=localtime();

#Check if the process had any known errors
$processErrors=`grep -n "index aborted" /opt/sap/cron_scripts/cron_logs/load_cmf_data.log`;

$processErrors .= `grep -n "Cannot" /opt/sap/cron_scripts/cron_logs/load_cmf_data.log`;
$processErrors .= `grep -n "Msg" /opt/sap/cron_scripts/cron_logs/load_cmf_data.log`;

print "$processErrors\n";

if($processErrors && $processErrors !~ /15163/ && $processErrors !~ /15094/){
   print "\nThere are ERRORS in the process!! ".$processErrors."\n";

   if ($processErrors =~ /index|Cannot/ && $processErrors !~ /15163/ && $processErrors !~ /15094/){
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com,CANPARDBASybaseMobileAlerts\@canpar.com
Subject: CMF LOAD FROM PERVASIVE HAS ERRORS!!! 
Dated: $currDate
==============================================
$processErrors   = $currDate =
==============================================

EOF
`;
   }else{
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: CMF LOAD FROM PERVASIVE HAS ERRORS!!! 
Dated: $currDate
==============================================
$processErrors   = $currDate =
==============================================

EOF
`;
   }
}

