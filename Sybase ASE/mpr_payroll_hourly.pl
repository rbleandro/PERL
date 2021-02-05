#!/usr/bin/perl

#Script: This script uploads gl data from solomon onto sybase for mpr purposes
#
#Date           Name            Description
#-------------------------------------------------------------------------------
#Mar 13,2019	Rafael Bahia       Originally created


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
$currTime = localtime();
$startHour=sprintf('%02d',((localtime())[2]));
$startMin=sprintf('%02d',((localtime())[1]));
my($day, $month, $year)=(localtime)[3,4,5];
#print "$day-".($month+1)."-".($year+1900)."\n";
$today=($year+1900)."-".($month+1)."-".$day;

print "Test Mount Point...\n";
$mount_pt=`cat /etc/mtab | grep "mpr_payroll "`;
if ($mount_pt eq ""){
   $mount_msgs = `sudo mount -t cifs \/\/10.3.1.12\/XNET\/MANAGER\/ADP /opt/sap/bcp_data/mpr_data/mpr_payroll -o username=em_process1,password=Canpar_2001,domain=canparnt 2>&1`;
   print "Any mounting messages, already mounted messages can be ignored:\n\n $mount_msgs\n";
}else{
   print "Dir is already mounted \n";
}

print "MPR Payroll StartTime: $currTime, Hour: $startHour, Min: $startMin\n";


#Uploading data...
if (-e "/opt/sap/bcp_data/MPR_Export_Hourly_Payroll_regex.csv"){
$bcp_msg = `. /opt/sap/SYBASE.sh
bcp mpr_data..mpr_hourly_union_time in /opt/sap/bcp_data/MPR_Export_Hourly_Payroll_regex.csv -Ucronmpr -S$prodserver -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -c -t"," --skiprows 2`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - mpr_payroll_hourly.pl - csv file unavailable

The file MPR_Export_Hourly_Payroll.csv is not available at /opt/sap/bcp_data/mpr_data/mpr_payroll yet or the cleaned file MPR_Export_Hourly_Payroll_regex.csv was not successfully generated at /opt/sap/bcp_data.

Check the script mpr_payroll_hourly.sh for more details on the generation of the cleaned file.

This script's name is mpr_payroll_hourly.pl and is located at the default scripts folder.

EOF
`;

die "File not available yet, dying\n\n";
}

#Any errors
print "BCP Messages: $bcp_msg";

if($bcp_msg =~ /error/ || $bcp_msg =~ /failed/ ){
print "Errors may have occurred during bcp...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - bcp of mpr_payroll_hourly.pl
Following status was received during mpr_payroll_hourly.pl bcp that started on $currTime
$bcp_msg

This script's name is mpr_payroll_hourly.pl and is located at the default scripts folder.

EOF
`;
die "Can't Continue. BCP errors.\n\n";
}

$sqlError = `. /opt/sap/SYBASE.sh
isql -Ucronmpr -P\`/opt/sap/cron_scripts/getpass.pl cronmpr\` -S$prodserver -b -n<<EOF 2>&1
use mpr_data
go
set clientapplname \'MPR_Export_Hourly_Payroll\'
go
execute load_terminal_time
go
execute load_employee_time
go
exit
EOF
`;
print "Any sql messages:". $sqlError."\n";

if($sqlError =~ /Msg/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - mpr_payroll_hourly.pl - exec procs phase

Following status was received during mpr_payroll_hourly.pl that started on $currTime
$sqlError

This script's name is mpr_payroll_hourly.pl and is located at the default scripts folder.

EOF
`;

die "Something went wrong, not moving MPR_Export_Hourly_Payroll file yet";
}

#If all is good, archive mpr file...
$mv_msg = `sudo mv /opt/sap/bcp_data/mpr_data/mpr_payroll/MPR_Export_Hourly_Payroll.xlsx /opt/sap/bcp_data/mpr_data/mpr_payroll/backup/MPR_Export_Hourly_Payroll_$today.xlsx 2>&1`;
print "Any messages from moving file: $mv_msg \n\n";

$mv_msg =~ s/`//g;

if($mv_msg =~ /cannot/){
      print "Errors may have occurred during file copy...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: CANPARDatabaseAdministratorsStaffList\@canpar.com
Subject: Error - moving file to mpr_payroll_hourly.pl

Following status was received during moving file to mpr_payroll_hourly.pl that started on $currTime
$mv_msg

This script's name is mpr_payroll_hourly.pl and is located at the default scripts folder.

EOF
`;

die "Something went wrong when moving the file to the backup folder";
}
