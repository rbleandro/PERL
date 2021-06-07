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
my $monitorOutput;

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

my $currDate=localtime();
$currTime = localtime();
my $startHour=sprintf('%02d',((localtime())[2]));
my $startMin=sprintf('%02d',((localtime())[1]));
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
$mon=sprintf('%02d',$mon);
$mday=sprintf('%02d',$mday);
$min=sprintf('%02d',$min);
$hour=sprintf('%02d',$hour);
$sec=sprintf('%02d',$sec);

my $date_flag = "$mon-$mday-$year $hour:$min:$sec";
print "Date to check from : $date_flag \n";

#*******************************
print "svp_proc_parcel_deltermupdation StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

#**********************************

print "SVP URL Execution StartTime: $currTime, Hour: $startHour, Min: $startMin\n";

`elinks \"https\:\/\/hqvlmsprtlstg1.loomisexpress.com\/sp_lm\/batchParcelExpectedDelEvaluation.do\?tokenId\=canpar\&token\=M985NRKHVKWuet26QvsMkQbP6mY\=\" \> \/tmp\/out_lm2.out 2>&1`;
sleep(20); 

`cat /tmp/out_lm2.out`;

while (1==1){
unless (-e "/tmp/svp_lm_d_completed"){ 
sleep(5);
$monitorOutput = `/opt/sap/cron_scripts/svp_parcel_del_url_monitor_lm.pl $date_flag`;
}else{
`rm /tmp/svp_lm_d_completed`;
last;
}
}

