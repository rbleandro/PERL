#!/usr/bin/perl -w

##############################################################################
#Script:   This script copies syslogins table from CPSYBTEST to CPSYBTEST to keep    #
#          them in sync                                                      #
#                                                                            #
#Author:   Amer Khan							     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#2005/03/03   Amer Khan	      Originally created                             #
#                                                                            #
##############################################################################

#Setting Sybase environment is set properly

#require "/opt/sybase/cron_scripts/set_sybase_env.pl";


#Set inputs
#Set starting variables
$currTime = localtime();
#$startHour=sprintf('%02d',((localtime())[6]));
$startHour=substr($currTime,0,3);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$bcp_error1 = `. /opt/sybase/SYBASE.sh
bcp master..vw_syslogins out /opt/sybase/bcp_data/master/syslogins_CPSYBTEST.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SCPSYBTEST -c`;

print "$bcp_error1\n";

#Execute Logins Purge
#
print "***Initiating logins deletes At:".localtime()."***\n";
$sqlError = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SNew_CPSYBTEST -b -n<<EOF 2>&1
sp_configure "allow updates", 1
go
delete master..syslogins where suid > 2 and name not in ('sa')
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

#Copy logins from CPSYBTEST
$bcp_error = `. /opt/sybase/SYBASE.sh
bcp master..syslogins in /opt/sybase/bcp_data/master/syslogins_CPSYBTEST.dat -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SNew_CPSYBTEST -c -F3`;

$sqlError1 = `. /opt/sybase/SYBASE.sh
isql -Usa -P\`/opt/sybase/cron_scripts/getpass.pl sa\` -SNew_CPSYBTEST -b -n<<EOF 2>&1
sp_configure "allow updates",0
go
exit
EOF
`;

print $bcp_error."\n";
print $sqlError."\n";
#print "@spid\n";
   if ($sqlError =~ /Error/ || $sqlError =~ /error/ || $bcp_error =~ /error/i){
      print "Messages From Logins Move Error...\n";
      print "$sqlError\n";


`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Logins Move Error

$sqlError
EOF
`;
}
