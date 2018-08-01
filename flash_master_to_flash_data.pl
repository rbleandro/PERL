#!/usr/bin/perl -w

##############################################################################
#Script:   This script will move the data from flash_master to flash_data    #
#                                                                            #
#                                                                            #
#Author:   Ahsan Ahmed							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2005/03/03   Ahsan Ahmed     Originally created                             #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sap/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
#$startHour=sprintf('%02d',((localtime())[6]));
$startHour=substr($currTime,0,3);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$bcp_error1 = `. /opt/sap/SYBASE.sh
bcp cmf_data..flash_master_view out /opt/sap/bcp_data/cpscan/flash_master_view.dat -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -SCPDB1 -c`;

print "$bcp_error1\n";

#
print "***Initiating flash_master At:".localtime()."***\n";
$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -SCPDB1 -b -n<<EOF 2>&1
truncate table cpscan..flash_data
go
exit
EOF
`;
print $sqlError."\n";
#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/){
      print "Messages From Logins Move Error...\n";
      print "$sqlError\n";
}

#Copy data from CPDB1
$bcp_error = `. /opt/sap/SYBASE.sh
bcp cpscan..flash_data in /opt/sap/bcp_data/cpscan/flash_master_view.dat -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -SCPDB1 -c -F3`;

print $bcp_error."\n";
print $sqlError."\n";
#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/ || $bcp_error =~ /error/i){
      print "Messages From Logins Move Error...\n";
      print "$sqlError\n";


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: flash_master Move Error

$sqlError
$bcp_error
EOF
`;
}
