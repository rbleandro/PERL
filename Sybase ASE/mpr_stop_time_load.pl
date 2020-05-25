#!/usr/bin/perl -w


#Author:    Amer Khan
#Date          Name           Description
#Apr 28 2008   Amer Khan 	   Originally created
#Apr 30 2020   Rafael Bahia   Changed db conn to use cronmpr user to allow separate tempdb usage

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

#Set starting variables
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));

print "mpr_stop_time_load StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

while (1==1){
   unless (-e "/tmp/emp_time_load_done"){
      sleep(5);
   }else{
      last;
   }
}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl sa\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
execute mpr_stop_time_load
go
exit
EOF
`;

print $sqlError."\n";
$currTime = localtime();

if($sqlError =~ /no|not|Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: ERROR - updating mpr_stop_time_load

Following status was received during mpr_stop_time_load that started on $currTime
$sqlError
EOF
`;

die "Cant continue, there were errors in this mpr_stop_time_load at $currTime \n";
}

$currTime = localtime();
print "mpr_pnd_wtd_and_notd FinTime: $currTime\n";

`touch /tmp/mpr_stop_time_load_done`;

