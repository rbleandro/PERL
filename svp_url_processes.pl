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
#        die "This is a stand by server\n"
}
use Sys::Hostname;
$prodserver = hostname();

#Setting Time
$currDate=localtime();

#`elinks \"http\:\/\/10.3.1.114\/sp\/batchEputEvaluation.do\?tokenId\=canpar\&token\=M985NRKHVKWuet26QvsMkQbP6mY\=\" \> out.out`;
#sleep(10);

#Check if the process had any known errors
$processErrors=`grep -P "started|completed" /root/logs/canpar_2008-07-02.log`;
@procArray = split(/\n/,$processErrors);

if($procArray[$#procArray] =~ /started/i){
   print "$procArray[$#procArray]\n";
   if (-e "/tmp/svp_started"){}else{
      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: svp_url trigger started... 
==============================================
$procArray[$#procArray]
==============================================

EOF
`;
      `touch /tmp/svp_started`;
   }
}


if($procArray[$#procArray] =~ /completed/i){
   `rm /tmp/svp_started`;
   print "\nThere are ERRORS in the process!! ".$procArray[$#procArray]."\n";

      `/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: svp_url trigger completed...
==============================================
$procArray[$#procArray]
==============================================

EOF
`;
}


