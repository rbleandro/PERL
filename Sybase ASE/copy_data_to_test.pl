#!/usr/bin/perl -w

##############################################################################
#Script:   This script checks SVP URL delays                                 #
#                                                                            #
#Author:	Rafael Bahia												     #
#Revision:                                                                   #
#Date           Name            Description                                  #
#----------------------------------------------------------------------------#
#Oct 24 2018	Rafael Bahia	Created										 #
##############################################################################

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
$testserver = '10.3.1.165';

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
#$startHour=substr($currTime,0,4);
$startMin=sprintf('%02d',((localtime())[1]));

print "CurrTime: $currTime, Hour: $startHour, Min: $startMin\n";

$deleteoldfiles =`find /home/sybase/db_backups/ -mindepth 1 -mtime +7 -delete`;

$database = $ARGV[0];
$table = $ARGV[1];

$bcpError=`/opt/sap/OCS-16_0/bin/bcp $database..$table out /home/sybase/db_backups/$database\_$table.dat -n -S CPDB1 -U sa -P s9b2s3`;

if ($bcpError =~ /Error/ || $bcpError =~ /Msg/){
print $bcpError."\n";

$finTime = localtime();

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Errors - copy_data_to_test at $finTime

$bcpError
EOF
`;
die;
}

$scpError=`scp /home/sybase/db_backups/$database\_$table.dat sybase\@10.3.1.165:~/db_backups/`;
print "$scpError\n";

#$load_msgs = `ssh $testserver /opt/sap/cron_scripts/load_data_to_test.pl $database $table`;
#print "$load_msgs \n";

$finTime = localtime();
print "Time Finished: $finTime\n";