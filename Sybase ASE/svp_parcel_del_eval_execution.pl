#!/usr/bin/perl 

use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use lib ('/opt/sap/cron_scripts/lib');
use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );


my $mail = 'CANPARDatabaseAdministratorsStaffList';
my $skipcheckprod=0;
my $noalert=0;
my $prodserver = hostname();
my $finTime = localtime();
my $checkProcessRunning=1;
my $my_pid="";
my $currTime="";
my $help=0;
my $sqlError="";
my $monitorOutput = "";
my $date_flag;

GetOptions(
	'skipcheckprod|s=s' => \$skipcheckprod,
	'to|r=s' => \$mail,
	'dbserver|ds=s' => \$prodserver,
	'skipcheckprocess|p=i' => \$checkProcessRunning,
	'noalert' => \$noalert,
	'help|h' => \$help
) or die showDefaultHelp(1,$0);

showDefaultHelp($help,$0);
isProd($skipcheckprod);

if ($prodserver =~ /cpsybtest/)
{
$prodserver = "CPSYBTEST";
}

$currTime = localtime();
print "StartTime: $currTime\n";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon += 1;

$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);

$date_flag = "$mon-$mday-$year $hour:$min:$sec";
print "Date to check from : $date_flag \n";

$sqlError = `. /opt/sap/SYBASE.sh
isql_r -V -S$prodserver -b -n<<EOF 2>&1
use svp_cp
go
set clientapplname \'svp_proc_parcel_deltermupdation\'    
go    
execute svp_proc_parcel_deltermupdation    
go
exit
EOF
`;
print $sqlError."\n";

if($sqlError =~ /no|not/){
      print "Errors may have occurred during update...\n\n";
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com,aahmed\@canpar.com,CANPARDatabaseAdministratorsStaffList\@canpar.com,forourke\@canpar.com
Subject: Status - svp_proc_parcel_deltermupdation 

Following status was received during svp_proc_parcel_deltermupdation that started on $currTime
$sqlError
EOF
`;
}else{
`/usr/sbin/sendmail -t -i <<EOF
To: kkotur\@canpar.com
Subject: Status - svp_proc_parcel_deltermupdation

Following status was received during svp_proc_parcel_deltermupdation that started on $currTime
$sqlError
EOF
`;
}

#**********************************

print "SVP URL Execution StartTime: $currTime\n";

`elinks \"http\:\/\/www.canpar.com\/sp\/batchParcelDelEvaluation.do\?tokenId\=canpar\&token\=M985NRKHVKWuet26QvsMkQbP6mY\=\" \> \/tmp\/out2.out 2>&1`;
sleep(20); 

`cat /tmp/out2.out`;

while (1==1){
unless (-e "/tmp/svp_d_completed"){ 
sleep(5);
$monitorOutput = `/opt/sap/cron_scripts/svp_parcel_del_url_monitor.pl $date_flag`;
}else{
`rm /tmp/svp_d_completed`;
last;
}
}

