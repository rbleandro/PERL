#!/usr/bin/perl -w

#Script:   This script sends out pages when thresholds of segments in database
#          are reached. This script is executed from within threshold stored
#          procedure and should not be used individually.
#
#Author:   Amer Khan
#Revision:
#Date           Name            Description
#---------------------------------------------------------------------------------
#08/27/04       Amer Khan       Originally created
#Mar 30 2019	Rafael Bahia	Changed the script to automatically add extra space as a precaution
#Apr 03 2019	Rafael Bahia	Implemented better error handling and mail messaging
#May 15 2019	Rafael Bahia	Changed the mail client to sendmail for faster mailing. Changed the script so it can run properly on secondary servers to report low space and add more space when necessary.
#May 15 2019	Rafael Bahia	Now the script will send an email if the script is invoked with the wrong parameter order.
#May 15 2019	Rafael Bahia	Now the script is taking into consideration all available temporary databases existing on the server (named with the tempdb* prefix) and not only tempdb.
#May 29 2019	Rafael Bahia	Final message regarding the automatic database expansion now differentiates between production and secondary servers.

#Usage Restrictions
#print $#ARGV;
if ($#ARGV != 2){
print "Usage: pageNow.pl cpscan image_seg 256000 \n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR on script pageNow.pl. Check as soon as possible!!

The script didn't receive the proper parameters in the right order. Check the threshold procedures on Sybase and match the parameters. The script is located is /opt/sap/cron_scripts/pageNow.pl.
EOF
`;
die;
}

use Sys::Hostname;
$prodserver = hostname();

if ($prodserver =~ /cpsybtest2/){
$prodserver='CPSYBTEST';
}

#open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
#while (<PROD>){
#@prodline = split(/\t/, $_);
#$prodline[1] =~ s/\n//g;
#}
#if ($prodline[1] eq "0" ){
#print "standby server \n";
#die "This is a stand by server\n";
#}

#Saving argument
$dbname = $ARGV[0];
$segname = $ARGV[1];
$space_left = $ARGV[2];

if ($segname eq "logsegment"){
$spacetoadd = 1000;
}else{
$spacetoadd = 5000;
}

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute

#Convert to MB
$space_left = ($space_left/512);
#print $space_left;

#CANPARDatabaseAdministratorsStaffList

if ($dbname =~ /tempdb/){

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!

Only $space_left MB left

Please contact DBAs for support.

Dated: $currDate\--$currHour\:$currMin
EOF
`;

}
else{
if ($space_left <= 500){
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!

Only $space_left MB left

Please contact DBAs for support.

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}else{

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use master
go
exec sp_add_database_space $dbname,"$segname",$spacetoadd
go
exit
EOF
`;

if ($sqlError =~ /Msg/){
print $sqlError."\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!

Only $space_left MB left. Attempting to add 5GB of extra space automatically failed. See the error below.

$sqlError

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}
else{
if ($sqlError =~ /no space left to add/){
print $sqlError."\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!

Only $space_left MB left

The space for this segment on this secondary server is already synchronized with production. Please check what might have triggered the segment growth.

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}else{
print $sqlError."\n";

`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Segment: $segname in Database: $dbname may be FULL!!!

Only $space_left MB left. 

If this is production, 5 GB were added automatically as a precaution (see output below). You should still check if any additional action is necessary. Remember to also add space on the standby and dr servers accordingly.

If this is a secondary server, the database size was synchronized automatically using the production's database size as reference (see output below). If the attempt to synchronize the space failed, check the procedure master..sp_add_database_space and see what is missing (use the log below as a reference).

$sqlError

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}
}
}
}

