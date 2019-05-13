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


#Usage Restrictions
if ($#ARGV != 2){
   print "Usage: pageNow.pl cpscan image_seg 256000 \n";
   die "Script Executed With Wrong Number Of Arguments\n";
}

open (PROD, "</opt/sap/cron_scripts/passwords/check_prod");
while (<PROD>){
@prodline = split(/\t/, $_);
$prodline[1] =~ s/\n//g;
}
if ($prodline[1] eq "0" ){
print "standby server \n";
die "This is a stand by server\n";
}
use Sys::Hostname;
$prodserver = hostname();

if ($prodserver =~ /cpsybtest2/){
$prodserver='CPSYBTEST';
}


#Saving argument
$dbname = $ARGV[0];
$segname = $ARGV[1];
$space_left = $ARGV[2];

#Setting Time range to scan
$currDate=((localtime())[5]+1900)."/".sprintf('%02d',((localtime())[4]+1))."/".sprintf('%02d',((localtime())[3]));
$currHour=sprintf('%02d',((localtime())[2]));
$currMin =sprintf('%02d',((localtime())[1]-1)); #Subtract one to check the past minute

#Convert to MB
$space_left = ($space_left/512);

if ($space_left <= 500 && $dbname ne 'tempdb'){
`mail -s "Segment: $segname in Database: $dbname may be FULL!!!" \`cat /opt/sap/sybmail/SYB_ADM_GROUP\` <<EOF

Only $space_left MB left

Please contact DBAs for support

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}else{

$sqlError = `. /opt/sap/SYBASE.sh
isql -Usa -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver <<EOF 2>&1
use master
go
exec sp_add_database_space $dbname,"$segname",5000
go
exit
EOF
`;

if ($sqlError =~ /Msg/ || $sqlError =~ /no|not/){
print $sqlError."\n";

`mail -s "Segment: $segname in Database: $dbname may be FULL!!!" \`cat /opt/sap/sybmail/SYB_ADM_GROUP\` <<EOF

Only $space_left MB left. Attempting to add 5GB of extra space automatically failed. See the error below.

$sqlError

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}
else{
`mail -s "Segment: $segname in Database: $dbname may be FULL!!!" \`cat /opt/sap/sybmail/SYB_ADM_GROUP\` <<EOF

Only $space_left MB left. 5 GB were added as a precaution (in production only) but you should investigate further and check if any additional action is necessary. Remember to also add space on the standby and dr servers.

$sqlError

Dated: $currDate\--$currHour\:$currMin
EOF
`;
}
}

